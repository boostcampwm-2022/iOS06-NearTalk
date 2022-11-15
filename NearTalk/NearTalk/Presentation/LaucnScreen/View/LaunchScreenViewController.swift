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
    private let repository: LaunchScreenRepository
    
    // MARK: - Lifecycles
    init(viewModel: LaunchScreenViewModel, repository: LaunchScreenRepository) {
        self.viewModel = viewModel
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureView()
    }
    
    // MARK: - Helpers
    func configureView() {
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct LaunchScreenViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let mockUseCase = DefaultLaunchScreenUseCase(launchScreenRepository: DefaultLaunchScreenRepository())
        let mockAction = LaunchScreenViewModelActions(
            showLoginViewController: {},
            showMainViewController: {}
        )

        return LaunchScreenViewController(
            viewModel: DefaultLaunchScreenViewModel(useCase: mockUseCase, actions: mockAction),
            repository: DefaultLaunchScreenRepository()
        ).showPreview(.iPhone14Pro)
    }
}
#endif
