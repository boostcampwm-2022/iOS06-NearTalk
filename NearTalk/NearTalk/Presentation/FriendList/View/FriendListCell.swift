//
//  FriendsListCell.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Kingfisher
import SnapKit
import Then
import UIKit

final class FriendListCell: UICollectionViewCell {
    
    static let identifier = String(describing: ChatRoomListCell.self)
    private var viewModel: FriendListViewModel?
    private var uuid: String?
    
    override var isSelected: Bool {
        didSet {
            if let uuid = self.uuid, isSelected {
                self.viewModel?.didSelectItem(userUUID: uuid)
            }
        }
    }
    
    // MARK: - UI properties
    private let img = UIImageView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "photo")
    }
    
    private let name = UILabel().then {
        $0.font = UIFont(name: "text", size: 18)
        $0.numberOfLines = 1
    }
    
    private let userDescription = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.numberOfLines = 1
    }
    
    private lazy var stactView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 4
        $0.addArrangedSubview(self.name)
        $0.addArrangedSubview(self.userDescription)
    }
    
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.configureConstraints()
    }
    
    // MARK: - Helper
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: Friend, viewModel: FriendListViewModel) {
        self.viewModel = viewModel
        self.uuid = model.userID
        self.name.text = model.username
        self.userDescription.text = model.statusMessage
        self.imageLoad(path: model.profileImagePath)
    }
    
    func imageLoad(path: String?) {
        guard let path = path,
              let url = URL(string: path)
        else {
            img.image = UIImage(systemName: "photo")
            return
        }
        
        img.kf.setImage(with: url)
        if img.image == nil {
            img.image = UIImage(systemName: "photo")
        }
    }
    
    private func addSubviews() {
        self.contentView.addSubview(img)
        self.contentView.addSubview(stactView)
    }
    
    private func configureConstraints() {
        self.configureImg()
    }
    
    private func configureImg() {
        self.img.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView).offset(16)
            make.centerY.equalTo(self.contentView)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        self.stactView.snp.makeConstraints { make in
            make.leading.equalTo(self.img.snp.trailing).offset(8)
            make.trailing.equalTo(self.contentView).offset(-16)
            make.centerY.equalTo(self.contentView)
        }
    }
}

