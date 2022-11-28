//
//  ChatRoomListCell.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/14.
//

import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class ChatRoomListCell: UICollectionViewCell {
    
    static let identifier = String(describing: ChatRoomListCell.self)
    
    private var viewModel: ChatRoomListViewModel?
    private var disposebag = DisposeBag()
    
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
    
    private let currentUserCount = UILabel().then {
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
        $0.textAlignment = .center
        $0.backgroundColor = .red
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 8
        $0.addArrangedSubview(self.name)
        $0.addArrangedSubview(self.currentUserCount)
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
    
    func configure(groupData: GroupChatRoomListData, viewModel: ChatRoomListViewModel) {
        self.viewModel = viewModel
        self.name.text = groupData.roomName
        self.currentUserCount.text = String((groupData.userList ?? []).count)
        self.imageLoad(path: groupData.roomImagePath)
        self.unreadMessageCount.text = String(groupData.messageCount ?? 0)
        self.bind(messageID: groupData.recentMessageID, roomID: groupData.uuid)
        self.textDate()
    }
    
    func configure(dmData: DMChatRoomListData, viewModel: ChatRoomListViewModel) {
        self.viewModel = viewModel
        self.name.text = dmData.roomName
        self.imageLoad(path: dmData.roomImagePath)
        self.unreadMessageCount.text = String(dmData.messageCount ?? 0)
        self.bind(messageID: dmData.recentMessageID, roomID: dmData.uuid)
        self.textDate()
    }
    
    // MARK: - Configure views
    private func addSubviews() {
        self.contentView.addSubview(self.img)
        self.contentView.addSubview(self.stackView2)
        self.contentView.addSubview(self.date)
        self.contentView.addSubview(self.unreadMessageCount)
    }
    
    private func configureConstraints() {
        self.img.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView).offset(16)
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(60)
        }
        
        self.date.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(8)
            make.trailing.equalTo(self.contentView).offset(-16)
        }
        
        self.stackView2.snp.makeConstraints { make in
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.date.snp.leading)
            make.centerY.equalTo(self.contentView)
        }
        
        self.unreadMessageCount.snp.makeConstraints { make in
            make.top.equalTo(self.date.snp.bottom).offset(16)
//            make.bottom.equalTo(self.contentView).offset(8)
            make.trailing.equalTo(self.contentView).offset(-16)
            make.leading.equalTo(self.stackView2.snp.trailing).offset(16)
        }
    }
    
    private func bind(messageID: String?, roomID: String?) {
        guard let messageID = messageID,
              let roomID = roomID else { return }
        self.viewModel?.getRecentMessage(messageID: messageID, roomID: roomID)
            .asObservable()
            .subscribe(onNext: { [weak self] chatMessage in
                self?.recentMessage.text = chatMessage.text
                self?.dateOperate(date: chatMessage.createdDate)
            })
            .disposed(by: disposebag)
    }
    
    private func dateOperate(date: Date?) {
        guard let date = date
        else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let convertDate = dateFormatter.string(from: date)
        
        self.date.text = convertDate
        // 날짜비교
    }
    
    private func textDate() {
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let convertDate = dateFormatter.string(from: nowDate)
        
        self.date.text = convertDate
    }
    
    private func imageLoad(path: String?) {
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
        let navigation = UINavigationController()
        
        let diContainer: ChatRoomListDIContainer = ChatRoomListDIContainer()
        let viewModel = diContainer.makeChatRoomListViewModel(
            actions: ChatRoomListViewModelActions(showChatRoom: { _, _ in },
                                                  showCreateChatRoom: {},
                                                  showDMChatRoomList: {},
                                                  showGroupChatRoomList: {})
        )

        let chatRoomData = ChatRoom(uuid: "123",
                                    userList: ["1", "2", "3", "4", "5", "6"],
                                    roomImagePath: "",
                                    roomName: "테스트방",
                                    accessibleRadius: 0,
                                    recentMessageID: "uuid",
                                    messageCount: 5)
                                    
        let groupData = GroupChatRoomListData(data: chatRoomData)
        
        UIViewPreview {
            let cell = ChatRoomListCell(frame: .zero)
            cell.configure(groupData: groupData, viewModel: viewModel)
            return cell
        }.previewLayout(.fixed(width: 393, height: 393 * 0.2))
    }
}
#endif
