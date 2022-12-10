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
    func descriptionDidEdited(_ description: String)
    func maxParticipantDidChanged(_ numOfParticipant: Int)
    func maxRangeDidChanged(_ range: Int)
    func createChatButtonDIdTapped()
    func setThumbnailImage(_ binary: Data?)
}

protocol CreateGroupChatViewModelOutput {
    var maxRangeLabel: Driver<String> { get }
    var createChatButtonIsEnabled: Driver<Bool> { get }
    var thumbnailImage: Driver<Data?> { get }
}

protocol CreateGroupChatViewModel: CreateGroupChatViewModelInput, CreateGroupChatViewModelOutput {
}

final class DefaultCreateGroupChatViewModel: CreateGroupChatViewModel {
    // MARK: - Proporties
    
    var thumbnailImage: RxCocoa.Driver<Data?> {
        self.imageBehaviorRelay.asDriver()
    }
    
    var maxRangeLabel: Driver<String>
    var createChatButtonIsEnabled: Driver<Bool>

    private let disposeBag = DisposeBag()
    
    private let createGroupChatUseCase: CreateGroupChatUseCase
    private let userDefaultUseCase: UserDefaultUseCase
    private let uploadImageUseCase: UploadImageUseCase
    private let actions: CreateGroupChatViewModelActions
    
    private var maxNumOfParticipant: Int = 50
    private var title: String = ""
    private var titlePublishSubject = PublishSubject<String>()
    private var description: String = ""
    private var descriptionPublishSubject = PublishSubject<String>()
    private var maxRange: Int = 0
    private var maxRangePublishSubject = PublishSubject<Int>()
    private let imageBehaviorRelay: BehaviorRelay<Data?> = BehaviorRelay(value: nil)
    
    init(createGroupChatUseCase: CreateGroupChatUseCase,
         userDefaultUseCase: UserDefaultUseCase,
         uploadImageUseCase: UploadImageUseCase,
         actions: CreateGroupChatViewModelActions
    ) {
        self.createGroupChatUseCase = createGroupChatUseCase
        self.userDefaultUseCase = userDefaultUseCase
        self.uploadImageUseCase = uploadImageUseCase
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

    func titleDidEdited(_ title: String) {
        self.title = title
        self.titlePublishSubject.onNext(title)
    }
    
    func descriptionDidEdited(_ description: String) {
        self.description = description
        self.descriptionPublishSubject.onNext(description)
    }
    
    func maxParticipantDidChanged(_ numOfParticipant: Int) {
        self.maxNumOfParticipant = numOfParticipant
    }
    
    func maxRangeDidChanged(_ range: Int) {
        self.maxRange = range
        self.maxRangePublishSubject.onNext(range)
    }
    
    func setThumbnailImage(_ binary: Data?) {
        self.imageBehaviorRelay.accept(binary)
    }

    func createChatButtonDIdTapped() {
        if let image = self.imageBehaviorRelay.value {
            self.uploadImageUseCase.execute(image: image)
                .subscribe(onSuccess: { [weak self] imagePath in
                    self?.createChatRoom(imagePath: imagePath)
                }, onFailure: { [weak self] _ in
                    self?.createChatRoom()
                })
                .disposed(by: self.disposeBag)
        } else {
            self.createChatRoom()
        }
    }
    
    private func createChatRoom(imagePath: String? = nil) {
        guard let userUUID = self.userDefaultUseCase.fetchUserUUID(),
              let currentUserLatitude = UserDefaults.standard.object(forKey: "CurrentUserLatitude") as? Double,
              let currentUserLongitude = UserDefaults.standard.object(forKey: "CurrentUserLongitude") as? Double,
              let randomLatitudeMeters = ((-500)...500).randomElement().map({Double($0)}),
              let randomLongitudeMeters = ((-500)...500).randomElement().map({Double($0)})
        else { return }
        
        let currentUserLocation = NCLocation(latitude: currentUserLatitude,
                                             longitude: currentUserLongitude)
        
        let randomChatRoomLocation = currentUserLocation.add(latitudeMeters: randomLongitudeMeters,
                                                     longitudeMeters: randomLatitudeMeters)
        
        let chatRoomUUID = UUID().uuidString
        let chatRoom = ChatRoom(
            uuid: chatRoomUUID,
            userList: [userUUID],
            roomImagePath: imagePath,
            roomType: "group",
            roomName: self.title,
            roomDescription: self.description,
            location: randomChatRoomLocation,
            latitude: randomChatRoomLocation.latitude,
            longitude: randomChatRoomLocation.longitude,
            accessibleRadius: Double(self.maxRange),
            recentMessageID: nil,
            recentMessageDateTimeStamp: Date().timeIntervalSince1970,
            maxNumberOfParticipants: self.maxNumOfParticipant,
            messageCount: 0
        )
        
        self.createGroupChatUseCase.createGroupChat(chatRoom: chatRoom)
            .subscribe(
                onCompleted: { [weak self] in
                    guard let self
                    else { return }
                    
                    self.createGroupChatUseCase
                        .addChatRoom(chatRoomUUID: chatRoomUUID)
                        .subscribe(onCompleted: { self.actions.showChatViewController(chatRoomUUID) })
                        .disposed(by: self.disposeBag)},
                onError: { error in
                    print("Error: ", error)
                })
            .disposed(by: self.disposeBag)
    }
}
