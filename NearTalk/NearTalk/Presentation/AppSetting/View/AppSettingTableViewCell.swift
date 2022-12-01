//
//  AppSettingTableViewCell.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import UIKit

final class AppSettingTableViewCell: UITableViewCell {
    let toggleSwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryView = toggleSwitch
        toggleSwitch.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        self.bringSubviewToFront(toggleSwitch)
        super.layoutSubviews()
    }
    
    func setUpCell(text: String) {
        var configuration = self.defaultContentConfiguration()
        configuration.text = text
        self.contentConfiguration = configuration
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static let identifier: String = String(describing: AppSettingTableViewCell.self)
}
