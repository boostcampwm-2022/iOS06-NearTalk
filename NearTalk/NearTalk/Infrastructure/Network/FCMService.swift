//
//  FCMService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/24.
//

import FirebaseMessaging
import Foundation
import RxSwift

protocol FCMService {
    func sendMessage(_ message: ChatMessage, _ roomName: String, _ tokenList: [String]) -> Completable
}

enum FCMServiceError: Error {
    case failedToSendFCM
}

final class DefaultFCMService: FCMService {
    func sendMessage(_ message: ChatMessage, _ roomName: String, _ tokenList: [String]) -> Completable {
        print("🚧 ", #function)
        print("-+++++++", tokenList)
        return Completable.create { completable in
            let dto: FCMNotificationDTO = .init(
                notification: .init(title: "\(roomName)", body: message.text),
                registrationIds: tokenList
            )
            guard let postData: Data = try? JSONEncoder().encode(dto) else {
                completable(.error(FCMServiceError.failedToSendFCM))
                return Disposables.create()
            }
            print(String(decoding: postData, as: UTF8.self))
            var request = URLRequest(url: Environment.fcmURL, timeoutInterval: 10.0)
            request.addValue(Environment.fcmServerKey, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data else {
                    print(String(describing: error))
                    completable(.error(FCMServiceError.failedToSendFCM))
                    return
                }
                print(String(data: data, encoding: .utf8)!)
                completable(.completed)
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
