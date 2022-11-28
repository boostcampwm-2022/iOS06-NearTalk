//
//  ValidateUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

protocol ValidateTextUseCase {
    func execute(_ value: String) -> Bool
}

final class ValidateNickNameUseCase: ValidateTextUseCase {
    /// 5자 이상, 20자 이하, 알파벳 소문자, 숫자, 특수문자(_-) 만 가능
    private let nickNameRegex: String = #"^[\da-z_-]{5,20}$"#
    
    func execute(_ value: String) -> Bool {
        return value.matchRegex(self.nickNameRegex)
    }
}

final class ValidateStatusMessageUseCase: ValidateTextUseCase {
    func execute(_ value: String) -> Bool {
        return value.count <= 50
    }
}
