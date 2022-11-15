//
//  ChattingRoomListCell.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/14.
//

import SnapKit
import Then
import UIKit

class ChattingRoomListCell: UITableViewCell {
    
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
    
    private let date = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    private let count = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(openData: OpenChattingRoomListData) {
        name.text = openData.name
        userDescription.text = openData.description
        date.text = openData.date
    }
    
    func configure(dmData: DMChattingRoomListData) {
        name.text = dmData.name
        userDescription.text = dmData.description
        date.text = dmData.date
    }
    
    private func layoutSetup() {
        
        self.contentView.addSubview(img)
        self.contentView.addSubview(name)
        self.contentView.addSubview(userDescription)
        self.contentView.addSubview(date)
        
        img.snp.makeConstraints { make in
            make.top.leading.equalTo(self.contentView).offset(16)
            make.bottom.equalTo(self.contentView).offset(-16)
            make.width.height.equalTo(60)
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
        
        date.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(8)
            make.trailing.equalTo(self.contentView).offset(-16)
        }
        
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 0.5
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ChattingRoomListCellPreview: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let cell = ChattingRoomListCell(frame: .zero)
            cell.configure(openData: OpenChattingRoomListData(img: "", name: "Ronald Robertson", description: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.", date: "오후 2:30", count: "12"))
            return cell
        }.previewLayout(.fixed(width: 300, height: 80))
    }
}
#endif
