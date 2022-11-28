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
        let maxRangeOfRadiusSliderSelected: Observable<Float>
        let createChatButtonDidTapEvent: Observable<Void>
    }
    
    struct Output {
        var maxRangeOfRadius = BehaviorRelay<String>(value: "1km")
        var createChatButtonIsEnable = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        
        input.maxRangeOfRadiusSliderSelected
            .map({ "\(Int($0))km" })
            .bind(to: output.maxRangeOfRadius)
            .disposed(by: disposeBag)
        
        input.createChatButtonDidTapEvent
            .subscribe { [weak self] _ in
                self?.coordinator.showChatViewController()
            }
            .disposed(by: disposeBag)
    
        return output
    }
}
