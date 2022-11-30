//
//  OnboardingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - UI properties
    private lazy var rootView: OnboardingView = OnboardingView()
    
    // MARK: - Properties
    private var buttonToggle: Bool = false
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: any OnboardingViewModel
    
    // MARK: - Lifecycles
    init(viewModel: any OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.bindToViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.rootView.makeProfileViewRounded()
    }
}

// MARK: - Helpers
private extension OnboardingViewController {
    func bindToViewModel() {
        self.bindNickNameField()
        self.bindMessageFeild()
        self.bindProfileTap()
        self.bindRegisterButton()
    }
    
    func bindNickNameField() {
        self.rootView.nickNameText
            .bind(onNext: { [weak self] text in
                self?.viewModel.editNickName(text)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindMessageFeild() {
        self.rootView.messageText
            .bind(onNext: { [weak self] text in
                self?.viewModel.editStatusMessage(text)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindProfileTap() {
        self.rootView.tapProfileEvent
            .bind(onNext: { [weak self] _ in
                self?.viewModel.editImage()
            })
            .disposed(by: self.disposeBag)
        self.viewModel.image
            .asDriver()
            .compactMap { $0 }
            .map { UIImage(data: $0) }
            .drive(self.rootView.profileImage)
            .disposed(by: self.disposeBag)
    }
    
    func bindRegisterButton() {
        self.viewModel.registerEnable
            .asDriver()
            .drive(self.rootView.registerEnable)
            .disposed(by: self.disposeBag)
        self.rootView.registerBtnClickEvent
            .bind(onNext: { [weak self] _ in
                self?.viewModel.register()
            })
            .disposed(by: self.disposeBag)
    }
}
