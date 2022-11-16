//
//  MainMapViewController.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/14.
//

import CoreLocation
import MapKit
import SnapKit
import Then
import UIKit

final class MainMapViewController: UIViewController {
    
    // MARK: - Properties
    private let locationManager = CLLocationManager().then {
        $0.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private var userLocation: CLLocation?
    // private let naverLocation = CLLocation(latitude: 37.3589, longitude: 127.1051)
    
    // MARK: - UI Components
    private var mapView = MKMapView().then {
        $0.showsUserLocation = true
        $0.setUserTrackingMode(.follow, animated: true)
    }
    
    private let moveToCurrentLocationButton: UIButton = UIButton().then {
        $0.setBackgroundImage(UIImage(systemName: "location.circle"), for: .normal)
        $0.tintColor = .systemBlue
        $0.addTarget(
            MainMapViewController.self,
            action: #selector(moveToCurrentLocation),
            for: .touchUpInside
        )
    }
    
    private let createChatRoomButton: UIButton = UIButton().then {
        $0.setBackgroundImage(UIImage(systemName: "pencil.circle"), for: .normal)
        $0.tintColor = .systemBlue
        $0.addTarget(
            MainMapViewController.self,
            action: #selector(createChatRoom),
            for: .touchUpInside
        )
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubViews()
        configureConstraints()
        configureDelegates()
        registerAnnotationViewClass()
        loadDataForMapView()
    }
    
    // MARK: - Methods
    private func addSubViews() {
        view.addSubview(self.mapView)
        
        self.mapView.addSubview(self.moveToCurrentLocationButton)
        self.mapView.addSubview(self.createChatRoomButton)
    }
    
    private func configureConstraints() {
        self.mapView.snp.makeConstraints {
            $0.width.equalTo(self.view)
            $0.height.equalTo(self.view)
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
    
    private func loadDataForMapView() {
        // 디버깅용
        struct ChatRoomData: Decodable {
            let chatRoomAnnotations: [ChatRoomAnnotation]

            let centerLatitude: CLLocationDegrees
            let centerLongitude: CLLocationDegrees
            let latitudeDelta: CLLocationDegrees
            let longitudeDelta: CLLocationDegrees

            var region: MKCoordinateRegion {
                let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
                let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
                return MKCoordinateRegion(center: center, span: span)
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
        // Single: Open or Dm
        self.mapView.register(GroupChatRoomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        self.mapView.register(DmChatRoomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        // Clustering
        self.mapView.register(ChatRoomClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    @objc
    func moveToCurrentLocation(sender: UIButton) {
        if let currentLocation = self.locationManager.location {
            self.mapView.move(to: currentLocation)
        }
    }
    
    // 추후에 채팅 방 생성 로직 추가
    @objc
    func createChatRoom() {
        print("ChatRoom 생성")
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
    
    private func setCameraZoomRange(minDistance: CLLocationDistance = 1000, maxDistance: CLLocationDistance = 10000) {
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
            return GroupChatRoomAnnotationView(annotation: chatRoomAnnotation, reuseIdentifier: GroupChatRoomAnnotationView.reuseIdentifier)
        case .directMessage:
            return DmChatRoomAnnotationView(annotation: chatRoomAnnotation, reuseIdentifier: DmChatRoomAnnotationView.reuseIdentifier)
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
            self.userLocation = manager.location
        case .restricted, .denied:
            // showRequestLocationServiceAlert()
            manager.requestWhenInUseAuthorization()
        @unknown default:
            return
        }
    }
    
    // 권한 요청 관련 추가 메서드
//    private func showRequestLocationServiceAlert() {
//        let requestLocationServiceAlert = UIAlertController(
//            title: "위치정보 이용",
//            message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.",
//            preferredStyle: .alert
//        )
//
//        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
//            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(appSetting)
//            }
//        }
//
//        let cancel = UIAlertAction(title: "취소", style: .default)
//
//        requestLocationServiceAlert.addAction(cancel)
//        requestLocationServiceAlert.addAction(goSetting)
//
//        present(requestLocationServiceAlert, animated: true, completion: nil)
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.mapView.move(to: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
    }
}
