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
    let showChatViewController: (String, String, [String]) -> Void
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
    private let actions: CreateGroupChatViewModelActions
    private let disposeBag = DisposeBag()
    
    init(createGroupChatUseCase: CreateGroupChatUseCaseable,
         actions: CreateGroupChatViewModelActions
    ) {
        self.createGroupChatUseCase = createGroupChatUseCase
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
        
        let chatRoomUUID = UUID().uuidString
        let chatRoom = ChatRoom(
            uuid: chatRoomUUID,
            userList: [], // 본인 uuid 추가 필요
            roomImagePath: nil,
            roomType: "group",
            roomName: self.title,
            roomDescription: self.description,
            location: nil,
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
                print("onCompleted")
                self?.actions.showChatViewController(chatRoomUUID, chatRoomName, chatRoom.userList ?? [])
            }, onError: { [weak self] _ in
                print("onError")
            })
            .disposed(by: self.disposeBag)
    }
}
