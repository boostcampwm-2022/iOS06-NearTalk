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
    
    // MARK: - Properties
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: any ProfileSettingViewModel

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubViews()
        self.configureNavigationBar()
        self.configureView()
        self.configureConstraint()
        self.bindToViewModel()
    }
    
    init(viewModel: any ProfileSettingViewModel, neccesaryProfileComponent: NecessaryProfileComponent?) {
        self.viewModel = viewModel
        if let neccesaryProfileComponent = neccesaryProfileComponent {
            self.nicknameField.text = neccesaryProfileComponent.nickName
            self.messageField.text = neccesaryProfileComponent.message
            if let image = neccesaryProfileComponent.image {
                self.profileImageView.image = UIImage(data: image)
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
private extension ProfileSettingViewController {
    func addSubViews() {
        [profileImageView, nicknameField, messageField].forEach {
            view.addSubview($0)
        }
    }
    
    func configureView() {
        self.view.backgroundColor = .systemBackground
    }
    
    func configureNavigationBar() {
        self.navigationController?.navigationBar.backgroundColor = .systemGray5
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "프로필 설정"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "등록", style: .plain, target: self, action: nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
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
    
    func bindToViewModel() {
        self.bindNickNameField()
        self.bindMessageField()
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
    
    func bindMessageField() {
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
            .compactMap {
                $0
            }
            .compactMap {
                UIImage(data: $0)
            }
            .subscribe(self.profileImageView.rx.image)
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

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//struct ProfileSettingViewControllerPreview: PreviewProvider {
//    static var previews: some View {
//        let diContainer: DefaultProfileSettingDIContainer = .init(dependency: .init(
//            updateProfileUseCase: DefaultUpdateProfileUseCase(repository: DefaultProfileRepository(firestoreService: DefaultFirestoreService(), firebaseAuthService: DefaultFirebaseAuthService())),
//            validateNickNameUseCase: ValidateNickNameUseCase(),
//            validateStatusMessageUseCase: ValidateStatusMessageUseCase(),
//            uploadImageUseCase: DefaultUploadImageUseCase(imageRepository: DefaultImageRepository(imageService: DefaultStorageService())),
//            profile: .init(uuid: <#T##String?#>, username: <#T##String?#>, email: <#T##String?#>, statusMessage: <#T##String?#>, profileImagePath: <#T##String?#>, friends: <#T##[String]?#>, chatRooms: <#T##[String]?#>),
//            necessaryProfileComponent: .init(nickName: "Tester01", message: "Preview Test", image: nil)))
//        let vc: LaunchScreenViewController = diContainer.
//        return vc.showPreview(.iPhone14Pro)
//    }
//}
//#endif
