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
    /// 3자 이상, 20자 이하, 알파벳 소문자, 숫자, 한글만 가능, 특수문자 불가.
    private let nickNameRegex: String = #"^[\da-zㄱ-ㅎㅏ-ㅣ가-힣]{3,20}$"#
    
    func execute(_ value: String) -> Bool {
        return value.matchRegex(self.nickNameRegex)
    }
}

final class ValidateStatusMessageUseCase: ValidateTextUseCase {
    func execute(_ value: String) -> Bool {
        return value.count <= 50
    }
}
