//
//  chatInputAccessoryView.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

class ChatInputAccessoryView: UIView {
    lazy var messageInputTextField = UITextField().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 2.0
        $0.layer.borderColor = UIColor.systemOrange.cgColor
    }
    
    lazy var sendButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.systemOrange.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [messageInputTextField, sendButton].forEach {
            self.addSubview($0)
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        
        messageInputTextField.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(sendButton.snp.leading).offset(-20)
        }
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     return CGSize(width: self.view.frame.width, height: 100)
    }
}
