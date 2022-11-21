//
//  MainMapUseCase.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/21.
//

import Foundation

protocol MainMapUseCase {
    func execute()
}

final class FetchChatRoomsInfoUseCase: MainMapUseCase {
    
    private let mainMapRepository: MainMapRepository
    
    init(mainMapRepository: MainMapRepository) {
        self.mainMapRepository = mainMapRepository
    }
    
    func execute() {
         
    }
}

final class UploadChatRoomInfoUseCase: MainMapUseCase {
    
    private let mainMapRepository: MainMapRepository
    
    init(mainMapRepository: MainMapRepository) {
        self.mainMapRepository = mainMapRepository
    }
    
    func execute() {
        
    }
}
