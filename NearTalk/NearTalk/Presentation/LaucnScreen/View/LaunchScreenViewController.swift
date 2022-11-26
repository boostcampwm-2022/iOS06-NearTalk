//
//  LaunchScreenViewController.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import SnapKit
import Then
import UIKit

final class LaunchScreenViewController: UIViewController {
    // MARK: - UI properties
    private let titleLabel: UILabel = UILabel().then {
        $0.text = "근방톡"
        $0.font = .systemFont(ofSize: 50, weight: .semibold)
    }
    
    // MARK: - Properties
    private let viewModel: LaunchScreenViewModel
    
    // MARK: - Lifecycles
    init(viewModel: LaunchScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(Self.self, #function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        addSubviews()
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.checkIsAuthenticated()
    }

    // MARK: - Configure views
    private func addSubviews() {
        self.view.addSubview(titleLabel)
    }
    
    private func configureConstraints() {
        configureLogoLabel()
    }
    
    private func configureLogoLabel() {
        self.titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct LaunchScreenViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let container: AppDIContainer = .init(
            navigationController: .init(),
            launchScreenActions: .init(),
            onboardingActions: .init(showMainViewController: nil)
        )
        let diContainer: LaunchScreenDIContainer = container.resolveLaunchScreenDIContainer()
        let vc: LaunchScreenViewController = diContainer.resolveLaunchScreenViewController()
        return vc.showPreview(.iPhone14Pro)
    }
}
#endif
