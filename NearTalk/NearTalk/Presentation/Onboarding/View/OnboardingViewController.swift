//
//  OnboardingViewController.swift
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

final class OnboardingViewController: UIViewController {
    // MARK: - UI properties
    private let logoView = UIImageView(image: UIImage(systemName: "map.circle.fill"))
    private let profileImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .lightGray
    }

    private let nicknameField: UITextField = UITextField().then {
        $0.placeholder = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let messageField: UITextField = UITextField().then {
        $0.placeholder = "상태 메세지"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let registerButton: UIButton = UIButton().then {
        $0.layer.cornerRadius = 5
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.isEnabled = false
        $0.setTitle("등록하기", for: .normal)
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.addSubViews()
        self.configureConstraints()
        self.bindToViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.profileImageView.makeRounded()
    }
}

// MARK: - Helpers
private extension OnboardingViewController {
    func addSubViews() {
        [logoView, profileImageView, nicknameField, messageField, registerButton].forEach {
            scrollView.addSubview($0)
        }
        view.addSubview(scrollView)
    }
    
    func configureConstraints() {
        self.configureScrollView()
        self.configureLogoView()
        self.configureProfileImageView()
        self.configureNickNameField()
        self.configureMessageField()
        self.configureRegisterButton()
    }
    
    func configureScrollView() {
        scrollView.snp.makeConstraints { (make) in
            make.edges.width.equalToSuperview()
        }
    }
    
    func configureLogoView() {
        logoView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(120)
        }
    }
    
    func configureProfileImageView() {
        profileImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoView.snp.bottom).offset(30)
            make.width.height.equalTo(120)
        }
    }
    
    func configureNickNameField() {
        nicknameField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(profileImageView.snp.bottom).offset(30)
            make.height.equalTo(nicknameField.snp.width).multipliedBy(0.15)
        }
    }
    
    func configureMessageField() {
        messageField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(nicknameField.snp.bottom).offset(30)
            make.height.equalTo(messageField.snp.width).multipliedBy(0.15)
        }
    }
    
    func configureRegisterButton() {
        registerButton.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(messageField.snp.bottom).offset(30)
            make.height.equalTo(registerButton.snp.width).multipliedBy(0.1)
        }
    }
    
    func bindToViewModel() {
        self.bindNickNameField()
        self.bindMessageFeild()
        self.bindProfileTap()
        self.bindRegisterButton()
    }
    
    func bindNickNameField() {
        self.nicknameField.rx.value
            .orEmpty
            .bind(onNext: { [weak self] text in
                self?.viewModel.editNickName(text)
                
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindMessageFeild() {
        self.messageField.rx.value
            .orEmpty
            .bind(onNext: { [weak self] text in
                self?.viewModel.editStatusMessage(text)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindProfileTap() {
        self.profileImageView.rx
            .tapGesture()
            .bind(onNext: { [weak self] gesture in
                if gesture.state == .ended {
                    self?.viewModel.editImage()
                }
            })
            .disposed(by: self.disposeBag)
        self.viewModel.image
            .asObservable()
            .compactMap { $0 }
            .map { UIImage(data: $0) }
            .bind(onNext: { self.profileImageView.image = $0 })
            .disposed(by: self.disposeBag)
    }
    
    func bindRegisterButton() {
        self.viewModel.registerEnable
            .bind(to: self.registerButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        self.registerButton.rx
            .tap
            .bind(onNext: { [weak self] in
                self?.viewModel.register()
            })
            .disposed(by: self.disposeBag)
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}
