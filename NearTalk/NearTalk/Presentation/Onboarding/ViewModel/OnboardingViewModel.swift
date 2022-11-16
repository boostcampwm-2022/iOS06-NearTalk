//
//  OnboardingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

import RxCocoa

import Foundation
import RxSwift

struct OnboardingInput {
    let nickName: Observable<String>
    let message: Observable<String>
}

struct OnboardingOutput {
    let nickNameValidity: Driver<Bool>
    let messageValidity: Driver<Bool>
    let registerEnable: Driver<Bool>
}

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(_ input: Input) -> Output
}

protocol OnboardingViewModel: ViewModelType where Input == OnboardingInput, Output == OnboardingOutput {
    init(validateUseCase: any OnboardingValidateUseCase, saveProfileUseCase: any OnboardingSaveProfileUseCase)
}

final class DefaultOnboardingViewModel: OnboardingViewModel {
    private let validateUseCase: any OnboardingValidateUseCase
    private let saveProfileUseCase: any OnboardingSaveProfileUseCase
    
    init(validateUseCase: any OnboardingValidateUseCase, saveProfileUseCase: any OnboardingSaveProfileUseCase) {
        self.validateUseCase = validateUseCase
        self.saveProfileUseCase = saveProfileUseCase
    }
    
    func transform(_ input: OnboardingInput) -> OnboardingOutput {
        let nickNameValidity: Driver<Bool> = input.nickName
            .map { [self] text in
                self.validateUseCase.validateNickName(text)
            }
            .asDriver(onErrorJustReturn: false)
        
        let messageValidity: Driver<Bool> = input.message
            .map { [self] text in
                self.validateUseCase.validateMessage(text)
            }
            .asDriver(onErrorJustReturn: false)
        
        let registerEnable: Driver<Bool> = Observable.combineLatest(nickNameValidity.asObservable(), messageValidity.asObservable()) {
            $0 && $1
        }
            .asDriver(onErrorJustReturn: false)
        return Output(nickNameValidity: nickNameValidity, messageValidity: messageValidity, registerEnable: registerEnable)
    }
}
