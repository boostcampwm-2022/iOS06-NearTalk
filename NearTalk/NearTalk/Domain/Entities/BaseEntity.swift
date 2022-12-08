//
//  BaseEntity.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/20.
//

import Foundation

protocol BaseEntity: Codable {
    var uuid: String? { get set }
    
    /// Date().timeIntervalSince1970 값
    var createdAtTimeStamp: Double? { get set }
}
