//
//  ChatCollectionViewCell.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

import SnapKit

class ChatCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: ChatRoomListCell.self)
    
    var message: String? {
        didSet {
            label.text = message
        }
    }
    
    var textAlignment: Bool? {
        didSet {
            label.textAlignment = textAlignment == true ?  .right : .left
        }
    }
    
    private let label: UILabel = UILabel().then { label in
        label.text = " "
        label.font = UIFont.systemFont(ofSize: 16)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addViews()
        self.backgroundColor = .yellow
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addViews()
    }
    
    private func addViews() {
        self.addSubview(label)
        
        self.label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
