//
//  AppTheme.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/08.
//

enum AppTheme: String, CaseIterable {
    static let keyName: String = String(describing: AppTheme.self)
    case system = "시스템 설정"
    case dark = "다크 모드"
    case light = "라이트 모드"
}
