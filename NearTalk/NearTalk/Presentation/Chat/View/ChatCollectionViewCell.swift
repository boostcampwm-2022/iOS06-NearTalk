//
//  ChatCollectionViewCell.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

import SnapKit

class ChatCollectionViewCell: UICollectionViewCell {
    // MARK: - Proporty
    
    static let identifier = String(describing: ChatRoomListCell.self)
    
    // MARK: - UI Proporty
    
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
    
    private lazy var namelabel: UILabel = UILabel().then { label in
        label.text = "name"
        label.font = UIFont.systemFont(ofSize: 16)
    }
    
    private let timelabel: UILabel = UILabel().then { label in
        label.text = " "
        label.font = UIFont.systemFont(ofSize: 16)
    }
    
    private lazy var profileImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "heart"))
        view.layer.cornerRadius = view.bounds.width / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    // MARK: - LifeCycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addViews()
        self.backgroundColor = .yellow
        self.contentView.backgroundColor = .blue
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.textView.snp.remakeConstraints { make in
            make.width.lessThanOrEqualTo(250)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func configure(isInComing: Bool, message: String) {
        self.textView.text = message
        
        textView.backgroundColor = isInComing ? .systemGray : .white
        
        if isInComing {
            self.textView.snp.makeConstraints { make in
                make.leading.equalToSuperview()
            }
        } else {
            self.textView.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
            }
        }
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
            make.width.lessThanOrEqualTo(250)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
