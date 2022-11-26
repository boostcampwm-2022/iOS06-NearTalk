//
//  CreateGroupChatViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import Foundation

import RxCocoa
import RxSwift

struct CreateGroupChatViewModelActions {
    let showChatViewController: () -> Void
}

protocol CreateGroupChatViewModelInput {
    func titleDidEdited(_ title: String)
    func descriptionDidEdited(_ descriptio: String)
    func maxParticipantDidChanged(_ numOfParticipant: Int)
    func maxRangeDidChanged(_ range: Int)
    func createChatButtonDIdTapped()
}

protocol CreateGroupChatViewModelOutput {
    var maxRangeLabel: Driver<String> { get }
    var createChatButtonIsEnabled: Driver<Bool> { get }
}

protocol CreateGroupChatViewModel: CreateGroupChatViewModelInput, CreateGroupChatViewModelOutput {
}

final class DefaultCreateGroupChatViewModel: CreateGroupChatViewModel {
    var maxRangeLabel: Driver<String>
    var createChatButtonIsEnabled: Driver<Bool>

    // MARK: - Proporties
//    private let createGroupChatUseCase: CreateGroupChatUseCaseable
//    private let actions: CreateGroupChatViewModelActions
    private let disposeBag = DisposeBag()
    
    init() {
//        self.createGroupChatUseCase = createGroupChatUseCase
//        self.actions = actions
                
        self.createChatButtonIsEnabled = Observable
            .combineLatest(title, description)
            .map {
                !$0.0.isEmpty && !$0.1.isEmpty
            }
            .asDriver(onErrorRecover: { _ in .empty() })
        
        self.maxRangeLabel = self.maxRange
            .map({"\($0)km"})
            .asDriver(onErrorRecover: { _ in .empty() })
    }
    
    // MARK: - Inputs
    
    private var title = PublishSubject<String>()
    func titleDidEdited(_ title: String) {
        self.title.onNext(title)
    }
    
    private var description = PublishSubject<String>()
    func descriptionDidEdited(_ description: String) {
        self.description.onNext(description)
    }
    
    private var maxParticipant = PublishSubject<Int>()
    func maxParticipantDidChanged(_ numOfParticipant: Int) {
        self.maxParticipant.onNext(numOfParticipant)
    }
    
    private var maxRange = PublishSubject<Int>()
    func maxRangeDidChanged(_ range: Int) {
        self.maxRange.onNext(range)
    }
    
    func createChatButtonDIdTapped() {
        print(#function)
    }
}
