//
//  chatInputAccessoryView.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import RxSwift
import UIKit

class ChatInputAccessoryView: UIView {
    private let disposeBag = DisposeBag()
    
    lazy var messageInputView = UIView().then {
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.secondaryLabel?.cgColor
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        
    }
    
    lazy var messageInputTextField = UITextView().then {
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.secondaryLabel?.cgColor
        $0.layer.cornerRadius = 15
        $0.layer.cornerRadius = 15
        $0.backgroundColor = .secondaryBackground
        $0.textColor = .label
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.clipsToBounds = true
        $0.textContainerInset = UIEdgeInsets(top: 10.0, left: 7.0, bottom: 10.0, right: 7.0)
    }
    
    lazy var sendButton = UIButton(type: .system).then {
        let imageConfigure = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfigure)
        $0.setImage(image, for: .normal)
        $0.tintColor = .primaryColor
    }
    
    lazy var addButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = .label
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [addButton, messageInputTextField, sendButton].forEach {
            self.addSubview($0)
        }
        self.addButton.snp.makeConstraints { make in
            make.height.width.equalTo(35)
            make.leading.equalTo(self).offset(8)
            make.bottom.equalToSuperview().inset(10)
        }
        
        self.sendButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        self.messageInputTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
            make.leading.equalTo(addButton.snp.trailing).offset(16)
            make.trailing.equalTo(sendButton.snp.leading).offset(-20)
        }
    }
}
