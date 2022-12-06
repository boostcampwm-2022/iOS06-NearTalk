//
//  ChatRoomListCell.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/14.
//

import CoreLocation
import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class ChatRoomListCell: UICollectionViewCell {
    
    static let identifier = String(describing: ChatRoomListCell.self)
    
    private var uuid: String?
    private var viewModel: ChatRoomListViewModel?
    private var disposeBag = DisposeBag()
    
    override var isSelected: Bool {
        didSet {
            if let uuid = self.uuid, isSelected {
                self.viewModel?.didSelectItem(at: uuid)
            }
        }
    }
    
    // MARK: - UI properties
    
    private let view = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = UIColor.tertiaryLabel?.withAlphaComponent(0.5)
    }
    
    private let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40.0))).then { symbol in
        symbol.tintColor = .label
    }
    
    private let img = UIImageView().then {
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "photo")
    }
    
    private lazy var name = UILabel().then {
        $0.font = UIFont(name: "text", size: 16)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private let currentUserCount = UILabel().then {
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    private let recentMessage = UILabel().then {
        
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.numberOfLines = 2
    }
    
    private let date = UILabel().then {
        $0.textAlignment = .right
        $0.font = UIFont.systemFont(ofSize: 12)
    }
    
    private let unreadMessageCount = BasePaddingLabel(padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)).then { label in
        label.backgroundColor = UIColor(named: "primaryColor")
        label.isHidden = true
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = 12
        label.textAlignment = .center
    }
    
    // MARK: - Lifecycles
    
    override func prepareForReuse() {
        self.view.isHidden = true
        self.lockIcon.isHidden = true
        self.name.text = nil
        self.currentUserCount.text = nil
        self.recentMessage.text = nil
        self.unreadMessageCount.isHidden = true
        self.date.text = nil
        self.img.image = nil
    }
    
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
        self.uuid = groupData.uuid
        self.name.text = groupData.roomName
        self.currentUserCount.text = String((groupData.userList ?? []).count)
        self.imageLoad(path: groupData.roomImagePath)
        self.recentMessage.text = groupData.recentMessageText == nil ? "새로 생성된 방입니다" : groupData.recentMessageText
        self.unreadMessageCheck(roomID: groupData.uuid ?? "", number: groupData.messageCount)
        self.dateOperate(date: groupData.recentMessageDate)
    }
    
    func configure(dmData: DMChatRoomListData, viewModel: ChatRoomListViewModel) {
        self.viewModel = viewModel
        self.uuid = dmData.uuid
        self.name.text = dmData.roomName
        self.imageLoad(path: dmData.roomImagePath)
        self.recentMessage.text = dmData.recentMessageText == nil ? "새로 생성된 방입니다" : dmData.recentMessageText
        self.unreadMessageCheck(roomID: dmData.uuid ?? "", number: dmData.messageCount)
        self.dateOperate(date: dmData.recentMessageDate)
    }
    
    // MARK: - Configure views
    private func addSubviews() {
        self.contentView.addSubview(self.img)
        self.contentView.addSubview(self.name)
        self.contentView.addSubview(self.recentMessage)
        self.contentView.addSubview(self.date)
        self.contentView.addSubview(self.unreadMessageCount)
        self.contentView.addSubview(self.view)
        self.contentView.addSubview(self.lockIcon)
    }
    
    private func configureConstraints() {
        self.img.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView).offset(16)
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(60)
        }
        
        self.date.snp.makeConstraints { make in
            make.top.equalTo(self.img.snp.top).offset(3)
            make.trailing.equalTo(self.contentView).offset(-24)
            make.width.equalTo(68)
        }
        
        self.unreadMessageCount.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView).offset(-24)
            make.bottom.equalTo(self.img.snp.bottom).offset(-8)
            make.height.equalTo(28)
        }
        
        self.name.snp.makeConstraints { make in
            make.top.equalTo(self.img.snp.top).offset(3)
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.date.snp.leading)
            make.height.equalTo(18)
        }
        
        self.recentMessage.snp.makeConstraints { make in
            make.top.equalTo(self.name.snp.bottom).offset(4)
            make.leading.equalTo(self.img.snp.trailing).offset(16)
            make.trailing.equalTo(self.date.snp.leading)
        }
        
        self.currentUserCount.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        
        self.view.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.contentView).inset(4)
            make.leading.trailing.equalTo(self.contentView).inset(12)
        }
        
        self.lockIcon.snp.makeConstraints { make in
            make.center.equalTo(self.contentView)
        }
        
    }
    
    private func dateOperate(date: Date?) {
        guard let date = date
        else { return }
        
        self.date.text = convertDate(date: date)
    }
    
    private func convertDate(date: Date) -> String {
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        
        let convertDate = dateFormatter.string(from: date)
        let convertNowDate = dateFormatter.string(from: nowDate)
        
        if convertDate.prefix(4) != convertNowDate.prefix(4) {
            dateFormatter.dateFormat = "yyyy.MM.dd"
            return dateFormatter.string(from: date)
        } else if convertDate.prefix(8) != convertNowDate.prefix(8) {
            dateFormatter.dateFormat = "MM.dd"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
    }
    
    private func testDate() {
        let nowDate = Date()
        self.date.text = self.convertDate(date: nowDate)
    }
    
    private func unreadMessageCheck(roomID: String, number: Int?) {
        guard let viewModel = self.viewModel else {
            self.unreadMessageCount.isHidden = true
            return
        }
        
        viewModel.getUserChatRoomTicket(roomID: roomID)
            .subscribe { event in
                switch event {
                case .success(let ticket):
                    guard let lastRoomMessageCount = ticket.lastRoomMessageCount,
                          let number = number,
                          number > lastRoomMessageCount else {
                        
                        DispatchQueue.main.async {
                            self.unreadMessageCount.isHidden = true
                        }
                        
                        return
                    }
                    DispatchQueue.main.async {
                        self.unreadMessageCount.text = String(number - lastRoomMessageCount)
                        self.unreadMessageCount.isHidden = false
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func imageLoad(path: String?) {
        guard let path = path, let url = URL(string: path) else {
            img.image = UIImage(named: "ChatLogo")
            return
        }
        
        img.kf.setImage(with: url)
        if img.image == nil {
            img.image = UIImage(named: "ChatLogo")
        }
    }
    
    private func distanceOperate(distance: Double) {
        UserDefaults.standard.rx
            .observe(String.self, "CurrentUserLocation")
            .subscribe(onNext: { (value) in
            })
            .disposed(by: disposeBag)
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ChatRoomListCellPreview: PreviewProvider {
    static var previews: some View {
        let diContainer: ChatRoomListDIContainer = ChatRoomListDIContainer()
        let viewModel = diContainer.makeChatRoomListViewModel(
            actions: ChatRoomListViewModelActions(showChatRoom: { _ in },
                                                  showCreateChatRoom: {},
                                                  showDMChatRoomList: {},
                                                  showGroupChatRoomList: {},
                                                  showAlert: {})
        )
        
        let chatRoomData = ChatRoom(uuid: "123",
                                    userList: ["1"],
                                    roomImagePath: "",
                                    roomName: "테스트트방테스트방",
                                    accessibleRadius: 0,
                                    recentMessageText: "테스트중테스트중테스트중테스트중",
                                    recentMessageDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()),
                                    messageCount: 4)
        
        let groupData = GroupChatRoomListData(data: chatRoomData)
        
        UIViewPreview {
            let cell = ChatRoomListCell(frame: .zero)
            cell.configure(groupData: groupData, viewModel: viewModel)
            return cell
        }.previewLayout(.fixed(width: 393, height: 393 * 0.2))
    }
}
#endif
