//
//  Environment.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/25.
//

import Foundation

public enum Environment {
    // MARK: - Plist
    enum Plist {
        static let fcmURL = "FCM_URL"
        static let fcmServerKey = "FCM_SERVER_KEY"
    }

    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary
        else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    // MARK: - Plist values
    static let fcmURL: URL = {
        guard let fcmURLString = Environment.infoDictionary[Plist.fcmURL] as? String
        else {
            fatalError("Root URL not set in plist for this environment")
        }
        guard let url = URL(string: fcmURLString) else {
            fatalError("Root URL is invalid")
        }
        return url
    }()

    static let fcmServerKey: String = {
        guard let fcmServerKey = Environment.infoDictionary[Plist.fcmServerKey] as? String
        else {
            fatalError("API Key not set in plist for this environment")
        }
        return fcmServerKey
    }()
}
