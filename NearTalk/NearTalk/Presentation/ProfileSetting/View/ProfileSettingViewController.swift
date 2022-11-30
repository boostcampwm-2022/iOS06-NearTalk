//
//  ProfileSettingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Then
import UIKit

final class ProfileSettingViewController: UIViewController {
    // MARK: - UI properties
    private lazy var rootView: ProfileSettingView = ProfileSettingView()
    
    // MARK: - Properties
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: any ProfileSettingViewModel

    // MARK: - Lifecycles
    override func loadView() {
        self.view = self.rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.bindToViewModel()
    }
    
    init(viewModel: any ProfileSettingViewModel, neccesaryProfileComponent: NecessaryProfileComponent?) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        if let neccesaryProfileComponent = neccesaryProfileComponent {
            self.rootView.injectProfileData(profileData: neccesaryProfileComponent)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
private extension ProfileSettingViewController {
    
    func configureNavigationBar() {
//        self.navigationController?.navigationBar.backgroundColor = .systemGray5
//        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "프로필 설정"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "등록", style: .plain, target: self, action: nil)
        self.navigationItem.largeTitleDisplayMode = .automatic
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
    }
    
    func bindToViewModel() {
        self.bindNickNameField()
        self.bindMessageField()
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
    
    func bindMessageField() {
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
        if let updateButton = self.navigationItem.rightBarButtonItem {
            self.viewModel.updateEnable
                .bind(to: updateButton.rx.isEnabled)
                .disposed(by: self.disposeBag)
            updateButton.rx
                .tap
                .bind(onNext: { [weak self] in
                    self?.viewModel.update()
                })
                .disposed(by: self.disposeBag)
        }
    }
}
