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
    
    private let name = UILabel().then {
        $0.font = UIFont(name: "text", size: 18)
        $0.numberOfLines = 1
    }
    
    private lazy var stactView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 4
        $0.addArrangedSubview(self.name)
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
        self.contentView.addSubview(stactView)
    }
    
    private func configureConstraints() {
        self.configureImg()
    }
    
    private func configureImg() {
        self.stactView.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView).offset(-16)
            make.centerY.equalTo(self.contentView)
        }
    }
}

// MARK: - Utils
extension BottomSheetTableViewCell {
    public func bind(to data: ChatRoom) {
        print("\(data.location?.longitude), \(data.location?.latitude)")
        name.text = "\(data.location?.longitude), \(data.location?.latitude)"
    }
}
