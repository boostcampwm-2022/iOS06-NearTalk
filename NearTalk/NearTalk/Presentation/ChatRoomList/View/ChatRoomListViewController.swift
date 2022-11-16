//
//  ChatRoomListViewController.swift
//  NearTalk
//
//  Created by yw22 on 2022/11/11.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class ChatRoomListViewController: UIViewController {
    
    private var openDataSource: UITableViewDiffableDataSource<Int, OpenChatRoomListData>?
    private var dmDataSource: UITableViewDiffableDataSource<Int, DMChatRoomListData>?
    private var viewModel: ChatRoomListViewModel!
    
    private let tableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(ChatRoomListCell.self, forCellReuseIdentifier: ChatRoomListCell.identifier)
    }
    
    // MARK: - Lifecycle
    static func create(with viewModel: ChatRoomListViewModel) -> ChatRoomListViewController {
        let view = ChatRoomListViewController()
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
        
        self.openDataSource = UITableViewDiffableDataSource<Int, OpenChatRoomListData>(tableView: self.tableView, cellProvider: { tableView, indexPath, _ in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomListCell.identifier, for: indexPath) as? ChatRoomListCell
            else { return UITableViewCell() }
//            cell.configure(openData: self.viewModel.openChatRoomDummyData[indexPath.row])
            return cell
        })
        
        self.openDataSource?.defaultRowAnimation = .fade
        tableView.dataSource = self.openDataSource
        
        // 빈 snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Int, OpenChatRoomListData>()
        snapshot.appendSections([0])
//        snapshot.appendItems(viewModel.openChatRoomDummyData)
        self.openDataSource?.apply(snapshot)
        
    }
    
    private func configureDmDatasource() {
        self.dmDataSource = UITableViewDiffableDataSource<Int, DMChatRoomListData>(tableView: self.tableView, cellProvider: { tableView, indexPath, _ in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomListCell.identifier, for: indexPath) as? ChatRoomListCell
            else { return UITableViewCell() }
            
//            cell.configure(dmData: self.viewModel.dmChatRoomDummyData[indexPath.row])
            return cell
        })
        
        self.dmDataSource?.defaultRowAnimation = .fade
        tableView.dataSource = self.dmDataSource
        
        // 빈 snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Int, DMChatRoomListData>()
        snapshot.appendSections([0])
//        snapshot.appendItems(viewModel.dmChatRoomDummyData)
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

struct ChatRoomListViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UINavigationController(rootViewController: ChatRoomListViewController()) .showPreview(.iPhone14Pro)
    }
}
#endif
