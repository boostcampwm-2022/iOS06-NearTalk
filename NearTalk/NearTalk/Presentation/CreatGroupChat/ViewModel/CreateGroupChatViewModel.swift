//
//  CreateGroupChatViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import Foundation

import RxRelay
import RxSwift

protocol CreateGroupChatUseCaseable {
    func validate(_ string: String)
    func createGroupChat(title: String, description: String, maxNumOfParticipants: Int, maxRangeOfRadius: Int)
}

protocol CreateGroupChatCoordinatable: Coordinator {
    func showChatViewController()
}

protocol ViewModelable {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input, disposbag: DisposeBag) -> Output
}

final class CreateGroupChatViewModel {
    // MARK: - Proporties
    
    private let createGroupChatUseCase: CreateGroupChatUseCaseable
    private let coordinator: CreateGroupChatCoordinatable
    
    init(createGroupChatUseCase: CreateGroupChatUseCaseable, coordinator: CreateGroupChatCoordinatable) {
        self.createGroupChatUseCase = createGroupChatUseCase
        self.coordinator = coordinator
    }
}

extension CreateGroupChatViewModel: ViewModelable {
    // TODO: - input 항목 수정 필요
    struct Input {
        let titleTextFieldDidEditEvent: Observable<Void>
        let descriptionTextFieldDidEditEvent: Observable<Void>
        let maxNumOfParticipantsPickerSelected: Observable<Int>
        let maxRangeOfRadiusSliderEvent: Observable<Void>
        let maxRangeOfRadiusSliderSelected: Observable<Int>
        let createChatButtonDidTapEvent: Observable<Void>
    }
    
    struct Output {
        var maxRangeOfRadius = BehaviorRelay<Int>(value: 1)
        var createChatButtonIsEnable = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input, disposbag: DisposeBag) -> Output {
        let output = Output()
        
        input.maxRangeOfRadiusSliderSelected
            .bind(to: output.maxRangeOfRadius)
            .disposed(by: disposbag)
        
        input.createChatButtonDidTapEvent
            .subscribe { [weak self] _ in
                self?.coordinator.showChatViewController()
            }
            .disposed(by: disposbag)
    
        return output
    }
}
