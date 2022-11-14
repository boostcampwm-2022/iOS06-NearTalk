//
//  ChattingRoomListViewModel.swift
//  NearTalk
//
//  Created by yw22 on 2022/11/11.
//

import Foundation
import RxRelay
import RxSwift

class ChattingRoomListViewModel {
    
    var dummyData: [ChattingRoomListData] = []
    private let disposeBag = DisposeBag()
    private(set) var data = PublishRelay<[ChattingRoomListData]>()
    
    init() {
        createDummyData()
    }
    
    func createDummyData() {
        dummyData.append(ChattingRoomListData(img: "", name: "Ronald Robertson", description: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.", date: "오후 2:30", count: "12"))
        dummyData.append(ChattingRoomListData(img: "", name: "Johnny Watson", description: "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis", date: "오후 1:01", count: "24"))
        dummyData.append(ChattingRoomListData(img: "", name: "Annette Cooper", description: "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.", date: "오후 12:57", count: "122"))
        dummyData.append(ChattingRoomListData(img: "", name: "Arthur Bell", description: "Voluptate irure aliquip consectetur commodo ex ex.", date: "오전 9:43", count: "5"))
        dummyData.append(ChattingRoomListData(img: "", name: "Jane Warren", description: "Ex Lorem veniam veniam irure sunt adipisicing culpa.", date: "오전 1:10", count: "6"))
        dummyData.append(ChattingRoomListData(img: "", name: "Morris Henry", description: "Dolore veniam Lorem occaecat veniam irure laborum est amet.", date: "어제", count: "20"))
        dummyData.append(ChattingRoomListData(img: "", name: "Irma Flores", description: "Amet enim do laborum tempor nisi aliqua ad adipisicing.", date: "어제", count: "1200"))
        dummyData.append(ChattingRoomListData(img: "", name: "008", description: "qwer", date: "어제", count: "954"))
        dummyData.append(ChattingRoomListData(img: "", name: "009", description: "asdf", date: "어제", count: "33"))
        dummyData.append(ChattingRoomListData(img: "", name: "010", description: "zxcv", date: "어제", count: "11"))
    }
}
