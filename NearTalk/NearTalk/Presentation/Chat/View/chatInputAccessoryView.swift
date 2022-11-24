//
//  chatInputAccessoryView.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

class ChatInputAccessoryView: UIView {
    private lazy var messageInputTextView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = .yellow
        $0.isScrollEnabled = false
    }
    
    private lazy var sendButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "heart"), for: .normal)
        $0.isEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        configureConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints() {
        
    }
    
    @objc
    private func handleTextInputChange() {
        
    }
}
