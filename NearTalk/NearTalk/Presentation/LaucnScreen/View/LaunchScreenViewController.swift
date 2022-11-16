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
        self.view.backgroundColor = .white
        configureView()
    }
    
    // MARK: - Helpers
    func configureView() {
        self.view.addSubview(titleLabel)
        
        self.titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct LaunchScreenViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let diContainer: LaunchScreenDIContainer = .init()
        let mockRepository: LaunchScreenRepository = diContainer.makeRepository()
        let mockAction: LaunchScreenViewModelActions = .init(showLoginViewController: {}, showMainViewController: {})
        let mockViewModel: LaunchScreenViewModel = diContainer.makeViewModel(actions: mockAction)
        return LaunchScreenViewController(viewModel: mockViewModel, repository: mockRepository)
            .showPreview(.iPhone14Pro)
    }
}
#endif
