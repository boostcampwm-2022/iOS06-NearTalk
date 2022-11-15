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

protocol OnboardingValidateUseCase {
    func validateNickName(_ value: String) -> Bool
    func validateMessage(_ value: String) -> Bool
}

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(_ input: Input) -> Output
}

extension String {
    private func regexList(pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let founds = regex.matches(in: self, range: NSRange(self.startIndex ..< self.endIndex, in: self))
            return founds.compactMap {
                if let range = Range($0.range, in: self) {
                    return String(self[range])
                } else {
                    return nil
                }
            }
        } catch {
            return []
        }
    }
    
    func matchRegex(_ pattern: String) -> Bool {
        return !self.regexList(pattern: pattern).isEmpty
    }
}

struct DefaultOnboardingValidateUseCase: OnboardingValidateUseCase {
    private let nickNameRegex: String = #"^[\da-z_@#!=\\\^\$\.\|\[\]\(\)\*\+\?\{\}]{5,20}$"#
    func validateNickName(_ value: String) -> Bool {
        return value.matchRegex(nickNameRegex)
    }
    func validateMessage(_ value: String) -> Bool {
        return value.count <= 50
    }
}

struct TestOnboardingValidateUseCase: OnboardingValidateUseCase {
    func validateNickName(_ value: String) -> Bool {
        return !value.isEmpty
    }
    func validateMessage(_ value: String) -> Bool {
        return !value.isEmpty
    }
}

protocol OnboardingViewModel: ViewModelType where Input == OnboardingInput, Output == OnboardingOutput {
    init(useCase: OnboardingValidateUseCase)
}

struct DefaultOnboardingViewModel: OnboardingViewModel {
    func transform(_ input: OnboardingInput) -> OnboardingOutput {
        let nickNameValidity: Driver<Bool> = input.nickName
            .map { [self] text in
                self.useCase.validateNickName(text)
            }
            .asDriver(onErrorJustReturn: false)
        
        let messageValidity: Driver<Bool> = input.message
            .map { [self] text in
                self.useCase.validateMessage(text)
            }
            .asDriver(onErrorJustReturn: false)
        
        let registerEnable: Driver<Bool> = Observable.combineLatest(nickNameValidity.asObservable(), messageValidity.asObservable()) {
            $0 && $1
        }
            .asDriver(onErrorJustReturn: false)
        return Output(nickNameValidity: nickNameValidity, messageValidity: messageValidity, registerEnable: registerEnable)
    }
    
    private let useCase: OnboardingValidateUseCase
    
    init(useCase: OnboardingValidateUseCase) {
        self.useCase = useCase
    }
}
