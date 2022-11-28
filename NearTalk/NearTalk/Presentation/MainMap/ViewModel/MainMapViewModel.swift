//
//  MainMapViewModel.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/14.
//

import Foundation
import RxCocoa
import RxSwift

// MARK: - Actions
struct MainMapViewModelActions {
    let showMainMapView: (NCLocation) -> Void
    let showBottomSheet: ([ChatRoom]) -> Void
    let showCreateChatRoomView: (NCLocation) -> Void
}

// MARK: - I/O Protocols
protocol MainMapViewModelInput {
    func viewDidLoad()
    func didMove(user location: NCLocation)
    func didMove(map location: NCLocation)
    func didSelect(with annotation: ChatRoomAnnotation)
    func didSelect(with segmentControlIndex: Int)
    func didTapMoveToCurrentLocationButton()
    func didTapCreateChatRoomButton()
}

protocol MainMapViewModelOutput {
    var userLocation: BehaviorRelay<NCLocation> { get set }
    var mapCenterLocation: BehaviorRelay<NCLocation> { get set }
    var chatRooms: BehaviorRelay<[ChatRoom]> { get set }
    var groupChatRooms: BehaviorRelay<[ChatRoom]> { get set }
    var dmChatRooms: BehaviorRelay<[ChatRoom]> { get set }
}

protocol MainMapViewModel: MainMapViewModelInput, MainMapViewModelOutput {}

final class DefaultMainMapViewModel: MainMapViewModel {
    
    private let useCases: MainMapUseCase
    private let actions: MainMapViewModelActions?
    
    // MARK: - Output
    var userLocation = BehaviorRelay<NCLocation>(value: NCLocation.defaultNCLocation)
    var mapCenterLocation = BehaviorRelay<NCLocation>(value: NCLocation.defaultNCLocation)
    var chatRooms = BehaviorRelay<[ChatRoom]>(value: [])
    var groupChatRooms = BehaviorRelay<[ChatRoom]>(value: [])
    var dmChatRooms = BehaviorRelay<[ChatRoom]>(value: [])
    
    // MARK: - Init
    init(useCases: MainMapUseCase, actions: MainMapViewModelActions? = nil) {
        self.useCases = useCases
        self.actions = actions
    }
    
    // MARK: - Private methods
    private func updateUserLocation(with userLocation: NCLocation) {
        // self.userLocation
    }
    
    private func updateMapCenterLocation(with mapCenterLocation: NCLocation) {
        // self.mapCenterLocation.onNext(mapCenterLocation)
    }
}

// MARK: - Input(View events)
extension DefaultMainMapViewModel {
    func viewDidLoad() { }
    
    func didMove(user location: NCLocation) {
        self.updateUserLocation(with: location)
    }
    
    func didMove(map location: NCLocation) {
        self.updateMapCenterLocation(with: location)
    }
    
    func didSelect(with annotation: ChatRoomAnnotation) {
        // self.actions?.showBottomSheet()
    }
    
    func didSelect(with segmentControlIndex: Int) {
        // self.actions?.showBottomSheet()
    }
    
    func didTapMoveToCurrentLocationButton() {
        // self.updateMapCenterLocation(with: self.userLocation)
    }
    
    func didTapCreateChatRoomButton() {
        // self.actions?.showCreateChatRoomView()
    }
}
