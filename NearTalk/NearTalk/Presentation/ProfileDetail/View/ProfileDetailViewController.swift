//
//  ProfileDetailViewController.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/15.
//

import UIKit

import Kingfisher
import RxCocoa
import RxSwift

class ProfileDetailViewController: UIViewController {
    
    // MARK: - Proporties
    
    private var viewModel: ProfileDetailViewModelable!
    private let disposeBag: DisposeBag = DisposeBag()
    
    private enum Metric {
        static let nameLabelFontSize: CGFloat = 24.0
        
        static let cornerRadius: CGFloat = 20.0
        
        static let stackViewLeftRightInset: CGFloat = 20.0
        static let stackViewBottomInset: CGFloat = 4.0
        static let stackViewSpacing: CGFloat = 15.0
        
        static let buttonTitleFontSize: CGFloat = 15.0
        static let buttonHeight: CGFloat = 40.0
    }
    
    // MARK: - UI Proporties
    
    private lazy var profileStackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = Metric.stackViewSpacing
    }
    
    private lazy var buttonStackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = Metric.stackViewSpacing
    }
    
    private lazy var thumbnailImageView: UIImageView = UIImageView().then {
        $0.layer.cornerRadius = Metric.cornerRadius
        $0.clipsToBounds = true
        $0.image = UIImage(named: "ChatLogo")
    }
    
    private lazy var nameLabel: UILabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = .systemFont(ofSize: Metric.nameLabelFontSize, weight: .bold)
    }
    
    private lazy var statusMessage: UILabel = UILabel().then {
        $0.text = "상태메세지"
    }
    
    private lazy var startChatButton: UIButton  = UIButton().then {
        $0.setTitle("채팅 하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: Metric.buttonTitleFontSize, weight: .bold)
        $0.layer.cornerRadius = Metric.cornerRadius
        $0.backgroundColor = .secondaryColor
    }

    private lazy var deleteFriendButton: UIButton = UIButton().then {
        $0.setTitle("친구 삭제하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: Metric.buttonTitleFontSize, weight: .bold)
        $0.layer.cornerRadius = Metric.cornerRadius
        $0.backgroundColor = .secondaryColor
    }
    
    // MARK: - LifeCycle
    static func create(with viewModel: any ProfileDetailViewModelable) -> ProfileDetailViewController {
        let view = ProfileDetailViewController()
        view.viewModel = viewModel
        return view
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        self.addSubviews()
        self.configureStackViews()
        self.configureImageView()
        self.configureButtons()
        self.binding()
    }
}

private extension ProfileDetailViewController {
    func addSubviews() {
        [thumbnailImageView, nameLabel, statusMessage].forEach {
            self.profileStackView.addArrangedSubview($0)
        }
        
        [startChatButton, deleteFriendButton].forEach {
            self.buttonStackView.addArrangedSubview($0)
        }
        
        [profileStackView, buttonStackView].forEach {
            self.view.addSubview($0)
        }
    }
    
    func configureStackViews() {
        self.profileStackView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(Metric.stackViewLeftRightInset)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.buttonStackView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(Metric.stackViewLeftRightInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Metric.stackViewBottomInset)
        }
    }
    
    func configureImageView() {
        self.thumbnailImageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            $0.height.equalTo(view.bounds.width - Metric.stackViewLeftRightInset * 2)
        }
    }
    
    func configureButtons() {
        self.startChatButton.snp.makeConstraints {
            $0.height.equalTo(Metric.buttonHeight)
        }
        
        self.deleteFriendButton.snp.makeConstraints {
            $0.height.equalTo(Metric.buttonHeight)
        }
    }
    
    func binding() {
        self.startChatButton.rx.tap
            .bind(to: viewModel.startChatButtonDidTapEvent)
            .disposed(by: disposeBag)
        
        self.deleteFriendButton.rx.tap
            .bind(to: viewModel.deleteFriendButtonDidTapEvent)
            .disposed(by: disposeBag)
                    
        self.viewModel?.userName
            .asDriver()
            .drive(onNext: { name in
                self.nameLabel.text = name
            })
            .disposed(by: disposeBag)
        
        self.viewModel?.statusMessage
            .asDriver()
            .drive(onNext: { statusMessage in
                self.statusMessage.text = statusMessage
            })
            .disposed(by: disposeBag)
        
        self.viewModel.profileImageURL
            .asDriver()
            .drive(onNext: {
                self.setImage(path: $0)
            })
            .disposed(by: disposeBag)
    }
    
    private func setImage(path: String?) {
        guard let path = path,
              let url = URL(string: path)
        else {
            return
        }
        
        self.thumbnailImageView.kf.setImage(with: url)
    }
}
