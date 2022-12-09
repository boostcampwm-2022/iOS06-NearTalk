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
    
    // MARK: - Dependencies
    struct Actions {
        let showCreateChatRoomView: () -> Void
    }
    
    struct UseCases {
        let fetchAccessibleChatRoomsUseCase: FetchAccessibleChatRoomsUseCase
    }
    
    struct Input {
        let mapViewDidAppear: Observable<NCMapRegion>
        let didTapMoveToCurrentLocationButton: Observable<Void>
        let didTapCreateChatRoomButton: Observable<Void>
        let didTapAnnotationView: Observable<MKAnnotation>
        let didUpdateUserLocation: Observable<NCLocation>
    }
    
    struct Output {
        let moveToCurrentLocationEvent: BehaviorRelay<Bool> = .init(value: false)
        let showCreateChatRoomViewEvent: BehaviorRelay<Bool> = .init(value: false)
        let showAccessibleChatRooms: PublishRelay<[ChatRoom]> = .init()
        let showAnnotationChatRooms: PublishRelay<[ChatRoom]> = .init()
        let currentUserLocation: BehaviorRelay<NCLocation> = .init(value: NCLocation.naver)
    }
    
    // MARK: - Properties
    let actions: Actions
    let useCases: UseCases
    let disposeBag: DisposeBag = .init()
    
    init(actions: Actions, useCases: UseCases) {
        self.actions = actions
        self.useCases = useCases
    }
    
    // MARK: - VC Binding
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.mapViewDidAppear
            .flatMap { region in
                let chatRooms = self.useCases.fetchAccessibleChatRoomsUseCase.fetchAccessibleAllChatRooms(in: region)
                return chatRooms
            }
            .bind(onNext: { output.showAccessibleChatRooms.accept($0) })
            .disposed(by: self.disposeBag)
        
        input.didTapMoveToCurrentLocationButton
            .map { true }
            .bind(to: output.moveToCurrentLocationEvent)
            .disposed(by: self.disposeBag)
        
        input.didTapCreateChatRoomButton
            .map { true }
            .bind(to: output.showCreateChatRoomViewEvent)
            .disposed(by: self.disposeBag)
        
        input.didTapAnnotationView
            .compactMap { annotation in
                if annotation is MKClusterAnnotation {
                    guard let clusterAnnotation = annotation as? MKClusterAnnotation
                    else { return [] }
                    
                    return clusterAnnotation.memberAnnotations.compactMap {
                        guard let chatRoomAnnotation = $0 as? ChatRoomAnnotation
                        else { return nil }
                        
                        return chatRoomAnnotation.chatRoomInfo
                    }
                }
                
                guard let singleChatRoomAnnotation = annotation as? ChatRoomAnnotation
                else { return [] }
                
                return [singleChatRoomAnnotation.chatRoomInfo]
            }
            .bind(onNext: { output.showAnnotationChatRooms.accept($0) })
            .disposed(by: self.disposeBag)
        
        input.didUpdateUserLocation
            .bind(to: output.currentUserLocation)
            .disposed(by: self.disposeBag)
        
        return output
    }
}
