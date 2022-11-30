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
        let didTapChatRoomAnnotation: Observable<MKAnnotationView>
    }
    
    struct Output {
        let moveToCurrentLocationEvent: BehaviorRelay<Bool> = .init(value: false)
        let showCreateChatRoomViewEvent: BehaviorRelay<Bool> = .init(value: false)
        let accessibleChatRooms: PublishRelay<[ChatRoom]> = .init()
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
            .flatMap { self.useCases.fetchAccessibleChatRoomsUseCase.fetchAccessibleAllChatRooms(in: $0) }
            .subscribe(onNext: { output.accessibleChatRooms.accept($0) })
            .disposed(by: self.disposeBag)
        
        return output
    }
    
    private func fetchChatRooms(userLocation: NCLocation) {
        
    }
}
