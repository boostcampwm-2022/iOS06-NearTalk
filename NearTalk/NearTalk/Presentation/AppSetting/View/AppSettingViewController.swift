//
//  AppSettingView.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import SnapKit
import UIKit

final class AppSettingViewController: UIViewController, UITableViewDelegate {
    private let tableView = UITableView()
    
    private lazy var dataSource: UITableViewDiffableDataSource<AppSettingSection, AppSettingItem> = {
        UITableViewDiffableDataSource<AppSettingSection, AppSettingItem>(tableView: self.tableView) { _, _, item in
            let cell: UITableViewCell

            if item == .alarmOnOff {
                cell = AppSettingTableViewCell()
            } else {
                cell = UITableViewCell()
            }

            var config = cell.defaultContentConfiguration()
            config.text = item.rawValue
            config.textProperties.alignment = .natural
            config.textProperties.font = UIFont.systemFont(ofSize: 16)
            cell.contentConfiguration = config
            cell.backgroundColor = .systemGray6
            cell.selectionStyle = .none
            return cell
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
        initDataSource()
        setTableView()
    }
}

private extension AppSettingViewController {
    func configureUI() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .systemGray5
        navigationItem.title = "앱 설정"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
    }
    
    func configureConstraint() {
        tableView.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(30)
            make.bottom.equalToSuperview()
        }
    }
    
    func setTableView() {
        tableView.delegate = self
        tableView.register(AppSettingTableViewCell.self, forCellReuseIdentifier: AppSettingTableViewCell.identifier)
        tableView.dataSource = self.dataSource
        self.tableView.backgroundColor = .systemBackground
        self.tableView.isScrollEnabled = false
    }
    
    func initDataSource() {
        var snapshot = self.dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(AppSettingItem.allCases, toSection: .main)
        self.dataSource.apply(snapshot)
    }
}

enum AppSettingSection: Hashable & Sendable {
    case main
}

enum AppSettingItem: String, Hashable & Sendable & CaseIterable {
    case logout = "로그아웃"
    case drop = "탈퇴"
    case developerInfo = "개발자 정보"
    case alarmOnOff = "알람 on/off"
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct AppSettingViewController_Preview: PreviewProvider {
    static var previews: some View {
        UINavigationController(rootViewController: AppSettingViewController()).showPreview(.iPhoneSE3)
    }
}
#endif
