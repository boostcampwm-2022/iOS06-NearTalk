//
//  ProfileSettingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class MyProfileViewController: UIViewController, UITableViewDelegate {
    private let myProfileView = UIView()
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
    }
    
    private let fieldStack = UIStackView().then {
        $0.distribution = .fillProportionally
        $0.alignment = .fill
        $0.axis = .vertical
    }
    
    private let nicknameLabel = UILabel().then {
        $0.textAlignment = .natural
        $0.text = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let messageLabel = UILabel().then {
        $0.textAlignment = .natural
        $0.text = "상태 메세지"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let tableView: UITableView = UITableView()
    
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
    
    private let viewModel: any MyProfileViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureConstraint()
        self.initDataSource()
        self.setTableView()
        self.bindViewModel()
    }
    
    override func viewWillLayoutSubviews() {
        configureTableView()
        self.profileImageView.makeRounded()
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.profileImageView.makeRounded()
        self.viewModel.viewWillAppear()
        super.viewWillAppear(animated)
    }
    
    init(viewModel: any MyProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menu = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch menu {
        case .profileSetting:
            self.viewModel.moveToProfileSettingView(
                necessaryProfileComponent: .init(
                    nickName: self.nicknameLabel.text,
                    message: self.messageLabel.text,
                    image: self.profileImageView.image?.pngData() ?? self.profileImageView.image?.jpegData(compressionQuality: 1.0)))
        case .appSetting:
            self.viewModel.moveToAppSettingView()
        }
    }
}

private extension MyProfileViewController {
    func configureUI() {
        configureNavigationBar()
        view.backgroundColor = .systemBackground
        view.addSubview(myProfileView)
        view.addSubview(tableView)
        
        myProfileView.addSubview(profileImageView)
        myProfileView.addSubview(fieldStack)
        fieldStack.addArrangedSubview(nicknameLabel)
        fieldStack.addArrangedSubview(messageLabel)
    }
    
    func configureTableView() {
        self.tableView.layer.cornerRadius = 5.0
        self.tableView.layer.masksToBounds = true
        self.tableView.clipsToBounds = true
        self.tableView.separatorInset = .zero
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
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "내 프로필"
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
    
    func bindViewModel() {
        self.viewModel.nickName
            .subscribe(self.nicknameLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.viewModel.message
            .subscribe(self.messageLabel.rx.text)
            .disposed(by: self.disposeBag)
        self.viewModel.image
            .compactMap { $0 }
            .compactMap { URL(string: $0) }
            .bind(onNext: { url in
                self.profileImageView.backgroundColor = .clear
                self.profileImageView.kf.setImage(with: url)
            })
            .disposed(by: self.disposeBag)
        self.viewModel.image
            .filter { $0 == nil }
            .bind(onNext: { _ in
                self.profileImageView.backgroundColor = .lightGray
                self.profileImageView.image = nil
            })
            .disposed(by: self.disposeBag)
    }
}

enum MyProfileSection: Hashable, Sendable {
    case main
}

enum MyProfileItem: String, Hashable, Sendable, CaseIterable {
    case profileSetting = "프로필 수정"
    case appSetting = "앱 설정"
}
