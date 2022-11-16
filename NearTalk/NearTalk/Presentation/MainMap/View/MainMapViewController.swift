//
//  MainMapViewController.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/14.
//

import CoreLocation
import MapKit
import UIKit

final class MainMapViewController: UIViewController {
    private var mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    
    // private let naverLocation = CLLocation(latitude: 37.3589, longitude: 127.1051)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapView()
        setLocationManager()
        setMoveToCurrentLocationButton()
        setCreateChatRoomButton()
        registerAnnotationViewClass()
    }
    
    private func loadDataForMapView() {
//        guard let dummyDataURL = Bundle.main.url() else {
//
//        }
    }
    
    private func setMapView() {
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
    }
    
    private func setLocationManager() {
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setMoveToCurrentLocationButton() {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "location.circle"), for: .normal)
        button.tintColor = .systemBlue
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        button.addTarget(self, action: #selector(moveToCurrentLocation), for: .touchUpInside)
    }
    
    @objc func moveToCurrentLocation(sender: UIButton) {
        if let currentLocation = locationManager.location {
            mapView.move(to: currentLocation)
        }
    }
    
    private func setCreateChatRoomButton() {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "pencil.circle"), for: .normal)
        button.tintColor = .systemBlue
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 140).isActive = true
        button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        button.addTarget(self, action: #selector(createChatRoom), for: .touchUpInside)
    }
    // 추후에 채팅 방 생성 로직 추가
    @objc func createChatRoom() {
        print("ChatRoom 생성")
    }
    
    private func registerAnnotationViewClass() {
        // Single: Open or Dm
        mapView.register(GroupChatRoomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(DmChatRoomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        // Clustering
        mapView.register(ChatRoomClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
}

extension MKMapView {
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
        case .dm:
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
            userLocation = manager.location
        case .restricted, .denied:
            // showRequestLocationServiceAlert()
            manager.requestWhenInUseAuthorization()
        @unknown default:
            return
        }
    }
    
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
            mapView.move(to: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
    }
}
