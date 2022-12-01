//
//  AppSettingView.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class AppSettingViewController: UIViewController, UITableViewDelegate {
    private let tableView = UITableView()
    
    private lazy var dataSource: UITableViewDiffableDataSource<AppSettingSection, AppSettingItem> = {
        UITableViewDiffableDataSource<AppSettingSection, AppSettingItem>(tableView: self.tableView) { _, _, item in
            let cell: UITableViewCell

            if item == .alarmOnOff {
                let notiCell = AppSettingTableViewCell()
                self.viewModel.notificationOnOffSwitch
                    .bind(to: notiCell.toggleSwitch.rx.isOn)
                    .disposed(by: self.disposeBag)
                notiCell.toggleSwitch.rx.value.changed.bind { [weak self] toggle in
                    self?.viewModel.notificationSwitchToggled(on: toggle)
                }
                .disposed(by: self.disposeBag)
                cell = notiCell
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
    
    override func viewDidLayoutSubviews() {
        self.viewModel.viewWillAppear()
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.viewWillAppear()
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.tableRowSelected(item: self.dataSource.itemIdentifier(for: indexPath))
    }
        
    private let viewModel: any AppSettingViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(viewModel: any AppSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AppSettingViewController {
    func configureUI() {
        navigationItem.title = "앱 설정"
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
        tableView.separatorInset = .zero
        self.tableView.isScrollEnabled = false
    }
    
    func initDataSource() {
        var snapshot = self.dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(AppSettingItem.allCases, toSection: .main)
        self.dataSource.apply(snapshot)
    }
}
