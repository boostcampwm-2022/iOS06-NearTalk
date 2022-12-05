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
        $0.setUserTrackingMode(.follow, animated: true)
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
    private var viewModel: MainMapViewModel!
    private let disposeBag: DisposeBag = .init()
    private let locationManager: CLLocationManager = .init().then {
        $0.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - LifeCycles
    static func create(with viewModel: MainMapViewModel) -> MainMapViewController {
        let mainMapVC = MainMapViewController()
        mainMapVC.viewModel = viewModel
        
        return mainMapVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubViews()
        configureConstraints()
        configureDelegates()
        registerAnnotationViewClass()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.locationManagerDidChangeAuthorization(self.locationManager)
        
        if let userLocation = self.locationManager.location {
            self.mapView.move(to: userLocation)
        }
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
            didTapMoveToCurrentLocationButton: self.moveToCurrentLocationButton.rx.tap.asObservable(),
            didTapCreateChatRoomButton: self.createChatRoomButton.rx.tap.asObservable(),
            currentUserMapRegion: self.mapView.rx.region.map { region in
                let centerLocation: NCLocation = .init(longitude: region.center.longitude, latitude: region.center.latitude)
                let latitudeDelta: Double = region.span.latitudeDelta
                let longitudeDelta: Double = region.span.longitudeDelta
                
                return NCMapRegion(centerLocation: centerLocation,
                                   latitudeDelta: latitudeDelta,
                                   longitudeDelta: longitudeDelta)
            },
            didTapAnnotationView: self.mapView.rx.didSelectAnnotationView.compactMap { $0.annotation }
        )
        
        // MARK: - Bind VM output
        let output = self.viewModel.transform(input: input)
        output.moveToCurrentLocationEvent
            .asDriver(onErrorJustReturn: false)
            .filter { $0 == true }
            .drive(onNext: { [weak self] _ in
                self?.mapView.showsUserLocation = true
                self?.mapView.setUserTrackingMode(.follow, animated: true)
            })
            .disposed(by: self.disposeBag)
        
        output.showAccessibleChatRooms
            .map { chatRooms in
                chatRooms.compactMap { ChatRoomAnnotation.create(with: $0) }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { annotations in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
            })
            .disposed(by: self.disposeBag)
        
        output.showAnnotationChatRooms
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: {
                let bottomSheet = BottomSheetViewController()
                bottomSheet.loadData(with: $0)
                
                self.present(bottomSheet, animated: true)
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
}

// MARK: - Extensions
private extension MKMapView {
    func move(to location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )

        setCameraBoundary(region: coordinateRegion)
        setCameraZoomRange()

        self.setRegion(coordinateRegion, animated: true)
    }
    
    private func setCameraBoundary(region coordinateRegion: MKCoordinateRegion, meters regionMeters: CLLocationDistance = 10000) {
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: coordinateRegion)
        self.setCameraBoundary(cameraBoundary, animated: true)
    }
    
    private func setCameraZoomRange(minDistance: CLLocationDistance = 1, maxDistance: CLLocationDistance = 10000) {
        let zoomRange = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: minDistance,
            maxCenterCoordinateDistance: maxDistance
        )
        self.setCameraZoomRange(zoomRange, animated: true)
    }
}

extension MainMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let chatRoomAnnotation = annotation as? ChatRoomAnnotation else {
            return nil
        }
        
        switch chatRoomAnnotation.roomType {
        case .group:
            return GroupChatRoomAnnotationView(
                annotation: chatRoomAnnotation,
                reuseIdentifier: GroupChatRoomAnnotationView.reuseIdentifier
            )
        case .directMessage:
            return DmChatRoomAnnotationView(
                annotation: chatRoomAnnotation,
                reuseIdentifier: DmChatRoomAnnotationView.reuseIdentifier
            )
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
        guard let currentUserLocation = locations.last
        else { return }
        
        let currentUserLatitude = Double(currentUserLocation.coordinate.latitude)
        let currentUserLongitude = Double(currentUserLocation.coordinate.longitude)
        
        UserDefaults.standard.set(["latitude": currentUserLatitude, "longitude": currentUserLongitude], forKey: "CurrentUserLocation")
        
        guard let cameraBoundary = self.mapView.cameraBoundary
        else { return }
        
        let southWest = NCLocation(longitude: cameraBoundary.region.center.longitude - (cameraBoundary.region.span.longitudeDelta / 2),
                                   latitude: cameraBoundary.region.center.latitude - (cameraBoundary.region.span.latitudeDelta / 2))
        let northEast = NCLocation(longitude: cameraBoundary.region.center.longitude + (cameraBoundary.region.span.longitudeDelta / 2),
                                   latitude: cameraBoundary.region.center.latitude + (cameraBoundary.region.span.latitudeDelta / 2))

        if (currentUserLatitude < southWest.latitude) || (northEast.latitude < currentUserLatitude) || (currentUserLongitude < southWest.longitude) || (northEast.longitude < currentUserLongitude) {
            self.mapView.move(to: currentUserLocation)
        }
    }
}
