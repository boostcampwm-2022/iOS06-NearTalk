//
//  RootTabBarController.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import UIKit

final class RootTabBarController: UITabBarController {
    // MARK: - UI properties
    
    // MARK: - Properties
    private var viewModel: RootTabBarViewModel!
    
    // MARK: - Lifecycles
    static func create(with viewModel: RootTabBarViewModel) -> RootTabBarController {
        let view = RootTabBarController()
        view.viewModel = viewModel
        return view
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTabBar()
    }
    
    // MARK: - Helpers
    private func configureTabBar() {
        self.view.backgroundColor = .secondarySystemBackground
        self.tabBar.barTintColor = .secondarySystemBackground
        self.tabBar.isTranslucent = false
    }
}
