//
//  ValidateUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

protocol ValidationResult {
    var message: String { get }
}

protocol ValidateTextUseCase {
    func execute(_ value: String) -> String
}

enum NickNameValidationResult: ValidationResult {
    case success
    case failure
    case empty
    
    var message: String {
        switch self {
        case .success:
            return "사용 가능한 닉네임 입니다"
        case .failure:
            return "3-20 자 사이의 영어 소문자, 숫자, 한글만 사용하십시오"
        default:
            return ""
        }
    }
}

final class ValidateNickNameUseCase: ValidateTextUseCase {
    /// 3자 이상, 20자 이하, 알파벳 소문자, 숫자, 한글만 가능, 특수문자 불가.
    private let nickNameRegex: String = #"^[\da-zㄱ-ㅎㅏ-ㅣ가-힣]{3,20}$"#
    
    func execute(_ value: String) -> String {
        return self.determine(nickName: value).message
    }
    
    private func determine(nickName: String) -> NickNameValidationResult {
        nickName.matchRegex(self.nickNameRegex) ? .success : .failure
    }
}

enum MessageValidationResult: ValidationResult {
    case success
    case failure
    case empty
    
    var message: String {
        switch self {
        case .success:
            return "사용 가능한 메세지 입니다"
        case .failure:
            return "50자 이하로 작성하십시오"
        default:
            return ""
        }
    }
}

final class ValidateStatusMessageUseCase: ValidateTextUseCase {
    func execute(_ value: String) -> String {
        return self.determine(message: value).message
    }
    
    private func determine(message: String) -> MessageValidationResult {
        message.count <= 50 ? .success : .failure
    }
}
