//
//  ProfileSettingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class MyProfileViewController: UIViewController {
    // MARK: - UI properties
    private let myProfileView: MyProfileView = MyProfileView()
    
    private let tableView: UITableView = UITableView()
    
    // MARK: - Properties
    private lazy var dataSource: UITableViewDiffableDataSource<MyProfileSection, MyProfileItem> = {
        UITableViewDiffableDataSource<MyProfileSection, MyProfileItem>(tableView: self.tableView) { _, _, item in
            let cell = UITableViewCell()
            var config = cell.defaultContentConfiguration()
            config.text = item.rawValue
            config.textProperties.alignment = .natural
            config.textProperties.font = UIFont.systemFont(ofSize: 16)
            cell.contentConfiguration = config
            cell.backgroundColor = .secondaryBackground
            cell.selectionStyle = .none
            return cell
        }
    }()
    
    private let viewModel: any MyProfileViewModel
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(viewModel: any MyProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.snp.remakeConstraints { (make) in
            make.top.equalTo(myProfileView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(self.tableView.visibleCells.reduce(0, { partialResult, cell in
                partialResult + cell.frame.height
            }))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.viewWillAppear()
        super.viewWillAppear(animated)
    }
}

extension MyProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectRow(menu: self.dataSource.itemIdentifier(for: indexPath))
    }
}

private extension MyProfileViewController {
    // MARK: - Helpers
    func configureUI() {
        configureNavigationBar()
        view.backgroundColor = .primaryBackground
        view.addSubview(myProfileView)
        view.addSubview(tableView)
    }
    
    func configureTableView() {
        self.tableView.layer.cornerRadius = 5.0
        self.tableView.layer.masksToBounds = true
        self.tableView.clipsToBounds = true
        self.tableView.separatorInset = .zero
    }
    
    func configureConstraint() {
        myProfileView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(96)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(myProfileView.snp.bottom).offset(20)
            $0.bottom.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(10)
        }
    }
    
    func configureNavigationBar() {
        let newNavBarAppearance: UINavigationBarAppearance = UINavigationBarAppearance()

        newNavBarAppearance.configureWithOpaqueBackground()
        newNavBarAppearance.backgroundColor = .secondaryBackground
        
        self.navigationController?
            .navigationBar
            .topItem?
            .backButtonDisplayMode = .minimal
        self.navigationController?.navigationBar.tintColor = .label

        self.navigationItem.title = "마이 프로필"
        self.navigationItem.hidesBackButton = true
        self.navigationItem.standardAppearance = newNavBarAppearance
        self.navigationItem.compactAppearance = newNavBarAppearance
        self.navigationItem.scrollEdgeAppearance = newNavBarAppearance
        self.navigationItem.compactScrollEdgeAppearance = newNavBarAppearance
    }
    
    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self.dataSource
        self.tableView.backgroundColor = .systemBackground
    }
    
    func initDataSource() {
        var snapshot: NSDiffableDataSourceSnapshot<MyProfileSection, MyProfileItem> = self.dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(MyProfileItem.allCases, toSection: .main)
        self.dataSource.apply(snapshot)
    }
    
    func bindViewModel() {
        self.viewModel.nickName
            .drive(self.myProfileView.nickName)
            .disposed(by: self.disposeBag)
        
        self.viewModel.message
            .drive(self.myProfileView.message)
            .disposed(by: self.disposeBag)
        
        self.viewModel.image
            .map { imageBinary in
                if let binary = imageBinary {
                    return UIImage(data: binary)
                } else {
                    return MyProfileView.defaultProfileImage
                }
            }
            .drive(self.myProfileView.image)
            .disposed(by: self.disposeBag)
    }
}
