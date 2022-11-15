//
//  FriendsListCell.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import SnapKit
import Then
import UIKit

class FriendsListCell: UITableViewCell {
    
    static let identifier = String(describing: ChattingRoomListCell.self)
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: FriendsListModel) {
        name.text = model.name
        userDescription.text = model.description
    }

    private func layoutSetup() {
        self.contentView.addSubview(img)
        self.contentView.addSubview(name)
        self.contentView.addSubview(userDescription)
        
        img.snp.makeConstraints { make in
            make.top.leading.equalTo(self.contentView).offset(16)
            make.bottom.equalTo(self.contentView).offset(-16)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        name.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(16)
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.contentView).offset(-16)
            make.height.equalTo(20)
        }
        
        userDescription.snp.makeConstraints { make in
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.contentView).offset(-16)
            make.bottom.equalTo(self.contentView).offset(-16)
            make.height.equalTo(40)
        }
        
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 0.5
    }
    
}
