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
    
    let tableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.rowHeight = 180
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .clear
        $0.register(ChattingRoomListCell.self, forCellReuseIdentifier: ChattingRoomListCell.identifier)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
 
        setupLayout()
        view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
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
        
        tableView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalTo(view)
        }
    }
    
    func configureDatasource() {
        
        dataSource = UITableViewDiffableDataSource<Int, ChattingRoomListData>(tableView: self.tableView, cellProvider: { tableView, indexPath, _ in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChattingRoomListCell.identifier, for: indexPath) as? ChattingRoomListCell else { return UITableViewCell() }
            cell.configure(data: self.viewModel.dummyData[indexPath.row])
            
            return cell
        })
 
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
