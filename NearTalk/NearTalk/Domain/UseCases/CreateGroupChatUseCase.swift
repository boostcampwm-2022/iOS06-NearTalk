//
//  CreateGroupChatUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import Foundation

final class CreateGroupChatUseCase {
    // MARK: - Proporties
    
//    private let firestoreRepository: FirestoreRepository
    
    // TODO: - repository 주입
    init() {
        print(#function)
    }
}

extension CreateGroupChatUseCase: CreateGroupChatUseCaseable {
    func validate(_ string: String) {
        print(#function)
    }
    
    func createGroupChat(title: String, description: String, maxNumOfParticipants: Int, maxRangeOfRadius: Int) {
        print(#function)
    }
}
