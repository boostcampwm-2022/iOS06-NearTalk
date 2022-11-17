//
//  ChatRoomList.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation

struct GroupChatRoomListData: Hashable {
    var img: String?
    var name: String?
    var description: String?
    var date: String?
    var count: String?
    
    init(data: ChatRoom) {
        self.name = data.roomName
        self.description = data.roomDescription
        
        if let list = data.userList, !list.isEmpty {
            self.count = String(list.count)
        }
        
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        self.date = dateFormatter.string(from: now as Date)
    }
    
}

struct DMChatRoomListData: Hashable {
    var img: String?
    var name: String?
    var description: String?
    var date: String?
    
    init(data: ChatRoom) {
        self.name = data.roomName
        self.description = data.roomDescription
        
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        self.date = dateFormatter.string(from: now as Date)
    }
}
