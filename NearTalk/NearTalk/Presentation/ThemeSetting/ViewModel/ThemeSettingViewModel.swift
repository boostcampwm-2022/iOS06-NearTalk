//
//  ThemeSettingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/08.
//

import RxCocoa

enum ThemeSettingSection: Hashable & Sendable {
    case main
}

protocol ThemeSettingInput {
    func selectTheme(item: AppTheme?)
}

protocol ThemeSettingOutput {
    var curTheme: Driver<AppTheme> { get }
}

protocol ThemeSettingViewModel: ThemeSettingInput, ThemeSettingOutput {}

final class DefaultThemeSettingViewModel {
    private let curThemeRelay: BehaviorRelay<AppTheme>
    
    init() {
        if let themeRawValue = UserDefaults.standard.string(forKey: AppTheme.keyName), let theme = AppTheme(rawValue: themeRawValue) {
            self.curThemeRelay = BehaviorRelay(value: theme)
        } else {
            self.curThemeRelay = BehaviorRelay(value: .system)
        }
    }
}

extension DefaultThemeSettingViewModel: ThemeSettingViewModel {
    var curTheme: Driver<AppTheme> {
        self.curThemeRelay.asDriver()
    }
    
    func selectTheme(item: AppTheme?) {
        guard let item = item
        else {
            return
        }
        
        if item != self.curThemeRelay.value {
            UserDefaults.standard.set(item.rawValue, forKey: AppTheme.keyName)
            self.curThemeRelay.accept(item)
        }
    }
}
