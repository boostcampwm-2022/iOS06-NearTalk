//
//  FirebaseQuery.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/20.
//

import FirebaseFirestore
import Foundation

enum FirebaseQueryKey {
    case `in`
    case notIn
    case isEqualTo
    case isLessThan
    case arrayContains
    case isGreaterThan
    case isNotEqualTo
    case arrayContainsAny
    case isLessThanOrEqualTo
    case isGreaterThanOrEqualTo
    
    // swiftlint:disable: cyclomatic_complexity
    func whereField(
        query: FirebaseFirestore.Query,
        key: String,
        value: Any
    ) -> FirebaseFirestore.Query {
        switch self {
        case .in:
            if let value = value as? [Any] {
                return query.whereField(key, in: value)
            } else {
                return query
            }
        case .notIn:
            if let value = value as? [Any] {
                return query.whereField(key, notIn: value)
            } else {
                return query
            }
        case .isEqualTo:
            return query.whereField(key, isEqualTo: value)
        case .isLessThan:
            return query.whereField(key, isLessThan: value)
        case .arrayContains:
            return query.whereField(key, arrayContains: value)
        case .isGreaterThan:
            return query.whereField(key, isGreaterThan: value)
        case .isNotEqualTo:
            return query.whereField(key, isNotEqualTo: value)
        case .arrayContainsAny:
            if let value = value as? [Any] {
                return query.whereField(key, arrayContainsAny: value)
            } else {
                return query
            }
        case .isLessThanOrEqualTo:
            return query.whereField(key, isLessThanOrEqualTo: value)
        case .isGreaterThanOrEqualTo:
            return query.whereField(key, isGreaterThanOrEqualTo: value)
        }
    }
    
    // swiftlint:disable: cyclomatic_complexity
    func makeQueryWithDocRef(
        docRef: FirebaseFirestore.CollectionReference,
        key: String,
        value: Any
    ) -> FirebaseFirestore.Query? {
        switch self {
        case .in:
            if let value = value as? [Any] {
                return docRef.whereField(key, in: value)
            } else {
                return nil
            }
        case .notIn:
            if let value = value as? [Any] {
                return docRef.whereField(key, notIn: value)
            } else {
                return nil
            }
        case .isEqualTo:
            return docRef.whereField(key, isEqualTo: value)
        case .isLessThan:
            return docRef.whereField(key, isLessThan: value)
        case .arrayContains:
            return docRef.whereField(key, arrayContains: value)
        case .isGreaterThan:
            return docRef.whereField(key, isGreaterThan: value)
        case .isNotEqualTo:
            return docRef.whereField(key, isNotEqualTo: value)
        case .arrayContainsAny:
            if let value = value as? [Any] {
                return docRef.whereField(key, arrayContainsAny: value)
            } else {
                return nil
            }
        case .isLessThanOrEqualTo:
            return docRef.whereField(key, isLessThanOrEqualTo: value)
        case .isGreaterThanOrEqualTo:
            return docRef.whereField(key, isGreaterThanOrEqualTo: value)
        }
    }
}
