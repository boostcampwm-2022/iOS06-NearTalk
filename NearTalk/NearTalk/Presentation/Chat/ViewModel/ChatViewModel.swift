//
//  ChatViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import Foundation

import RxSwift

protocol ChatViewModelInput {
    var tapSendMessageButton: Single<Void> { get }
    var message: Single<Void> { get }
}

protocol ChatViewModelOut {
    var newMessage: Single<Void> { get }
}

protocol ChatViewModel: ChatViewModelInput, ChatViewModelOut {
    
}

//class DefaultChatViewModel: ChatViewModel {
//    var newMessage: RxSwift.Single<Void>
//    
//    var tapSendMessageButton: RxSwift.Single<Void>
//    
//    var message: RxSwift.Single<Void>
//    
//    
//
//}
