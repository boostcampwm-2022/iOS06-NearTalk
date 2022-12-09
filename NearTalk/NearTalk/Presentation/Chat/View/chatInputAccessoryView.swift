//
//  chatInputAccessoryView.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

class ChatInputAccessoryView: UIView {
    
    lazy var messageInputView = UIView().then {
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.secondaryLabel?.cgColor
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        
    }
    
    lazy var messageInputTextField = UITextField().then {
        $0.backgroundColor = .clear
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
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
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [addButton, messageInputView, messageInputTextField, sendButton].forEach {
            self.addSubview($0)
        }
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(8)
            make.height.width.equalTo(35)
            
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        
        messageInputView.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.centerY.equalToSuperview()
            make.leading.equalTo(addButton.snp.trailing).offset(8)
            make.trailing.equalTo(sendButton.snp.leading).offset(-20)
        }
        
        messageInputTextField.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.centerY.equalToSuperview()
            make.leading.equalTo(addButton.snp.trailing).offset(16)
            make.trailing.equalTo(sendButton.snp.leading).offset(-20)
        }
    }
}
