//
//  MainMapViewController.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/14.
//

import CoreLocation
import Kingfisher
import MapKit
import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class MainMapViewController: UIViewController {
    
    // MARK: - UI Components
    private let mapView: MKMapView = .init().then {
        $0.showsUserLocation = true
        $0.showsCompass = false
    }
    private lazy var userLocationInfoView: UIStackView = .init().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 4
        $0.backgroundColor = .primaryColor
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    private let userProfileImage: UIImageView = .init().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "Logo")
    }
    private let userLocationLabel: UILabel = .init().then {
        $0.textColor = .label
        $0.textAlignment = .center
        $0.backgroundColor = .secondaryBackground
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private lazy var compassButton: MKCompassButton = .init(mapView: self.mapView)
    private let moveToCurrentLocationButton: UIButton = .init().then {
        guard let normalColor: UIColor = .primaryColor,
              let highlightedColor: UIColor = .secondaryColor
        else {
            return
        }
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
        let normalImage = UIImage(systemName: "location.circle")?
            .withTintColor(normalColor, renderingMode: .alwaysOriginal)
            .withConfiguration(imageConfig)
        let highlightImage = UIImage(systemName: "location.circle")?
            .withTintColor(highlightedColor, renderingMode: .alwaysOriginal)
            .withConfiguration(imageConfig)
        
        $0.setImage(normalImage, for: .normal)
        $0.setImage(highlightImage, for: .highlighted)
    }
    private let createChatRoomButton: UIButton = .init().then {
        guard let normalColor: UIColor = .primaryColor,
              let highlightedColor: UIColor = .secondaryColor
        else {
            return
        }
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
        let normalImage = UIImage(systemName: "message.badge.circle")?
            .withTintColor(normalColor, renderingMode: .alwaysOriginal)
            .withConfiguration(imageConfig)
        let highlightImage = UIImage(systemName: "message.badge.circle")?
            .withTintColor(highlightedColor, renderingMode: .alwaysOriginal)
            .withConfiguration(imageConfig)
        
        $0.setImage(normalImage, for: .normal)
        $0.setImage(highlightImage, for: .highlighted)
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
    
    override func viewWillAppear(_ animated: Bool) {
        if let profileImagePath = UserDefaults.standard.object(forKey: UserDefaultsKey.profileImagePath.string) as? String {
            self.fetch(path: profileImagePath)
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: - Methods
    private func addSubViews() {
        view.addSubview(self.mapView)
        
        self.userLocationInfoView.addArrangedSubview(self.userProfileImage)
        self.userLocationInfoView.addArrangedSubview(self.userLocationLabel)
        
        self.mapView.addSubview(self.userLocationInfoView)
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
        
        self.userLocationInfoView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(52)
            make.height.equalTo(36)
        }
        
        self.userProfileImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        self.userLocationLabel.snp.makeConstraints { make in
            make.width.equalTo(self.userLocationInfoView.snp.width).inset(24)
            make.height.equalTo(28)
        }

        self.compassButton.snp.makeConstraints { make in
            make.top.equalTo(self.userLocationInfoView.snp.bottom)
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
                    else {
                        return nil
                    }
                    
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
                    else {
                        return nil
                    }

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
                else {
                    return
                }

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
                self.updateUserDefaults(with: currentUserLocation)
                
                let currentUserCLLocation = CLLocation(latitude: currentUserLocation.latitude,
                                                       longitude: currentUserLocation.longitude)
                self.fetch(userLocation: currentUserCLLocation)
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
    
    private func updateUserDefaults(with currentUserLocation: NCLocation) {
        let currentUserLatitude = currentUserLocation.latitude
        let currentUserLongitude = currentUserLocation.longitude
        UserDefaults.standard.set(currentUserLatitude, forKey: UserDefaultsKey.currentUserLatitude.string)
        UserDefaults.standard.set(currentUserLongitude, forKey: UserDefaultsKey.currentUserLongitude.string)
    }
    
    private func fetch(path imagePath: String?) {
        guard let path = imagePath,
              let url = URL(string: path)
        else {
            return
        }

        self.userProfileImage.kf.setImage(with: url)
    }
    
    private func fetch(userLocation: CLLocation) {
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        geocoder.reverseGeocodeLocation(userLocation, preferredLocale: locale) { [weak self] (placeMarks, _) in
            guard let placeMarks = placeMarks,
                  let city = placeMarks.last?.locality,
                  let dong = placeMarks.last?.subLocality,
                  let name = placeMarks.last?.name
            else {
                return
            }
            
            self?.userLocationLabel.text = "\(city) \(dong) \(name)"
        }
    }
}

extension MainMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let userLocationView = MKUserLocationView(annotation: annotation, reuseIdentifier: nil)
            userLocationView.canShowCallout = false
            userLocationView.tintColor = .tertiaryColor

            return userLocationView
        }
        
        guard let chatRoomAnnotation = annotation as? ChatRoomAnnotation
        else {
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
