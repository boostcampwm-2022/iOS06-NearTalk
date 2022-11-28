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
    private lazy var mapView: MKMapView = .init().then {
        $0.showsUserLocation = true
        $0.setUserTrackingMode(.follow, animated: true)
    }
    private lazy var moveToCurrentLocationButton: UIButton = .init().then {
        $0.setBackgroundImage(UIImage(systemName: "location.circle"), for: .normal)
        $0.tintColor = .systemBlue
    }
    private lazy var createChatRoomButton: UIButton = .init().then {
        $0.setBackgroundImage(UIImage(systemName: "pencil.circle"), for: .normal)
        $0.tintColor = .systemBlue
    }
    private let bottomSheet: BottomSheetViewController = .init()

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
        // 디버깅 용
        loadDataForMapView()
        
        if let sheetController = self.presentationController as? UISheetPresentationController {
            sheetController.detents = [.medium(), .large()]
            sheetController.prefersGrabberVisible = true
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
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.moveToCurrentLocationButton.snp.makeConstraints {
            $0.top.equalTo(self.view).offset(100)
            $0.trailing.equalTo(self.view.snp.trailing)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
        }
        
        self.createChatRoomButton.snp.makeConstraints {
            $0.top.equalTo(self.moveToCurrentLocationButton.snp.bottom)
            $0.trailing.equalTo(self.view.snp.trailing)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
        }
    }
    
    private func configureDelegates() {
        self.mapView.delegate = self
        self.locationManager.delegate = self
    }
    
    private func bindViewModel() {
        self.moveToCurrentLocationButton.rx.tap
            .asObservable()
            .bind(onNext: { [weak self] _ in
                if let currentUserLocation = self?.mapView.userLocation.location {
                    self?.mapView.move(to: currentUserLocation)
                }
            })
            .disposed(by: self.disposeBag)
        
        let input = MainMapViewModel.Input(
            mapViewDidAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:))).map { _ in self.mapView }.asObservable(),
            didUpdateUserLocation: self.mapView.rx.didUpdateUserLocation.map { _ in self.mapView }.asObservable(),
            didSelectMainMapAnnotation: self.mapView.rx.didSelectAnnotationView.asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
    }
    
    private func loadDataForMapView() {
        // 디버깅 용
        struct ChatRoomData: Decodable {
            let chatRoomAnnotations: [ChatRoomAnnotation]

            let centerLatitude: CLLocationDegrees
            let centerLongitude: CLLocationDegrees
            let latitudeDelta: CLLocationDegrees
            let longitudeDelta: CLLocationDegrees

            var region: MKCoordinateRegion {
                let center = CLLocationCoordinate2D(
                    latitude: centerLatitude,
                    longitude: centerLongitude
                )
                let span = MKCoordinateSpan(
                    latitudeDelta: latitudeDelta,
                    longitudeDelta: longitudeDelta
                )
                
                return MKCoordinateRegion(
                    center: center,
                    span: span
                )
            }
        }
        
        guard let plistURL = Bundle.main.url(forResource: "DummyData", withExtension: "plist") else {
            fatalError("Failed to resolve URL for `Data.plist` in bundle.")
        }

        do {
            let plistData = try Data(contentsOf: plistURL)
            let decoder = PropertyListDecoder()
            let decodedData = try decoder.decode(ChatRoomData.self, from: plistData)
            self.mapView.region = decodedData.region
            self.mapView.addAnnotations(decodedData.chatRoomAnnotations)
        } catch {
            fatalError("Failed to load provided data, error: \(error.localizedDescription)")
        }
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.viewModel.actions.showBottomSheetView()
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
        if let location = locations.last {
            self.mapView.move(to: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
    }
}
