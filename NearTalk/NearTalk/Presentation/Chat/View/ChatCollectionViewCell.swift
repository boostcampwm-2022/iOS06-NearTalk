//
//  ChatCollectionViewCell.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import Kingfisher
import RxRelay
import RxSwift
import SnapKit
import UIKit

class ChatCollectionViewCell: UICollectionViewCell {
    // MARK: - Proporty
    static let identifier = String(describing: ChatRoomListCell.self)
    var ticketsRelay: BehaviorRelay<[String: Double]>!
    private var createdAt: Date?
    private var viewModel: ChatViewModel?
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - UI Proporty
    private let textView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16.0)
        view.textContainer.maximumNumberOfLines = 0
        view.textColor = .label
        view.backgroundColor = .white
        view.layer.cornerRadius = 20.0
        view.layer.masksToBounds = false
        view.isEditable = false
        view.isScrollEnabled = false
        view.textContainerInset = .init(top: 13, left: 13, bottom: 13, right: 13)
        view.sizeToFit()
        return view
    }()
    
    private lazy var nameLabel: UILabel = UILabel().then { label in
        label.font = .systemFont(ofSize: 12)
    }
    
    private let timeLabel: UILabel = UILabel().then { label in
        label.font = .systemFont(ofSize: 8)
    }
    
    private let countOfUnreadMessagesLabel: UILabel = UILabel().then { label in
        label.tintColor = .primaryColor
        label.font = .systemFont(ofSize: 8)
    }
    
    private lazy var profileImageView: UIImageView = UIImageView().then { imageView in
        imageView.layer.cornerRadius = 20.0
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "ChatLogo")
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
        self.nameLabel.text = ""
        self.timeLabel.text = ""
        self.textView.text = ""
        self.countOfUnreadMessagesLabel.text = ""
        self.profileImageView.image = nil
        self.textView.text = nil
        
        self.disposeBag = DisposeBag()
    }

    func configure(messageItem: MessageItem, tickets: BehaviorRelay<[String: Double]>, completion: (() -> Void)? = nil) {
        self.profileImageView.image = nil
        let isInComing = messageItem.type == .receive
        
        self.createdAt = messageItem.createdAt
        self.ticketsRelay = tickets
        self.bindTicket()
        
        self.textView.backgroundColor = isInComing ? .secondaryBackground : .primaryColor
        self.textView.textColor = isInComing ? .label : .whiteLabel
        self.textView.text = messageItem.message
        self.nameLabel.text = isInComing ? messageItem.userName : ""
        self.timeLabel.text = self.convertDateToString(with: messageItem.createdAt)
                
        if isInComing {
            self.setImage(path: messageItem.imagePath)
            
            self.textView.snp.remakeConstraints { make in
                make.leading.equalTo(profileImageView.snp.trailing).offset(5)
                make.top.equalTo(nameLabel.snp.bottom).offset(2)
                make.width.lessThanOrEqualTo(250)
                make.bottom.equalToSuperview()
            }
            
            self.timeLabel.snp.remakeConstraints { make in
                make.leading.equalTo(self.textView.snp.trailing).offset(5)
                make.bottom.equalToSuperview()
            }
            
            self.countOfUnreadMessagesLabel.snp.remakeConstraints { make in
                make.leading.equalTo(self.textView.snp.trailing).offset(5)
                make.bottom.equalTo(self.timeLabel.snp.top)
            }
        } else {
            self.profileImageView.image = nil
            
            self.textView.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(10)
                make.top.equalToSuperview()
                make.width.lessThanOrEqualTo(250)
                make.bottom.equalToSuperview()
            }

            self.timeLabel.snp.remakeConstraints { make in
                make.trailing.equalTo(self.textView.snp.leading).inset(-5)
                make.bottom.equalToSuperview()
            }

            self.countOfUnreadMessagesLabel.snp.remakeConstraints { make in
                make.trailing.equalTo(self.textView.snp.leading).inset(-5)
                make.bottom.equalTo(self.timeLabel.snp.top)
            }
        }
    }
    
    private func addViews() {
        [nameLabel, profileImageView, textView, timeLabel, countOfUnreadMessagesLabel].forEach {
            self.contentView.addSubview($0)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(nameLabel.snp.left).inset(-5)
            make.top.equalToSuperview()
        }
        
        self.textView.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(250)
            make.bottom.equalToSuperview()
        }
        
        self.timeLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
        
        self.countOfUnreadMessagesLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.timeLabel.snp.top)
        }
    }
    
    private func setImage(path: String?) {
        guard let path = path,
              let url = URL(string: path)
        else {
            self.profileImageView.image = UIImage(named: "ChatLogo")
            return
        }
        
        self.profileImageView.kf.setImage(with: url)
    }
    
    private func convertDateToString(with date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        
        return dateFormatter.string(from: date)
    }
    
    private func bindTicket() {
        self.ticketsRelay
            .asDriver()
            .drive(onNext: { [weak self] lastUpdatedTimeOfTickets in
                guard let self,
                      let createdAt = self.createdAt else {
                    return
                }
                let count = lastUpdatedTimeOfTickets.filter({ (_, time) in
                    let lastUpdatedTime = Date(timeIntervalSince1970: time)
                    return lastUpdatedTime < createdAt
                }).count
//                print("📩 [안읽은 사람 수]: \(count)")
                if count > 0 {
                    self.countOfUnreadMessagesLabel.text = "\(count)"
                }
            })
            .disposed(by: self.disposeBag)
    }
}
