//
//  FriendsListView.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class FriendsListViewController: UIViewController {
    // MARK: - UI properties
    private let tableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(FriendsListCell.self, forCellReuseIdentifier: FriendsListCell.identifier)
    }
    
    // MARK: - Properties
    
    private var dataSource: UITableViewDiffableDataSource<Int, FriendsListModel>?
    private var viewModel = FriendsListViewModel()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        configureConstraints()
    }
    
    // MARK: - Helper
    private func addSubviews() {
        self.view.addSubview(tableView)
    }

    private func configureConstraints() {
        self.configureView()
        self.configureTableView()
        self.configureNavigation()
        self.configureDatasource()
    }
    
    private func configureView() {
        self.view.backgroundColor = .systemBackground
    }
    
    private func configureTableView() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.trailing.leading.equalTo(view)
        }
    }
    
    private func configureNavigation() {
        self.navigationItem.title = "친구 목록"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapCreateChatRoomButton))
    }
    
    // 데이터소스 세팅
    private func configureDatasource() {

        self.dataSource = UITableViewDiffableDataSource<Int, FriendsListModel>(tableView: self.tableView, cellProvider: { tableView, indexPath, _ in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendsListCell.identifier, for: indexPath) as? FriendsListCell
            else { return UITableViewCell() }
            
            cell.configure(model: self.viewModel.friendsListDummyData[indexPath.row])
            
            return cell
        })
        
        self.dataSource?.defaultRowAnimation = .fade
        self.tableView.dataSource = self.dataSource
        
        // 빈 snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Int, FriendsListModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.friendsListDummyData)
        self.dataSource?.apply(snapshot)
        
    }
    
    @objc private func didTapCreateChatRoomButton() {
        print("친구 추가 이동")
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct FriendsListViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UINavigationController(rootViewController: FriendsListViewController()).showPreview(.iPhone14Pro)
    }
}
#endif
