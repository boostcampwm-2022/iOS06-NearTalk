//
//  ChattingRoomListViewController.swift
//  NearTalk
//
//  Created by yw22 on 2022/11/11.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class ChattingRoomListViewController: UIViewController {
    
    private var openDataSource: UITableViewDiffableDataSource<Int, OpenChattingRoomListData>?
    private var dmDataSource: UITableViewDiffableDataSource<Int, DMChattingRoomListData>?
    private var viewModel: ChattingRoomListViewModel!
    
    private let tableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(ChattingRoomListCell.self, forCellReuseIdentifier: ChattingRoomListCell.identifier)
    }
    
    // MARK: - Lifecycle
    static func create(with viewModel: ChattingRoomListViewModel) -> ChattingRoomListViewController {
        let view = ChattingRoomListViewController()
        view.viewModel = viewModel
        return view
    }

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavi()
        setupLayout()
        configureDmDatasource()
    }
    
    // 레이아웃 셋팅
    private func setupLayout() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.trailing.leading.equalTo(view)
        }
    }
    
    // 데이터소스 세팅
    private func configureOpenDatasource() {
        
        self.openDataSource = UITableViewDiffableDataSource<Int, OpenChattingRoomListData>(tableView: self.tableView, cellProvider: { tableView, indexPath, _ in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChattingRoomListCell.identifier, for: indexPath) as? ChattingRoomListCell
            else { return UITableViewCell() }
            cell.configure(openData: self.viewModel.openChattingRoomDummyData[indexPath.row])
            return cell
        })
        
        self.openDataSource?.defaultRowAnimation = .fade
        tableView.dataSource = self.openDataSource
        
        // 빈 snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Int, OpenChattingRoomListData>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.openChattingRoomDummyData)
        self.openDataSource?.apply(snapshot)
        
    }
    
    private func configureDmDatasource() {
        self.dmDataSource = UITableViewDiffableDataSource<Int, DMChattingRoomListData>(tableView: self.tableView, cellProvider: { tableView, indexPath, _ in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChattingRoomListCell.identifier, for: indexPath) as? ChattingRoomListCell
            else { return UITableViewCell() }
            
            cell.configure(dmData: self.viewModel.dmChattingRoomDummyData[indexPath.row])
            return cell
        })
        
        self.dmDataSource?.defaultRowAnimation = .fade
        tableView.dataSource = self.dmDataSource
        
        // 빈 snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Int, DMChattingRoomListData>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.dmChattingRoomDummyData)
        self.dmDataSource?.apply(snapshot)
        
    }
    
    // 네비게이션 바
    private func configureNavi() {
        let dmChatButton: UIBarButtonItem = UIBarButtonItem(title: "DM", style: .plain, target: self, action: #selector(dmChatRoomListButtonTapped))
        let openChatButton: UIBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openChatButtonTapped))
        let creatOpenChatButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapCreateChatRoomButton))
        
        self.navigationItem.leftBarButtonItems = [dmChatButton, openChatButton]
        self.navigationItem.rightBarButtonItem = creatOpenChatButton
    }
    
    @objc private func didTapCreateChatRoomButton() {
        print("채팅방 생성 이동")
    }
    
    @objc private func dmChatRoomListButtonTapped() {
        configureDmDatasource()
    }
    
    @objc private func openChatButtonTapped() {
        configureOpenDatasource()
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ChattingRoomListViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UINavigationController(rootViewController: ChattingRoomListViewController()) .showPreview(.iPhone14Pro)
    }
}
#endif
