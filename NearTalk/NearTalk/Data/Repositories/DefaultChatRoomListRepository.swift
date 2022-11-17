//
//  ChatRoomListRepository.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxSwift

final class DefaultChatRoomListRepository {
    
    private let dataTransferService: StorageService
    private(set) var dummyData: ChatRoomDummyData = ChatRoomDummyData()
    
    init(dataTransferService: StorageService) {
        self.dataTransferService = dataTransferService
    }
}

extension DefaultChatRoomListRepository: ChatRoomListRepository {
    
    func fetchChatRoomList() -> Observable<[ChatRoom]> {
        return Observable<[ChatRoom]>.create { observer in
            observer.onNext(self.dummyData.chatRoomData)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func fetchUserChatRoomModel() -> Observable<[UserChatRoomModel]> {
        return Observable<[UserChatRoomModel]>.create { observer in
            observer.onNext(self.dummyData.userChatRoomData)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
}

struct ChatRoomDummyData {
    var chatRoomData: [ChatRoom] = []
    var userChatRoomData: [UserChatRoomModel] = []
    
    init() {
        chatRoomData.append(ChatRoom(roomID: "1", userList: ["s001", "s002", "s003", "s004", "s005"], roomType: "open", roomName: "네이버", roomDescription: "aaaaaaaaaaaaaaaaaa"))
        chatRoomData.append(ChatRoom(roomID: "2", userList: ["s001", "s002", "s003", "s005"], roomType: "open", roomName: "다음", roomDescription: "bbbbbbbbbbbbbbbbbbbbbbbb"))
        chatRoomData.append(ChatRoom(roomID: "3", userList: ["s001", "s002", "s003", "s004", "s005"], roomType: "open", roomName: "카카오", roomDescription: "cccccccccccccccccccccccccccccc"))
        chatRoomData.append(ChatRoom(roomID: "4", userList: ["s001", "s004", "s005"], roomType: "open", roomName: "넷마블", roomDescription: "ddddddddddddddddddddd"))
        chatRoomData.append(ChatRoom(roomID: "5", userList: ["s001", "s002", "s003", "s004", "s005", "s011", "s013", "s014", "s015"], roomType: "open", roomName: "넥슨", roomDescription: "eeeeeeeeeeeeeeeeeeee"))
        chatRoomData.append(ChatRoom(roomID: "6", userList: ["s001", "s009", "s007", "s014", "s021"], roomType: "open", roomName: "엔씨", roomDescription: "ffffffffffffffffffffffff"))
        chatRoomData.append(ChatRoom(roomID: "7", userList: ["s011", "s017"], roomType: "open", roomName: "구글", roomDescription: "gggggggggggggggggggggggg"))
        chatRoomData.append(ChatRoom(roomID: "8", userList: ["s001", "s002"], roomType: "dm", roomName: "아마존", roomDescription: "hhhhhhhhhhhhhhhhhhhhhh"))
        chatRoomData.append(ChatRoom(roomID: "9", userList: ["s001", "s002"], roomType: "dm", roomName: "페이스북", roomDescription: "iiiiiiiiiiiiiiiiiiiiiiiiiiii"))
        chatRoomData.append(ChatRoom(roomID: "10", userList: ["s001", "s002"], roomType: "dm", roomName: "Meta", roomDescription: "jjjjjjjjjjjjjjjjjjjjjjjj"))
        chatRoomData.append(ChatRoom(roomID: "11", userList: ["s001", "s002"], roomType: "dm", roomName: "인스타그램", roomDescription: "kkkkkkkkkkkkkkkkkkkkkk"))
        
        userChatRoomData.append(UserChatRoomModel(userID: "s001", chatRoomID: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]))
    }
}
