//
//  ChattingRoomListViewModel.swift
//  NearTalk
//
//  Created by yw22 on 2022/11/11.
//

import Foundation
import RxRelay
import RxSwift

final class ChattingRoomListViewModel {
    
    var openChattingRoomDummyData: [OpenChattingRoomListData] = []
    var dmChattingRoomDummyData: [DMChattingRoomListData] = []
    
    init() {
        createDummyData()
    }
    
    func createDummyData() {
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "Ronald Robertson", description: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.", date: "오후 2:30", count: "12"))
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "Johnny Watson", description: "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis", date: "오후 1:01", count: "24"))
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "Annette Cooper", description: "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.", date: "오후 12:57", count: "122"))
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "Arthur Bell", description: "Voluptate irure aliquip consectetur commodo ex ex.", date: "오전 9:43", count: "5"))
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "Jane Warren", description: "Ex Lorem veniam veniam irure sunt adipisicing culpa.", date: "오전 1:10", count: "6"))
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "Morris Henry", description: "Dolore veniam Lorem occaecat veniam irure laborum est amet.", date: "어제", count: "20"))
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "Irma Flores", description: "Amet enim do laborum tempor nisi aliqua ad adipisicing.", date: "어제", count: "1200"))
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "008", description: "qwer", date: "어제", count: "954"))
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "009", description: "asdf", date: "어제", count: "33"))
        openChattingRoomDummyData.append(OpenChattingRoomListData(img: "", name: "010", description: "zxcv", date: "어제", count: "11"))
        
        dmChattingRoomDummyData.append(DMChattingRoomListData(img: "", name: "dm Ronald Robertson", description: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.", date: "오후 1:33"))
        dmChattingRoomDummyData.append(DMChattingRoomListData(img: "", name: "dm Johnny Watson", description: "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis", date: "오후 12:23"))
        dmChattingRoomDummyData.append(DMChattingRoomListData(img: "", name: "dm Annette Cooper", description: "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.", date: "오전 5:12"))
        dmChattingRoomDummyData.append(DMChattingRoomListData(img: "", name: "dm Arthur Bell", description: "Voluptate irure aliquip consectetur commodo ex ex.", date: "오전 9:43"))
        dmChattingRoomDummyData.append(DMChattingRoomListData(img: "", name: "dm Jane Warren", description: "Ex Lorem veniam veniam irure sunt adipisicing culpa.", date: "오전 1:10"))
        
    }
}
