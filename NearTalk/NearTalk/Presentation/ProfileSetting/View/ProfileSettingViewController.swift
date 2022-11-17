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
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .lightGray
    }

    private let nicknameField = UITextField().then {
        $0.placeholder = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let messageField = UITextField().then {
        $0.placeholder = "상태 메세지"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    // MARK: - Properties
    private weak var coordinator: MyProfileCoordinator?
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureConstraint()
        self.bindToProfileImage()
    }
    
    init(coordinator: MyProfileCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
private extension ProfileSettingViewController {
    func configureUI() {
        configureNavigationBar()
        [profileImageView, nicknameField, messageField].forEach {
            view.addSubview($0)
        }
        view.backgroundColor = .systemBackground
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .systemGray5
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "프로필 설정"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "등록", style: .plain, target: self, action: nil)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
    }
    
    func configureConstraint() {
        profileImageView.snp.makeConstraints { (make) in
            make.horizontalEdges.top.equalToSuperview()
            make.width.equalTo(profileImageView.snp.height)
        }
        
        nicknameField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
        }
        
        messageField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(nicknameField.snp.bottom).offset(10)
        }
    }
    
    func bindToProfileImage() {
        self.profileImageView.rx
            .tapGesture()
            .asObservable()
            .bind(onNext: { gesture in
                if gesture.state == .ended {
                    self.coordinator?.showPHPickerViewController(self.profileImageView.rx.image)
                }
            })
            .disposed(by: self.disposeBag)
    }
}
