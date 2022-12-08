//
//  ThemeSettingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/08.
//

import RxCocoa
import RxSwift
import UIKit

final class ThemeSettingViewController: UIViewController {
    private let tableView: UITableView = UITableView()
    
    private let viewModel: any ThemeSettingViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private lazy var dataSource: UITableViewDiffableDataSource<ThemeSettingSection, AppTheme> = {
        UITableViewDiffableDataSource<ThemeSettingSection, AppTheme>(tableView: self.tableView) { _, _, item in
            let cell: UITableViewCell = UITableViewCell()
            var config: UIListContentConfiguration = cell.defaultContentConfiguration()

            config.text = item.rawValue
            config.textProperties.alignment = .natural
            config.textProperties.font = UIFont.systemFont(ofSize: 16)
            cell.contentConfiguration = config
            cell.backgroundColor = .secondaryBackground
            cell.selectionStyle = .none
            cell.accessoryView = UIImageView(image: UIImage(
                systemName: "checkmark.circle.fill",
                withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.primaryColor ?? .systemOrange])))
            
            self.viewModel.curTheme
                .map { $0.rawValue }
                .drive(onNext: {
                    let label: String? = (cell.contentConfiguration as? UIListContentConfiguration)?.text
                    let hidden: Bool = label != $0
                    cell.accessoryView?.isHidden = hidden
                })
                .disposed(by: self.disposeBag)
            return cell
        }
    }()
    
    init(viewModel: any ThemeSettingViewModel) {
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
        self.configureTableView()
        self.configureNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.snp.remakeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(15)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(self.tableView.visibleCells.reduce(0, { partialResult, cell in
                partialResult + cell.frame.height
            }))
        }
    }
}

extension ThemeSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectTheme(item: self.dataSource.itemIdentifier(for: indexPath))
    }
}

private extension ThemeSettingViewController {
    func configureUI() {
        navigationItem.title = "테마 설정"
        view.addSubview(tableView)
        view.backgroundColor = .primaryBackground
    }
    
    func configureNavigationBar() {
        let newNavBarAppearance: UINavigationBarAppearance = UINavigationBarAppearance()
        newNavBarAppearance.configureWithOpaqueBackground()
        newNavBarAppearance.backgroundColor = .secondaryBackground
        
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationItem.standardAppearance = newNavBarAppearance
        self.navigationItem.compactAppearance = newNavBarAppearance
        self.navigationItem.scrollEdgeAppearance = newNavBarAppearance
        self.navigationItem.compactScrollEdgeAppearance = newNavBarAppearance
    }
    
    func configureConstraint() {
        tableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(15)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            $0.bottom.equalToSuperview()
        }
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.register(
            AppSettingTableViewCell.self,
            forCellReuseIdentifier: AppSettingTableViewCell.identifier)
        self.tableView.dataSource = self.dataSource
        self.tableView.separatorInset = .zero
        self.tableView.layer.cornerRadius = 5.0
        self.tableView.isScrollEnabled = false
    }
    
    func initDataSource() {
        var snapshot: NSDiffableDataSourceSnapshot = self.dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(AppTheme.allCases, toSection: .main)
        self.dataSource.apply(snapshot)
    }
}
