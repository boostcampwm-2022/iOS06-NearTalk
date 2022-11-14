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
    
    var dummyData: [ChattingRoomListData] = []
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupLayout()
        createDummyData()
        view.backgroundColor = .gray
    }
    
    func createDummyData() {
        dummyData.append(ChattingRoomListData(img: "", name: "001", description: "asdf"))
        dummyData.append(ChattingRoomListData(img: "", name: "002", description: "zxcv"))
        dummyData.append(ChattingRoomListData(img: "", name: "003", description: "qwer"))
        dummyData.append(ChattingRoomListData(img: "", name: "004", description: "asdf"))
        dummyData.append(ChattingRoomListData(img: "", name: "005", description: "zxcv"))
    }
    
    func setupLayout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalTo(view)
        }
    }
    
    func setupNavi() {
        
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
