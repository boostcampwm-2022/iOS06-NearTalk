//
//  MainMapViewController.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/14.
//

import CoreLocation
import MapKit
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class MainMapViewController: UIViewController {
    
    // MARK: - UI Components
    private(set) lazy var mapView: MKMapView = .init().then {
        $0.showsUserLocation = true
        $0.showsCompass = false
    }
    private lazy var currentUserLocationLabel: UILabel = .init().then {
        $0.textColor = .label
        $0.textAlignment = .center
        $0.backgroundColor = .secondaryBackground
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private(set) lazy var compassButton: MKCompassButton = .init(mapView: self.mapView)
    private(set) lazy var moveToCurrentLocationButton: UIButton = .init().then {
        $0.setBackgroundImage(UIImage(systemName: "location.circle"), for: .normal)
        $0.tintColor = .primaryColor?.withAlphaComponent(0.8)
    }
    private(set) lazy var createChatRoomButton: UIButton = .init().then {
        $0.setBackgroundImage(UIImage(systemName: "message.badge.circle"), for: .normal)
        $0.tintColor = .primaryColor?.withAlphaComponent(0.8)
    }

    // MARK: - Properties
    private var coordinator: MainMapCoordinator?
    private var viewModel: MainMapViewModel!
    private let disposeBag: DisposeBag = .init()
    private let locationManager: CLLocationManager = .init().then {
        $0.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - LifeCycles
    static func create(with viewModel: MainMapViewModel, coordinator: MainMapCoordinator) -> MainMapViewController {
        let mainMapVC = MainMapViewController()
        mainMapVC.viewModel = viewModel
        mainMapVC.coordinator = coordinator
        
        return mainMapVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubViews()
        self.configureConstraints()
        self.configureDelegates()
        self.registerAnnotationViewClass()
        self.bindViewModel()
    }
    
    // MARK: - Methods
    private func addSubViews() {
        view.addSubview(self.mapView)
        
        self.mapView.addSubview(self.currentUserLocationLabel)
        self.mapView.addSubview(self.compassButton)
        self.mapView.addSubview(self.moveToCurrentLocationButton)
        self.mapView.addSubview(self.createChatRoomButton)
    }
    
    private func configureConstraints() {
        let safeAreaLayoutGuide = self.mapView.safeAreaLayoutGuide
        
        self.mapView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.currentUserLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(48)
            make.height.equalTo(36)
        }

        self.compassButton.snp.makeConstraints { make in
            make.top.equalTo(self.currentUserLocationLabel.snp.bottom)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-5)
            make.width.equalTo(45)
            make.height.equalTo(45)
        }
        
        self.moveToCurrentLocationButton.snp.makeConstraints { make in
            make.top.equalTo(compassButton.snp.bottom)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-5)
            make.width.equalTo(45)
            make.height.equalTo(45)
        }
        
        self.createChatRoomButton.snp.makeConstraints { make in
            make.top.equalTo(self.moveToCurrentLocationButton.snp.bottom)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-5)
            make.width.equalTo(45)
            make.height.equalTo(45)
        }
    }
    
    private func configureDelegates() {
        self.mapView.delegate = self
        self.locationManager.delegate = self
    }
    
    private func bindViewModel() {

        // MARK: - Bind VM input
        let input = MainMapViewModel.Input(
            mapViewDidAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
                .compactMap { _ -> NCMapRegion? in
                    guard let region = self.mapView.cameraBoundary?.region
                    else { return nil }
                    
                    return self.convertToNCMapRegion(with: region)
                }
                .asObservable(),
            didTapMoveToCurrentLocationButton: self.moveToCurrentLocationButton.rx.tap.asObservable(),
            didTapCreateChatRoomButton: self.createChatRoomButton.rx.tap.asObservable(),
            didTapAnnotationView: self.mapView.rx.didSelectAnnotationView.compactMap { $0.annotation },
            didDragMapView: self.mapView.rx.panGesture().map { _ in }.asObservable(),
            didUpdateUserLocation: self.mapView.rx.didUpdateUserLocation
                .compactMap { _ -> NCLocation? in
                    guard let currentUserLocation = self.locationManager.location?.coordinate
                    else { return nil }

                    return NCLocation(latitude: currentUserLocation.latitude,
                                      longitude: currentUserLocation.longitude)
                }
                .asObservable()
        )
        
        // MARK: - Bind VM output
        let output = self.viewModel.transform(input: input)
        
        output.showAccessibleChatRooms
            .asDriver(onErrorJustReturn: [])
            .map { chatRooms -> [ChatRoomAnnotation] in
                self.mapView.setUserTrackingMode(.follow, animated: true)

                return chatRooms.compactMap {
                    let annotation = ChatRoomAnnotation.create(with: $0)

                    return annotation
                }
            }
            .drive(self.mapView.rx.annotations)
            .disposed(by: self.disposeBag)
        
        output.showCreateChatRoomViewEvent
            .asDriver(onErrorJustReturn: false)
            .filter { $0 == true }
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showCreateChatRoomView()
            })
            .disposed(by: self.disposeBag)
        
        output.showAnnotationChatRooms
            .asObservable()
            .subscribe(onNext: { [weak self] chatRooms in
                guard let mainMapVC = self
                else { return }

                if chatRooms.count > 1 {
                    self?.coordinator?.showBottomSheet(mainMapVC: mainMapVC, chatRooms: chatRooms)
                    self?.mapView.selectedAnnotations = []
                }
            })
            .disposed(by: self.disposeBag)

        output.followCurrentUserLocation
            .asObservable()
            .subscribe(onNext: { [weak self] isFollowing in
                if isFollowing {
                    self?.mapView.setUserTrackingMode(.follow, animated: false)
                } else {
                    self?.mapView.setUserTrackingMode(.none, animated: false)
                }
            })
            .disposed(by: self.disposeBag)
        
        output.currentUserLocation
            .asObservable()
            .subscribe(onNext: { currentUserLocation in
                let currentUserLatitude = currentUserLocation.latitude
                let currentUserLongitude = currentUserLocation.longitude
                UserDefaults.standard.set(currentUserLatitude, forKey: UserDefaultsKey.currentUserLatitude.string)
                UserDefaults.standard.set(currentUserLongitude, forKey: UserDefaultsKey.currentUserLongitude.string)
                
                let currentUserCLLocation = CLLocation(latitude: currentUserLatitude, longitude: currentUserLongitude)
                let geocoder = CLGeocoder()
                let locale = Locale(identifier: "Ko-kr")
                geocoder.reverseGeocodeLocation(currentUserCLLocation, preferredLocale: locale) { [weak self] (placeMarks, _) in
                    guard let placeMarks = placeMarks,
                          let address = placeMarks.last?.name
                    else { return }
                    
                    self?.currentUserLocationLabel.text = address
                    self?.currentUserLocationLabel.textAlignment = .center
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func registerAnnotationViewClass() {
        // Single: Group or DM
        self.mapView.register(
            GroupChatRoomAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        self.mapView.register(
            DmChatRoomAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        // Clustering
        self.mapView.register(
            ChatRoomClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
    }
    
    private func convertToNCMapRegion(with region: MKCoordinateRegion) -> NCMapRegion {
        let centerLocation: NCLocation = .init(latitude: region.center.latitude, longitude: region.center.longitude)
        let latitudeDelta: Double = region.span.latitudeDelta
        let longitudeDelta: Double = region.span.longitudeDelta
        
        return NCMapRegion(centerLocation: centerLocation,
                           latitudeDelta: latitudeDelta,
                           longitudeDelta: longitudeDelta)
    }
    
    private func followUserLocation() {
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    private func setCamera(with centerLocation: CLLocation) {
        self.setCameraBoundary(centerLocation: centerLocation)
        self.setCameraZoomRange()
    }
    
    private func setCameraBoundary(centerLocation: CLLocation, meters regionMeters: CLLocationDistance = 5000) {
        let coordinateRegion = MKCoordinateRegion(center: centerLocation.coordinate,
                                                  latitudinalMeters: 5000,
                                                  longitudinalMeters: 5000)
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: coordinateRegion)
        self.mapView.setCameraBoundary(cameraBoundary, animated: true)
    }
    
    private func setCameraZoomRange(minDistance: CLLocationDistance = 1, maxDistance: CLLocationDistance = 5000) {
        let zoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: minDistance,
                                                  maxCenterCoordinateDistance: maxDistance)
        self.mapView.setCameraZoomRange(zoomRange, animated: true)
    }
}

extension MainMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let chatRoomAnnotation = annotation as? ChatRoomAnnotation else {
            return nil
        }
        
        switch chatRoomAnnotation.roomType {
        case .group:
            let groupChatRoomAnnotationView = GroupChatRoomAnnotationView(annotation: chatRoomAnnotation,
                                                                    reuseIdentifier: GroupChatRoomAnnotationView.reuseIdentifier)
            
            groupChatRoomAnnotationView.insert(coordinator: coordinator)
            
            if let startUserCoordinate = self.mapView.userLocation.location?.coordinate {
                let startUserNCLocation = NCLocation(latitude: startUserCoordinate.latitude,
                                                     longitude: startUserCoordinate.longitude)
                
                groupChatRoomAnnotationView.configureAccessible(userLocation: startUserNCLocation,
                                                                targetAnnotation: annotation)
            }
            
            self.mapView.rx.didUpdateUserLocation
                .asDriver()
                .drive(onNext: { userLocation in
                    let currentUserLocation = NCLocation(latitude: userLocation.coordinate.latitude,
                                                         longitude: userLocation.coordinate.longitude)

                    groupChatRoomAnnotationView.configureAccessible(userLocation: currentUserLocation,
                                                                    targetAnnotation: annotation)

                })
                .disposed(by: self.disposeBag)

            return groupChatRoomAnnotationView
            
        case .directMessage:
            return DmChatRoomAnnotationView(annotation: chatRoomAnnotation,
                                            reuseIdentifier: DmChatRoomAnnotationView.reuseIdentifier)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let primaryColor: UIColor = .primaryColor
        else { return MKOverlayRenderer(overlay: overlay) }
        
        if overlay.isKind(of: MKCircle.self) {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = primaryColor.withAlphaComponent(0.01)
            circleRenderer.strokeColor = primaryColor
            circleRenderer.lineWidth = 0.5
            return circleRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension MainMapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            return
        }
    }
}
