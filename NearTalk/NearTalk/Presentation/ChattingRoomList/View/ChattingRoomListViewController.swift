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
    
    private var dataSource: UITableViewDiffableDataSource<Int, ChattingRoomListData>?
    private var viewModel = ChattingRoomListViewModel()
    
    var naviBar = UINavigationBar()
    
    let tableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(ChattingRoomListCell.self, forCellReuseIdentifier: ChattingRoomListCell.identifier)
    }

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addNaviBar()
        setupLayout()
    }
    
    // 레이아웃 셋팅
    func setupLayout() {
        configureDatasource()
        self.dataSource?.defaultRowAnimation = .fade
        tableView.dataSource = self.dataSource
        
        // 빈 snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChattingRoomListData>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.dummyData)
        self.dataSource?.apply(snapshot)
        
        view.addSubview(tableView)
        view.addSubview(naviBar)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.naviBar.snp.bottom).offset(-12)
            make.bottom.trailing.leading.equalTo(view)
        }
    }
    
    // 데이터소스 세팅
    func configureDatasource() {
        
        dataSource = UITableViewDiffableDataSource<Int, ChattingRoomListData>(tableView: self.tableView, cellProvider: { tableView, indexPath, _ in
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ChattingRoomListCell.identifier,
                for: indexPath) as? ChattingRoomListCell
            else {
                return UITableViewCell()
            }
            
            cell.configure(data: self.viewModel.dummyData[indexPath.row])
            
            return cell
        })
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
        naviItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapChangeButton))
        naviBar.items = [naviItem]
    }
    
    @objc func didTapCreateChatRoomButton() {
        print("채팅방 생성 이동")
    }
    
    @objc func didTapChangeButton() {
        print("채팅방 목록 변경")
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
