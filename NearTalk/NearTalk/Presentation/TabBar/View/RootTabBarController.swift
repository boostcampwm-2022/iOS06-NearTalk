//
//  RootTabBarController.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import UIKit

struct RootTabBarControllerDependency {
    let mainMapNavigationController: UINavigationController
    let chatRoomListNavigationController: UINavigationController
    let friendListNavigationController: UINavigationController
    let myProfileNavigationController: UINavigationController
}

final class RootTabBarController: UITabBarController {
    // MARK: - UI properties
    
    // MARK: - Properties
    private let viewModel: RootTabBarViewModel
    private let dependency: RootTabBarControllerDependency
    
    // MARK: - Lifecycles
    init(viewModel: RootTabBarViewModel, dependency: RootTabBarControllerDependency) {
        self.viewModel = viewModel
        self.dependency = dependency
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTabBar()
        self.configureViewControllers()
    }
    
    // MARK: - Helpers
    private func configureTabBar() {
        self.view.backgroundColor = .secondarySystemBackground
        self.tabBar.barTintColor = .secondarySystemBackground
        self.tabBar.isTranslucent = false
    }
    
    private func configureViewControllers() {
        self.viewControllers = [
            self.embed(
                rootNav: self.dependency.mainMapNavigationController,
                title: "홈",
                inactivatedImage: UIImage(systemName: "house")?.withTintColor(.darkGray),
                activatedImage: UIImage(systemName: "house.fill")?.withTintColor(.blue)
            ),
            self.embed(
                rootNav: self.dependency.chatRoomListNavigationController,
                title: "채팅",
                inactivatedImage: UIImage(systemName: "message")?.withTintColor(.darkGray),
                activatedImage: UIImage(systemName: "message.fill")?.withTintColor(.blue)
            ),
            self.embed(
                rootNav: self.dependency.friendListNavigationController,
                title: "친구",
                inactivatedImage: UIImage(systemName: "figure.2.arms.open")?.withTintColor(.darkGray),
                activatedImage: UIImage(systemName: "figure.2.arms.open")?.withTintColor(.blue)
            ),
            self.embed(
                rootNav: self.dependency.myProfileNavigationController,
                title: "마이페이지",
                inactivatedImage: UIImage(systemName: "figure.wave")?.withTintColor(.darkGray),
                activatedImage: UIImage(systemName: "figure.wave")?.withTintColor(.blue)
            )
        ]
    }
    
    private func embed(
        rootNav: UINavigationController,
        title: String?,
        inactivatedImage: UIImage?,
        activatedImage: UIImage?
    ) -> UIViewController {
        let tabBarItem = UITabBarItem(
            title: title,
            image: inactivatedImage?.withRenderingMode(.alwaysOriginal),
            selectedImage: activatedImage?.withRenderingMode(.alwaysOriginal)
        )
        rootNav.tabBarItem = tabBarItem
        return rootNav
    }
}
