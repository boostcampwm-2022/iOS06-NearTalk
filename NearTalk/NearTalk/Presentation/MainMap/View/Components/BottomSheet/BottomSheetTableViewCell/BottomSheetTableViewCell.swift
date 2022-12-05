//
//  BottomSheetTableViewCell.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/17.
//

import SnapKit
import Then
import UIKit

final class BottomSheetTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: BottomSheetTableViewCell.self)
    
    private let chatRoomImage = UIImageView().then {
        $0.layer.cornerRadius = 30
        $0.image = UIImage(systemName: "photo")
    }
    
    private lazy var infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 4
        $0.addArrangedSubview(self.infoHeaderView)
        $0.addArrangedSubview(self.chatRoomDescription)
    }
    
    private lazy var infoHeaderView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.addArrangedSubview(self.chatRoomName)
        $0.addArrangedSubview(self.chatRoomDistance)
    }
    
    private let chatRoomName = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private let chatRoomDistance = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private let chatRoomDescription = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.numberOfLines = 0
    }
    
    private let chatRoomEnterButton = UIButton().then {
        let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 24)
        let buttonImage = UIImage(systemName: "arrow.right.circle",
                                  withConfiguration: buttonImageConfig)
        $0.setImage(buttonImage, for: .normal)
    }
    
    // MARK: - Lifecycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubviews()
        self.configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been impl")
    }
    
    private func addSubviews() {
        self.contentView.addSubview(self.chatRoomImage)
        self.contentView.addSubview(self.infoStackView)
        self.contentView.addSubview(self.chatRoomEnterButton)
    }
    
    private func configureConstraints() {
        self.chatRoomImage.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView).offset(16)
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(60)
        }
        
        self.chatRoomEnterButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView).offset(-16)
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(40)
        }
        
        self.infoStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.chatRoomImage.snp.trailing).offset(16)
            make.trailing.equalTo(self.chatRoomEnterButton.snp.leading).offset(-8)
            make.top.bottom.equalTo(self.contentView).inset(8)
        }
    }
    
    private func configureImg() {
    }
}

// MARK: - Bind
extension BottomSheetTableViewCell {
    public func bind(to data: ChatRoom) {
        self.chatRoomName.text = data.roomName ?? "Ronald Robertson"
        self.chatRoomDistance.text = "1.5 km"
        self.chatRoomDescription.text = data.roomDescription ?? "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum."
    }
}
