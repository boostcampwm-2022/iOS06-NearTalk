//
//  ChatRoomListCell.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/14.
//

import SnapKit
import Then
import UIKit

class ChatRoomListCell: UICollectionViewCell {
    
    static let identifier = String(describing: ChatRoomListCell.self)
    
    // MARK: - UI properties
    private let img = UIImageView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "photo")
    }
    
    private lazy var name = UILabel().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.sizeToFit()
        $0.font = UIFont(name: "text", size: 18)
    }
    
    private let count = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private let recentMessage = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.numberOfLines = 2
    }
    
    private let date = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10)
    }
    
    private let unreadMessageCount = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 8
        $0.addArrangedSubview(self.name)
        $0.addArrangedSubview(self.count)
    }
    
    private lazy var stackView2 = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .leading
        $0.spacing = 4
        $0.addArrangedSubview(self.stackView)
        $0.addArrangedSubview(self.recentMessage)
    }
    
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(groupData: GroupChatRoomListData) {
        self.name.text = groupData.name
        self.recentMessage.text = groupData.description
        self.date.text = groupData.date
        self.count.text = groupData.count
        self.imageLoad(path: groupData.img)
    }
    
    func configure(dmData: DMChatRoomListData) {
        self.name.text = dmData.name
        self.recentMessage.text = dmData.description
        self.date.text = dmData.date
        self.count.text = nil
        self.imageLoad(path: dmData.img)
    }
    
    // MARK: - Configure views
    private func addSubviews() {
        self.contentView.addSubview(self.img)
        self.contentView.addSubview(self.stackView2)
        self.contentView.addSubview(self.date)
    }
    
    private func configureConstraints() {
        img.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView).offset(16)
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(60)
        }
        
        date.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(8)
            make.trailing.equalTo(self.contentView).offset(-16)
        }
        
        stackView2.snp.makeConstraints { make in
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.date.snp.leading)
            make.centerY.equalTo(self.contentView)
        }
    }
    
    func dataOperator() {
        
    }
    
    func imageLoad(path: String?) {
        guard let path = path,
              let url = URL(string: path)
        else {
            img.image = UIImage(systemName: "photo")
            return
        }
        
        img.kf.setImage(with: URL(string: "주소: \(url)"))
        if img.image == nil {
            img.image = UIImage(systemName: "photo")
        }
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ChatRoomListCellPreview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let cell = ChatRoomListCell(frame: .zero)
            cell.configure(groupData: GroupChatRoomListData(data: ChatRoom(userList: ["1", "2", "3", "4", "5", "6"],
                                                                           roomName: "Ronald Robertson",
                                                                           roomDescription: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.")))
            return cell
        }.previewLayout(.fixed(width: 393, height: 393 * 0.2))
    }
}
#endif
