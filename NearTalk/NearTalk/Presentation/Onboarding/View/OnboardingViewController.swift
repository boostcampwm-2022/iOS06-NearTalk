//
//  OnboardingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - UI properties
    private lazy var logoView = UIImageView(image: UIImage(systemName: "map.circle.fill"))
    private lazy var profileImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .lightGray
    }
    
    private let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer().then {
        $0.numberOfTouchesRequired = 1
        $0.numberOfTapsRequired = 1
    }

    private lazy var nicknameField: UITextField = UITextField().then {
        $0.placeholder = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private lazy var messageField: UITextField = UITextField().then {
        $0.placeholder = "상태 메세지"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private lazy var registerButton: UIButton = UIButton().then {
        $0.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
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
    private weak var coordinator: OnboardingCoordinator?
    
    // MARK: - Lifecycles
    init(viewModel: any OnboardingViewModel, coordinator: OnboardingCoordinator) {
        self.coordinator = coordinator
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
        self.bindProfileTap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
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
        let nickName = nicknameField.rx.text.orEmpty.asObservable()
        let message = messageField.rx.text.orEmpty.asObservable()
        let input = OnboardingInput(nickName: nickName, message: message)
        let output = viewModel.transform(input)
        
        output.registerEnable
            .drive(registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func bindProfileTap() {
        tapGesture.addTarget(self, action: #selector(touchProfileImageView(sender:)))
        self.profileImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func touchProfileImageView(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.coordinator?.presentPictureSelectViewController(self.profileImageView.rx.image.asObserver())
        }
    }
    
    @objc private func buttonClicked() {
        self.buttonToggle.toggle()
        self.registerButton.backgroundColor = buttonToggle ? .systemRed : .systemBlue
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

// swiftlint:disable: type_name
struct OnbardViewController_Preview: PreviewProvider {
    static var previews: some View {
        let diContainer: DefaultOnboardingDIContainer = DefaultOnboardingDIContainer()
        let navController: UINavigationController = UINavigationController()
        let coordinator: OnboardingCoordinator = diContainer.makeOnboardingCoordinator(navigationController: navController, dependency: diContainer.makeOnboardingCoordinatorDependency())
        coordinator.start()
        return navController.showPreview(.iPhoneSE3)
    }
}
#endif
