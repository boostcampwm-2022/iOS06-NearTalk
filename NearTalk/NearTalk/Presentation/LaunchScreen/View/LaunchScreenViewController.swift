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
    private let appLogoImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "Logo")
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
        self.view.backgroundColor = .primaryBackground
        addSubviews()
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.checkIsAuthenticated()
    }

    // MARK: - Configure views
    private func addSubviews() {
        self.view.addSubview(appLogoImageView)
    }
    
    private func configureConstraints() {
        configureLogoLabel()
    }
    
    private func configureLogoLabel() {
        self.appLogoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
