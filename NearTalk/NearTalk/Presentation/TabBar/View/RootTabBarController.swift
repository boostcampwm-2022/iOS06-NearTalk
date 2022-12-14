//
//  RootTabBarController.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import RxCocoa
import RxSwift
import UIKit

final class RootTabBarController: UITabBarController {
    // MARK: - UI properties
    
    // MARK: - Properties
    private let viewModel: RootTabBarViewModel
    private let disposeBag: DisposeBag = .init()
    
    enum TabBarItem {
        case home
        case chatList
        case friendList
        case myProfile
        
        var num: Int {
            switch self {
            case .home: return 0
            case .chatList: return 1
            case .friendList: return 2
            case .myProfile: return 3
            }
        }
    }
    
    // MARK: - Lifecycles
    init(viewModel: RootTabBarViewModel!) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTabBar()
        self.bind()
    }
    
    // MARK: - Helpers
    private func configureTabBar() {
        self.view.backgroundColor = .secondaryBackground
        self.tabBar.backgroundColor = .secondaryBackground
        self.tabBar.tintColor = .label
        self.tabBar.isTranslucent = false
        
    }
    
    private func bind() {
        self.viewModel.messageAllCount
            .asObservable()
            .subscribe(onNext: { count in
                let allCount = count
                let readCount = self.viewModel.readMessageCount.value
                self.unreadMessageCount(unreadCount: allCount - readCount)
            })
            .disposed(by: disposeBag)
                
        self.viewModel.readMessageCount
            .asObservable()
            .subscribe(onNext: { count in
                let allCount = self.viewModel.messageAllCount.value
                let readCount = count
                self.unreadMessageCount(unreadCount: allCount - readCount)
            })
            .disposed(by: disposeBag)
    }
    
    private func unreadMessageCount(unreadCount: Int) {
        if unreadCount > 0 {
            self.viewControllers?[TabBarItem.chatList.num].tabBarItem.badgeColor = .primaryColor
            self.viewControllers?[TabBarItem.chatList.num].tabBarItem.badgeValue = String(unreadCount)
        } else {
            self.viewControllers?[TabBarItem.chatList.num].tabBarItem.badgeColor = nil
            self.viewControllers?[TabBarItem.chatList.num].tabBarItem.badgeValue = nil
        }
    }
    
}
