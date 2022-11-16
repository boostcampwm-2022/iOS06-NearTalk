//
//  FriendsListCell.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import SnapKit
import Then
import UIKit

final class FriendsListCell: UITableViewCell {
    
    static let identifier = String(describing: ChattingRoomListCell.self)
    
    // MARK: - UI properties
    private let img = UIImageView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "photo")
    }
    
    private let name = UILabel().then {
        $0.font = UIFont(name: "text", size: 18)
    }
    
    private let userDescription = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.numberOfLines = 2
    }
    
    // MARK: - Lifecycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubviews()
        self.configureConstraints()
        
    }
    
    // MARK: - Helper
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: FriendsListModel) {
        self.name.text = model.name
        self.userDescription.text = model.description
    }
 
    private func addSubviews() {
        self.contentView.addSubview(img)
        self.contentView.addSubview(name)
        self.contentView.addSubview(userDescription)
    }
    
    private func configureConstraints() {
        configureImg()
        configureName()
        configureuserDescription()
        configurContentView()
    }
    
    private func configureImg() {
        self.img.snp.makeConstraints { make in
            make.top.leading.equalTo(self.contentView).offset(16)
            make.bottom.equalTo(self.contentView).offset(-16)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
    }
    
    private func configureName() {
        self.name.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(16)
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.contentView).offset(-16)
            make.height.equalTo(20)
        }
    }
    
    private func configureuserDescription() {
        self.userDescription.snp.makeConstraints { make in
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.contentView).offset(-16)
            make.bottom.equalTo(self.contentView).offset(-16)
            make.height.equalTo(40)
        }
    }
    
    private func configurContentView() {
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.borderWidth = 0.5
    }
    
}
