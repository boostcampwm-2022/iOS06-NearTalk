//
//  Codable+Dictionary.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/19.
//

import Foundation

extension Encodable {
    func encode() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
        else {
            throw NSError()
        }
        return dictionary
    }
}

extension Decodable {
    static func decode<T: Decodable>(dictionary: [String: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [.fragmentsAllowed])
        return try JSONDecoder().decode(T.self, from: data)
    }
}
