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
        let didTapMoveToCurrentLocationButton: Observable<Void>
        let didTapCreateChatRoomButton: Observable<Void>
        let currentUserMapRegion: Observable<NCMapRegion>
        let didTapAnnotationView: Observable<MKAnnotation>
    }
    
    struct Output {
        let moveToCurrentLocationEvent: BehaviorRelay<Bool> = .init(value: false)
        let showCreateChatRoomViewEvent: BehaviorRelay<Bool> = .init(value: false)
        let showAccessibleChatRooms: PublishRelay<[ChatRoom]> = .init()
        let showAnnotationChatRooms: PublishRelay<[ChatRoom]> = .init()
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
        input.didTapMoveToCurrentLocationButton
            .map { true }
            .bind(to: output.moveToCurrentLocationEvent)
            .disposed(by: self.disposeBag)
        
        input.didTapCreateChatRoomButton
            .map { true }
            .bind(to: output.showCreateChatRoomViewEvent)
            .disposed(by: self.disposeBag)
        
        input.currentUserMapRegion
            .flatMap { _ in
                let dummyChatRooms = self.useCases.fetchAccessibleChatRoomsUseCase.fetchDummyChatRooms()
                return dummyChatRooms
            }
            .bind(onNext: { output.showAccessibleChatRooms.accept($0) })
            .disposed(by: self.disposeBag)
        
        input.didTapAnnotationView
            .map {
                if $0 is MKClusterAnnotation {
                    let tmp1 = $0 as! MKClusterAnnotation
                    return tmp1.memberAnnotations.map {
                        let tmp2 = $0 as! ChatRoomAnnotation
                        return tmp2.chatRoomInfo
                    }
                } else {
                    let tmp3 = $0 as! ChatRoomAnnotation
                    return [tmp3.chatRoomInfo]
                }
            }
            .bind(onNext: { output.showAnnotationChatRooms.accept($0) })
            .disposed(by: self.disposeBag)
        
        return output
    }
}
