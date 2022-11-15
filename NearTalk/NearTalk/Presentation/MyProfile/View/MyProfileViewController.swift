//
//  ProfileSettingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import SnapKit
import Then
import UIKit

final class MyProfileViewController: UIViewController, UITableViewDelegate {
    private let myProfileView = UIView()
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .lightGray
    }
    
    private let fieldStack = UIStackView().then {
        $0.distribution = .fillProportionally
        $0.alignment = .fill
        $0.axis = .vertical
    }
    
    private let nicknameField = UITextField().then {
        $0.textAlignment = .natural
        $0.placeholder = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let messageField = UITextField().then {
        $0.textAlignment = .natural
        $0.placeholder = "상태 메세지"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let tableView = UITableView()
    
    private lazy var dataSource: UITableViewDiffableDataSource<MyProfileSection, MyProfileItem> = {
        UITableViewDiffableDataSource<MyProfileSection, MyProfileItem>(tableView: self.tableView) { _, _, item in
            let cell = UITableViewCell()
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.layer.cornerRadius = 5.0
        self.tableView.layer.masksToBounds = true
        self.tableView.clipsToBounds = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.clipsToBounds = true
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
}

private extension MyProfileViewController {
    func configureUI() {
        configureNavigationBar()
        
        view.addSubview(myProfileView)
        view.addSubview(tableView)
        
        myProfileView.addSubview(profileImageView)
        myProfileView.addSubview(fieldStack)
        fieldStack.addArrangedSubview(nicknameField)
        fieldStack.addArrangedSubview(messageField)
    }
    
    func configureConstraint() {
        myProfileView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(96)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(myProfileView.snp.bottom).offset(20)
            make.bottom.horizontalEdges.equalToSuperview().inset(10)
        }
        
        profileImageView.snp.makeConstraints { (make) in
            make.leading.verticalEdges.equalToSuperview()
            make.width.equalTo(profileImageView.snp.height)
        }
        
        fieldStack.snp.makeConstraints { (make) in
            make.verticalEdges.trailing.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .systemGray5
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "내 프로필"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
    }
    
    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self.dataSource
        self.tableView.backgroundColor = .systemBackground
    }
    
    func initDataSource() {
        var snapshot = self.dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(MyProfileItem.allCases, toSection: .main)
        self.dataSource.apply(snapshot)
    }
}

enum MyProfileSection: Hashable & Sendable {
    case main
}

enum MyProfileItem: String, Hashable & Sendable & CaseIterable {
    case profileSetting = "프로필 수정"
    case appSetting = "앱 설정"
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

// swiftlint:disable: type_name
struct MyProfileViewController_Preview: PreviewProvider {
    static var previews: some View {
        UINavigationController(rootViewController: MyProfileViewController()).showPreview(.iPhone14Pro)
        UINavigationController(rootViewController: MyProfileViewController()).showPreview(.iPhoneSE3)
    }
}
#endif
