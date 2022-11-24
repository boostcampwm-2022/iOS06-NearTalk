//
//  ChatCollectionViewCell.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

import SnapKit

class ChatCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: ChatRoomListCell.self)
    
    var message: String? {
        didSet {
            textView.text = message
        }
    }
    
    var textAlignment: Bool? {
        didSet {
            namelabel.textAlignment = textAlignment == true ?  .right : .left
        }
    }
    
    var isInComing: Bool? {
        didSet {
            print("isInComing", isInComing)
        }
    }
    
    private let textView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 18.0)
        view.text = "message"
        view.textContainer.maximumNumberOfLines = 0
        view.textColor = .black
        view.backgroundColor = .white
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = false
        view.isEditable = false
        view.isScrollEnabled = false
        view.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        view.sizeToFit()
        return view
    }()
    
    let messagelabel: UILabel = UILabel().then { label in
        label.text = "message"
        label.numberOfLines = 0
    }
    
    private let namelabel: UILabel = UILabel().then { label in
        label.text = "name"
        label.font = UIFont.systemFont(ofSize: 16)
    }
    
    private let timelabel: UILabel = UILabel().then { label in
        label.text = " "
        label.font = UIFont.systemFont(ofSize: 16)
    }
    
    private let profileImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "heart"))
        view.layer.cornerRadius = view.bounds.width / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    let bubbleView: UIView = UIView().then { view in
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addViews()
        self.backgroundColor = .yellow
        self.contentView.backgroundColor = .blue
    }
    
    private func addViews() {
        [textView].forEach {
            self.contentView.addSubview($0)
        }
                
//        self.namelabel.snp.makeConstraints { make in
//            make.top.equalTo(contentView.snp.top)
//            make.leading.trailing.equalToSuperview()
//        }
        
        self.textView.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(300)
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
//        self.bubbleView.snp.makeConstraints { make in
//            make.top.equalTo(messagelabel.snp.top).inset(-16)
//            make.leading.equalTo(messagelabel.snp.leading).inset(-16)
//            make.trailing.equalTo(messagelabel.snp.trailing).inset(-16)
//            make.bottom.equalTo(messagelabel.snp.bottom).inset(-16)
//        }
        
//        self.contentView.snp.makeConstraints { make in
//            make.width.equalTo(250)
//        }
    }
}
