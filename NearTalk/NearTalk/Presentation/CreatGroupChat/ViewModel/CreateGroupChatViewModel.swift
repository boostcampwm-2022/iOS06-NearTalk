//
//  CreateGroupChatViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import Foundation

import RxCocoa
import RxSwift

struct CreateGroupChatViewModelActions {
    let showChatViewController: (String) -> Void
}

protocol CreateGroupChatViewModelInput {
    func titleDidEdited(_ title: String)
    func descriptionDidEdited(_ descriptio: String)
    func maxParticipantDidChanged(_ numOfParticipant: Int)
    func maxRangeDidChanged(_ range: Int)
    func createChatButtonDIdTapped()
}

protocol CreateGroupChatViewModelOutput {
    var maxRangeLabel: Driver<String> { get }
    var createChatButtonIsEnabled: Driver<Bool> { get }
}

protocol CreateGroupChatViewModel: CreateGroupChatViewModelInput, CreateGroupChatViewModelOutput {
}

final class DefaultCreateGroupChatViewModel: CreateGroupChatViewModel {
    var maxRangeLabel: Driver<String>
    var createChatButtonIsEnabled: Driver<Bool>

    // MARK: - Proporties
    private let createGroupChatUseCase: CreateGroupChatUseCaseable
    private let userDefaultUseCase: UserDefaultUseCase
    private let actions: CreateGroupChatViewModelActions
    private let disposeBag = DisposeBag()
    
    init(createGroupChatUseCase: CreateGroupChatUseCaseable,
         userDefaultUseCase: UserDefaultUseCase,
         actions: CreateGroupChatViewModelActions
    ) {
        self.createGroupChatUseCase = createGroupChatUseCase
        self.userDefaultUseCase = userDefaultUseCase
        self.actions = actions
                
        self.createChatButtonIsEnabled = Observable
            .combineLatest(titlePublishSubject, descriptionPublishSubject)
            .map {
                !$0.0.isEmpty && !$0.1.isEmpty
            }
            .asDriver(onErrorRecover: { _ in .empty() })
        
        self.maxRangeLabel = self.maxRangePublishSubject
            .map({"\($0)km"})
            .asDriver(onErrorRecover: { _ in .empty() })
    }
    
    // MARK: - Inputs
    
    private var title: String = ""
    private var titlePublishSubject = PublishSubject<String>()
    func titleDidEdited(_ title: String) {
        self.title = title
        self.titlePublishSubject.onNext(title)
    }
    
    private var description: String = ""
    private var descriptionPublishSubject = PublishSubject<String>()
    func descriptionDidEdited(_ description: String) {
        self.description = description
        self.descriptionPublishSubject.onNext(description)
    }
    
    private var maxParticipant: Int = 10
    func maxParticipantDidChanged(_ numOfParticipant: Int) {
        self.maxParticipant = numOfParticipant
        print(numOfParticipant)
    }
    
    private var maxRange: Int = 0
    private var maxRangePublishSubject = PublishSubject<Int>()
    func maxRangeDidChanged(_ range: Int) {
        self.maxRange = range
        self.maxRangePublishSubject.onNext(range)
    }
    
    func createChatButtonDIdTapped() {
        // TODO: - ChatRoom 내부 수정 필요
        guard let userUUID = userDefaultUseCase.fetchUserUUID() else {
            return
        }
        
        let chatRoomUUID = UUID().uuidString
        let chatRoom = ChatRoom(
            uuid: chatRoomUUID,
            userList: [userUUID], // 임시 ID - userdefault에 저장된 값 사용 예정
            roomImagePath: nil,
            roomType: "group",
            roomName: self.title,
            roomDescription: self.description,
            location: NCLocation(latitude: 37.3596093566472, longitude: 127.1056219310272), // 임시 위치
            latitude: 37.3596093566472,
            longitude: 127.1056219310272,
            accessibleRadius: Double(self.maxRange),
            recentMessageID: nil,
            maxNumberOfParticipants: self.maxParticipant,
            messageCount: 0
        )
        print(#function, chatRoom, self.title)
        self.createGroupChatUseCase.createGroupChat(chatRoom: chatRoom)
            .subscribe(onCompleted: { [weak self] in
                guard let chatRoomName = self?.title else {
                    return
                }
                print("onCompleted", chatRoomName)
                self?.createGroupChatUseCase.addChatRoom(chatRoomUUID: chatRoomUUID)
                    .subscribe(onCompleted: {
                        self?.actions.showChatViewController(chatRoomUUID)
                    })
            }, onError: { _ in
                print("onError")
            })
            .disposed(by: self.disposeBag)
    }
}
