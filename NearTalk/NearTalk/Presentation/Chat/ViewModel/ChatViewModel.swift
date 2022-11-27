//
//  ChatViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import Foundation

import RxSwift

protocol ChatViewModelInput {
    func sendMessage(_ message: String)
}

protocol ChatViewModelOut {
}

protocol ChatViewModel: ChatViewModelInput, ChatViewModelOut {
}

class DefaultChatViewModel: ChatViewModel {
    private var messagingUseCase: MessagingUseCase
    
    init(messagingUseCase: MessagingUseCase) {
        self.messagingUseCase = messagingUseCase
    }
    
    func sendMessage(_ message: String) {
        print(#function, message)
    }
}
