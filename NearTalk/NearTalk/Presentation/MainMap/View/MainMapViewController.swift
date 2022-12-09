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
    }
    private(set) lazy var moveToCurrentLocationButton: UIButton = .init().then {
        $0.setBackgroundImage(UIImage(systemName: "location.circle"), for: .normal)
        $0.tintColor = .systemBlue
    }
    private(set) lazy var createChatRoomButton: UIButton = .init().then {
        $0.setBackgroundImage(UIImage(systemName: "pencil.circle"), for: .normal)
        $0.tintColor = .systemBlue
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
        
        self.locationManagerDidChangeAuthorization(self.locationManager)
        self.addSubViews()
        self.configureConstraints()
        self.configureDelegates()
        self.registerAnnotationViewClass()
        self.bindViewModel()
    }
    
    // MARK: - Methods
    private func addSubViews() {
        view.addSubview(self.mapView)
        
        self.mapView.addSubview(self.moveToCurrentLocationButton)
        self.mapView.addSubview(self.createChatRoomButton)
    }
    
    private func configureConstraints() {
        self.mapView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        self.moveToCurrentLocationButton.snp.makeConstraints {
            $0.top.equalTo(self.view).offset(160)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-5)
            $0.width.equalTo(45)
            $0.height.equalTo(45)
        }
        
        self.createChatRoomButton.snp.makeConstraints {
            $0.top.equalTo(self.moveToCurrentLocationButton.snp.bottom)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-5)
            $0.width.equalTo(45)
            $0.height.equalTo(45)
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
            didUpdateUserLocation: self.mapView.rx.didUpdateUserLocation
                .compactMap { event -> NCLocation? in
                    guard let latitude = event.location?.coordinate.latitude,
                          let longitude = event.location?.coordinate.longitude
                    else { return nil }
                    
                    return NCLocation(latitude: latitude, longitude: longitude)
                }
                .asObservable()
        )
        
        // MARK: - Bind VM output
        let output = self.viewModel.transform(input: input)
        
        output.showAccessibleChatRooms
            .asDriver(onErrorJustReturn: [])
            .map { chatRooms in
                return chatRooms.compactMap { ChatRoomAnnotation.create(with: $0) }
            }
            .drive(self.mapView.rx.annotations)
            .disposed(by: self.disposeBag)
        
        output.moveToCurrentLocationEvent
            .asDriver(onErrorJustReturn: false)
            .filter { $0 == true }
            .drive(onNext: { [weak self] _ in
                // self?.followUserLocation()
            })
            .disposed(by: self.disposeBag)
        
        output.showCreateChatRoomViewEvent
            .asDriver(onErrorJustReturn: false)
            .filter { $0 == true }
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showCreateChatRoomView()
            })
            .disposed(by: self.disposeBag)
        
        output.showAnnotationChatRooms
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] chatRooms in
                guard let mainMapVC = self
                else { return }
                
                if chatRooms.count > 1 {
                    self?.coordinator?.showBottomSheet(mainMapVC: mainMapVC, chatRooms: chatRooms)
                    self?.mapView.selectedAnnotations = []
                }
            })
            .disposed(by: self.disposeBag)
        
        output.currentUserLocation
            .asDriver(onErrorJustReturn: NCLocation.naver)
            .drive(onNext: { [weak self] location in
                let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                self?.followUserLocation()
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
            
            return groupChatRoomAnnotationView
        case .directMessage:
            return DmChatRoomAnnotationView(annotation: chatRoomAnnotation,
                                            reuseIdentifier: DmChatRoomAnnotationView.reuseIdentifier)
        }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last
        else { return }
        
        let currentUserLatitude = Double(userLocation.coordinate.latitude)
        let currentUserLongitude = Double(userLocation.coordinate.longitude)
        UserDefaults.standard.set(currentUserLatitude, forKey: "CurrentUserLatitude")
        UserDefaults.standard.set(currentUserLongitude, forKey: "CurrentUserLongitude")
        
        guard let cameraBoundary = self.mapView.cameraBoundary
        else { return }
        
        let southWest = NCLocation(latitude: cameraBoundary.region.center.latitude - (cameraBoundary.region.span.latitudeDelta / 2),
                                   longitude: cameraBoundary.region.center.longitude - (cameraBoundary.region.span.longitudeDelta / 2))
        let northEast = NCLocation(latitude: cameraBoundary.region.center.latitude + (cameraBoundary.region.span.latitudeDelta / 2),
                                   longitude: cameraBoundary.region.center.longitude + (cameraBoundary.region.span.longitudeDelta / 2))

        if (currentUserLatitude < southWest.latitude) || (northEast.latitude < currentUserLatitude) || (currentUserLongitude < southWest.longitude) || (northEast.longitude < currentUserLongitude) {
            // self.followUserLocation()
        }
    }
}
