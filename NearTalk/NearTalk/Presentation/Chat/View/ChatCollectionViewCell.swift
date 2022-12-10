//
//  ChatCollectionViewCell.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import Kingfisher
import SnapKit
import UIKit

class ChatCollectionViewCell: UICollectionViewCell {
    // MARK: - Proporty
    
    static let identifier = String(describing: ChatRoomListCell.self)
    
    // MARK: - UI Proporty
    
    private let textView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16.0)
        view.text = "message"
        view.textContainer.maximumNumberOfLines = 0
        view.textColor = .black
        view.backgroundColor = .white
        view.layer.cornerRadius = 20.0
        view.layer.masksToBounds = false
        view.isEditable = false
        view.isScrollEnabled = false
        view.textContainerInset = .init(top: 13, left: 13, bottom: 13, right: 13)
        view.sizeToFit()
        return view
    }()
    
    private lazy var namelabel: UILabel = UILabel().then { label in
        label.text = "namelabel"
        label.font = UIFont.systemFont(ofSize: 12)
    }
    
    private let timelabel: UILabel = UILabel().then { label in
        label.text = "timelabel"
        label.font = UIFont.systemFont(ofSize: 8)
    }
    
    private lazy var profileImageView: UIImageView = UIImageView().then { imageView in
        imageView.layer.cornerRadius = 20.0
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "heart")
    }
    
    // MARK: - LifeCycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.addViews()
        self.isUserInteractionEnabled = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.textView.snp.remakeConstraints { make in
            make.width.lessThanOrEqualTo(250)
            make.bottom.equalToSuperview()
        }
        self.namelabel.text = ""
        self.timelabel.text = ""
        self.profileImageView.image = nil
    }

    func configure(messageItem: MessageItem, completion: (() -> Void)? = nil) {
        let isInComing = messageItem.type == .receive ? true : false
        
        self.textView.backgroundColor = isInComing ? .secondaryLabel : .primaryColor
        self.textView.text = messageItem.message
        self.namelabel.text = isInComing ? messageItem.userName : ""
        self.timelabel.text = self.convertDateToString(with: messageItem.createdAt)
                
        if isInComing {
            self.setImage(path: messageItem.imagePath)
            
            self.textView.snp.makeConstraints { make in
                make.leading.equalTo(profileImageView.snp.trailing).inset(-5)
                make.top.equalTo(namelabel.snp.bottom).inset(-2)
            }
            
            self.timelabel.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.leading.equalTo(self.textView.snp.trailing)
            }
        } else {
            self.profileImageView.image = nil
            
            self.textView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(10)
                make.top.equalToSuperview()
            }
            
            self.timelabel.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.trailing.equalTo(self.textView.snp.leading)
            }
        }
    }
    
    private func addViews() {
        [namelabel, profileImageView, textView, timelabel].forEach {
            self.contentView.addSubview($0)
        }
        
        self.namelabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(namelabel.snp.left).inset(-5)
            make.top.equalToSuperview()
        }
        
        self.textView.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(250)
            make.bottom.equalToSuperview()
        }
        
        self.timelabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
    
    private func setImage(path: String?) {
        guard let path = path,
              let url = URL(string: path)
        else {
            return
        }
        
        self.profileImageView.kf.setImage(with: url)
    }
    
    private func convertDateToString(with date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        
        return dateFormatter.string(from: date)
    }
}
