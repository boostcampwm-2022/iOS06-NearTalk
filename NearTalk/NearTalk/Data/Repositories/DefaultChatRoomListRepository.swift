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
        chatRoomData.append(ChatRoom(roomID: "1", userList: ["s001", "s002", "s003", "s004", "s005"], roomType: "open", roomName: "네이버", roomDescription: "술기운이 올라오니"))
        chatRoomData.append(ChatRoom(roomID: "2", userList: ["s001", "s002", "s003", "s005"], roomType: "open", roomName: "다음", roomDescription: "사내놈들끼린 결국엔 여자 얘기"))
        chatRoomData.append(ChatRoom(roomID: "3", userList: ["s001", "s002", "s003", "s004", "s005"], roomType: "open", roomName: "카카오", roomDescription: "적적해서 서로의 전화기를 꺼내"))
        chatRoomData.append(ChatRoom(roomID: "4", userList: ["s001", "s004", "s005"], roomType: "open", roomName: "넷마블", roomDescription: "번호목록을 뒤져보지"))
        chatRoomData.append(ChatRoom(roomID: "5", userList: ["s001", "s002", "s003", "s004", "s005", "s011", "s013", "s014", "s015"], roomType: "open", roomName: "넥슨", roomDescription: "너는 지금 뭐해 자니 밖이야?"))
        chatRoomData.append(ChatRoom(roomID: "6", userList: ["s001", "s009", "s007", "s014", "s021"], roomType: "open", roomName: "엔씨", roomDescription: "뜬금없는 문자를 돌려보지 난"))
        chatRoomData.append(ChatRoom(roomID: "7", userList: ["s001", "s017"], roomType: "open", roomName: "구글", roomDescription: "어떻게 해볼까란 뜻은 아니야"))
        chatRoomData.append(ChatRoom(roomID: "7", userList: ["s001", "s017", "s022"], roomType: "open", roomName: "아마존", roomDescription: "그냥 심심해서 그래 아니 외로워서 그래"))
        
        chatRoomData.append(ChatRoom(roomID: "8", userList: ["s001", "s002"], roomType: "dm", roomName: "라이언", roomDescription: "일 끝나서 친구들과 한잔"))
        chatRoomData.append(ChatRoom(roomID: "9", userList: ["s001", "s002"], roomType: "dm", roomName: "어피치", roomDescription: "내일은 노는 토요일이니깐"))
        chatRoomData.append(ChatRoom(roomID: "10", userList: ["s001", "s002"], roomType: "dm", roomName: "네오", roomDescription: "일 얘기 사는 얘기 재미난 얘기"))
        chatRoomData.append(ChatRoom(roomID: "11", userList: ["s001", "s002"], roomType: "dm", roomName: "튜브", roomDescription: "시간가는 줄 모르는 이 밤"))
        
        userChatRoomData.append(UserChatRoomModel(userID: "s001", chatRoomID: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]))
    }
}
