//
//  MainMapViewModel.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/14.
//

import Foundation
import MapKit
import RxCocoa
import RxRelay
import RxSwift

final class MainMapViewModel {
    struct Actions {
        let showCreateChatRoomView: () -> Void
        let showBottomSheetView: () -> Void
    }
    
    struct UseCases {
        let fetchAccessibleChatRoomsUseCase: FetchAccessibleChatRoomsUseCase
    }
    
    struct Input {
        let mapViewDidAppear: Observable<MKMapView>
        let didUpdateUserLocation: Observable<MKMapView>
        let didSelectMainMapAnnotation: Observable<MKAnnotationView>
    }
    
    struct Output {
        let accessibleAllChatRooms: PublishRelay<[ChatRoom]> = .init()
        let annotationAllChatRooms: PublishRelay<[ChatRoom]> = .init()
    }
    
    let actions: Actions
    let useCases: UseCases
    let disposeBag: DisposeBag = .init()
    
    init(actions: Actions, useCases: UseCases) {
        self.actions = actions
        self.useCases = useCases
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.mapViewDidAppear
            .map { mapView in
                let centerLocation = NCLocation(longitude: mapView.userLocation.coordinate.longitude,
                                                latitude: mapView.userLocation.coordinate.latitude)
                let radiusDistanceMeters = Double(2000)
                let latitudinalMeters = mapView.region.span.latitudeDelta * NCLocation.decimalDegreePerMeter
                let longitudinalMeters = mapView.region.span.longitudeDelta * NCLocation.decimalDegreePerMeter
                
                return NCMapRegion(centerLocation: centerLocation,
                                   radiusDistanceMeters: radiusDistanceMeters,
                                   latitudinalMeters: latitudinalMeters,
                                   longitudinalMeters: longitudinalMeters)
            }
            .flatMap{ self.useCases.fetchAccessibleChatRoomsUseCase.fetchAccessibleAllChatRooms(in: $0) }
            .bind(to: output.accessibleAllChatRooms)
            .disposed(by: self.disposeBag)
        
        input.didUpdateUserLocation
            .map { mapView in
                let centerLocation = NCLocation(longitude: mapView.userLocation.coordinate.longitude,
                                                latitude: mapView.userLocation.coordinate.latitude)
                let radiusDistanceMeters = Double(2000)
                let latitudinalMeters = mapView.region.span.latitudeDelta * NCLocation.decimalDegreePerMeter
                let longitudinalMeters = mapView.region.span.longitudeDelta * NCLocation.decimalDegreePerMeter
                
                return NCMapRegion(centerLocation: centerLocation,
                                   radiusDistanceMeters: radiusDistanceMeters,
                                   latitudinalMeters: latitudinalMeters,
                                   longitudinalMeters: longitudinalMeters)
            }
            .flatMap{ self.useCases.fetchAccessibleChatRoomsUseCase.fetchAccessibleAllChatRooms(in: $0) }
            .bind(to: output.accessibleAllChatRooms)
            .disposed(by: self.disposeBag)
        
        return output
    }
}
