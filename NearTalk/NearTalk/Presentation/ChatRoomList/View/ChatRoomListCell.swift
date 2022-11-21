//
//  ChatRoomListCell.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/14.
//

import SnapKit
import Then
import UIKit

class ChatRoomListCell: UITableViewCell {
    
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
    
    private let userDescription = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.numberOfLines = 2
    }
    
    private let date = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    private let count = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 12)
        
    }
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 4
        $0.addArrangedSubview(self.name)
        $0.addArrangedSubview(self.count)
    }
    
    // MARK: - Lifecycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        configureConstraints()
        configureContentView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(groupData: GroupChatRoomListData) {
        self.name.text = groupData.name
        self.userDescription.text = groupData.description
        self.date.text = groupData.date
        self.count.text = groupData.count
    }
    
    func configure(dmData: DMChatRoomListData) {
        self.name.text = dmData.name
        self.userDescription.text = dmData.description
        self.date.text = dmData.date
        self.count.text = nil
    }
    
    // MARK: - Configure views
    private func addSubviews() {
        self.contentView.addSubview(self.img)
        self.contentView.addSubview(self.stackView)
        self.contentView.addSubview(self.userDescription)
        self.contentView.addSubview(self.date)
    }
    
    private func configureConstraints() {
        img.snp.makeConstraints { make in
            make.top.leading.equalTo(self.contentView).offset(16)
            make.bottom.equalTo(self.contentView).offset(-16)
            make.width.height.equalTo(60)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(16)
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.contentView).offset(-12)
            make.height.equalTo(20)
        }
        
        userDescription.snp.makeConstraints { make in
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.contentView).offset(-16)
            make.bottom.equalTo(self.contentView).offset(-16)
            make.height.equalTo(40)
        }
        
        date.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(8)
            make.trailing.equalTo(self.contentView).offset(-16)
        }
    }
    
    private func configureContentView() {
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.borderWidth = 0.5
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
        }.previewLayout(.fixed(width: 400, height: 100))
    }
}
#endif
