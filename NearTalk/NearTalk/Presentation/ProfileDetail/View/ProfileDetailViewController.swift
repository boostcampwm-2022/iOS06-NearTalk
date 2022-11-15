//
//  ProfileDetailViewController.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/15.
//

import UIKit

class ProfileDetailViewController: UIViewController {
    private lazy var thumnailImageView = UIImageView().then {
        $0.layer.cornerRadius = 40
        $0.clipsToBounds = true
        $0.backgroundColor = .systemOrange
    }
    
    private lazy var nameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = .systemFont(ofSize: 20.0, weight: .bold)
    }
    
    private lazy var stateLabel = UILabel().then {
        $0.text = "상태메세지"
    }
    
    private lazy var chatButton = UIButton().then {
        $0.setTitle("채팅 하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .bold)
        $0.layer.cornerRadius = 15.0
        $0.backgroundColor = .systemOrange
    }
    
    private lazy var deleteButton = UIButton().then {
        $0.setTitle("친구 삭제하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .bold)
        $0.layer.cornerRadius = 15.0
        $0.backgroundColor = .systemOrange
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configLayout()
    }
}

private extension ProfileDetailViewController {
    private func configLayout() {
        let profileStackView = UIStackView(arrangedSubviews: [thumnailImageView, nameLabel, stateLabel])
        profileStackView.axis = .vertical
        profileStackView.spacing = 20.0
        
        let buttonStackView = UIStackView(arrangedSubviews: [chatButton, deleteButton])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 10.0
        
        [profileStackView, buttonStackView].forEach {
            view.addSubview($0)
        }
        
        profileStackView.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        thumnailImageView.snp.makeConstraints {
            $0.height.equalTo(view.bounds.width - 40)
        }
        
        chatButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(self.view.bounds.width)
        }
        
        deleteButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(self.view.bounds.width)
        }
    }
}
