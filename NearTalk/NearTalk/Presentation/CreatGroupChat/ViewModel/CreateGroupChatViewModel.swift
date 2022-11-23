//
//  CreateGroupChatViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import Foundation

import RxRelay
import RxSwift

struct CreateGroupChatViewModelActions {
    let showChatViewController: () -> Void
}

protocol CreateGroupChatViewModelable {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

final class CreateGroupChatViewModel {
    // MARK: - Proporties
    private let createGroupChatUseCase: CreateGroupChatUseCaseable
    private let actions: CreateGroupChatViewModelActions
    private let disposeBag = DisposeBag()
    
    init(createGroupChatUseCase: CreateGroupChatUseCaseable, actions: CreateGroupChatViewModelActions) {
        self.createGroupChatUseCase = createGroupChatUseCase
        self.actions = actions
    }
}

extension CreateGroupChatViewModel: CreateGroupChatViewModelable {
    // TODO: - input 항목 수정 필요
    struct Input {
        let titleTextFieldDidEditEvent: Observable<Void>
        let descriptionTextFieldDidEditEvent: Observable<Void>
        let maxNumOfParticipantsPickerSelected: Observable<Int>
        let maxRangeOfRadiusSliderSelected: Observable<Float>
        let createChatButtonDidTapEvent: Observable<Void>
    }
    
    struct Output {
        var maxRangeOfRadius = BehaviorRelay<String>(value: "1km")
        var createChatButtonIsEnable = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.maxRangeOfRadiusSliderSelected
            .map({ "\(Int($0))km" })
            .bind(to: output.maxRangeOfRadius)
            .disposed(by: disposeBag)
        
        input.createChatButtonDidTapEvent
            .subscribe { [weak self] _ in
                self?.actions.showChatViewController()
            }
            .disposed(by: disposeBag)
    
        return output
    }
}
