//
//  ChatRoomListViewModel.swift
//  NearTalk
//
//  Created by yw22 on 2022/11/11.
//

import Foundation
import RxRelay
import RxSwift

struct ChatRoomListViewModelActions {
    let showChatRoom: () -> Void
    let showCreateChatRoom: () -> Void
}

protocol ChatRoomListViewModelInput {
}

protocol ChatRoomListViewModelOutput {
}

protocol ChatRoomListViewModel: ChatRoomListViewModelInput, ChatRoomListViewModelOutput {}

final class DefaultChatRoomListViewModel: ChatRoomListViewModel {
    
    private let chatRoomListUseCase: ChatRoomListUseCase
    private let actions: ChatRoomListViewModelActions?
    
    var openChatRoomDummyData: [OpenChatRoomListData] = []
    var dmChatRoomDummyData: [DMChatRoomListData] = []
    
    init(useCase: ChatRoomListUseCase, actions: ChatRoomListViewModelActions? = nil) {
        self.chatRoomListUseCase = useCase
        self.actions = actions
        
        createDummyData()
    }

    func createDummyData() {
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "Ronald Robertson", description: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.", date: "오후 2:30", count: "12"))
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "Johnny Watson", description: "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis", date: "오후 1:01", count: "24"))
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "Annette Cooper", description: "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.", date: "오후 12:57", count: "122"))
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "Arthur Bell", description: "Voluptate irure aliquip consectetur commodo ex ex.", date: "오전 9:43", count: "5"))
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "Jane Warren", description: "Ex Lorem veniam veniam irure sunt adipisicing culpa.", date: "오전 1:10", count: "6"))
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "Morris Henry", description: "Dolore veniam Lorem occaecat veniam irure laborum est amet.", date: "어제", count: "20"))
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "Irma Flores", description: "Amet enim do laborum tempor nisi aliqua ad adipisicing.", date: "어제", count: "1200"))
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "008", description: "qwer", date: "어제", count: "954"))
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "009", description: "asdf", date: "어제", count: "33"))
        openChatRoomDummyData.append(OpenChatRoomListData(img: "", name: "010", description: "zxcv", date: "어제", count: "11"))
        
        dmChatRoomDummyData.append(DMChatRoomListData(img: "", name: "dm Ronald Robertson", description: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.", date: "오후 1:33"))
        dmChatRoomDummyData.append(DMChatRoomListData(img: "", name: "dm Johnny Watson", description: "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis", date: "오후 12:23"))
        dmChatRoomDummyData.append(DMChatRoomListData(img: "", name: "dm Annette Cooper", description: "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.", date: "오전 5:12"))
        dmChatRoomDummyData.append(DMChatRoomListData(img: "", name: "dm Arthur Bell", description: "Voluptate irure aliquip consectetur commodo ex ex.", date: "오전 9:43"))
        dmChatRoomDummyData.append(DMChatRoomListData(img: "", name: "dm Jane Warren", description: "Ex Lorem veniam veniam irure sunt adipisicing culpa.", date: "오전 1:10"))
    }
}
