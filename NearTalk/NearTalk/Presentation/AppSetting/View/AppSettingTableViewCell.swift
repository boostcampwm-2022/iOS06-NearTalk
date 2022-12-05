//
//  AppSettingTableViewCell.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import UIKit

final class AppSettingTableViewCell: UITableViewCell {
    static let identifier: String = String(describing: AppSettingTableViewCell.self)
    
    let toggleSwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureToggleSwitch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.bringSubviewToFront(toggleSwitch)
        super.layoutSubviews()
    }
    
    private func configureToggleSwitch() {
        self.addSubview(self.toggleSwitch)
        toggleSwitch.isUserInteractionEnabled = true
        toggleSwitch.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func setUpCell(text: String) {
        var configuration = self.defaultContentConfiguration()
        configuration.text = text
        self.contentConfiguration = configuration
    }
}
