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
    private var viewModel = ChattingRoomListViewModel()
    
    var naviBar = UINavigationBar()
    
    let tableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(ChattingRoomListCell.self, forCellReuseIdentifier: ChattingRoomListCell.identifier)
    }

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNaviBar()
        setupLayout()
        configureDmDatasource()
    }
    
    // 레이아웃 셋팅
    func setupLayout() {
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(naviBar)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.naviBar.snp.bottom).offset(-8)
            make.bottom.trailing.leading.equalTo(view)
        }
    }
    
    // 데이터소스 세팅
    func configureOpenDatasource() {
        
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
    
    func configureDmDatasource() {
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
    private func addNaviBar() {
        // safe area
        var statusBarHeight: CGFloat = 0
        statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0

        // navigationBar
        self.naviBar = UINavigationBar(frame: .init(x: 0, y: statusBarHeight, width: view.frame.width, height: statusBarHeight))
        naviBar.isTranslucent = false
        naviBar.backgroundColor = .systemBackground

        let naviItem = UINavigationItem(title: "오픈채팅 목록")
        naviItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapCreateChatRoomButton))
        naviItem.leftBarButtonItem = UIBarButtonItem(title: "DM", style: .plain, target: self, action: #selector(didTapChangeButton))
        naviBar.items = [naviItem]
    }
    
    @objc func didTapCreateChatRoomButton() {
        print("채팅방 생성 이동")
    }
    
    @objc func didTapChangeButton() {
        if self.naviBar.items?.first?.leftBarButtonItem?.title == "DM" {
            self.naviBar.items?.first?.leftBarButtonItem = UIBarButtonItem(title: "오픈채팅", style: .plain, target: self, action: #selector(didTapChangeButton))
            configureOpenDatasource()
        } else {
            self.naviBar.items?.first?.leftBarButtonItem = UIBarButtonItem(title: "DM", style: .plain, target: self, action: #selector(didTapChangeButton))
            configureDmDatasource()
        }
//        tableView.reloadData()
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ChattingRoomListViewControllerPreview: PreviewProvider {
    static var previews: some View {
        ChattingRoomListViewController().showPreview(.iPhone14Pro)
    }
}
#endif
