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
    private let viewModel: RootTabBarViewModel
    
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
    }
    
    // MARK: - Helpers
    private func configureTabBar() {
        self.view.backgroundColor = .secondarySystemBackground
        self.tabBar.barTintColor = .secondarySystemBackground
        self.tabBar.isTranslucent = false
    }
}
