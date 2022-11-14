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
    
    let img = UIImageView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "photo")
    }
    
    let name = UILabel().then {
        $0.font = UIFont(name: "text", size: 18)
    }
    
    let userDescription = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.numberOfLines = 2
        
    }
    
    let date = UILabel().then {
        $0.numberOfLines = 2
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    let count = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(data: ChattingRoomListData) {
        name.text = data.name
        userDescription.text = data.description
        date.text = data.date
    }
    
    func layoutSetup() {
        
        self.contentView.addSubview(img)
        self.contentView.addSubview(name)
        self.contentView.addSubview(userDescription)
        self.contentView.addSubview(date)
        
        img.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(16)
            make.leading.equalTo(self.contentView).offset(16)
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
        
        date.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(8)
            make.trailing.equalTo(self.contentView).offset(-16)
            
        }
        
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 0.5
        
    }
    
}

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//struct ChattingRoomListCellPreview: PreviewProvider {
//    static var previews: some View {
//        UIViewPreview {
//            let cell = ChattingRoomListCell(frame: .zero)
//            cell.configure(data: ChattingRoomListData(img: "", name: "Ronald Robertson", description: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.", date: "오후 2:30", count: "12"))
//            return cell
//        }.previewLayout(.fixed(width: 300, height: 120))
//    }
//}
//#endif
