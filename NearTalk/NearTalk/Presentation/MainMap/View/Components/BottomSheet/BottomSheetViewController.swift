//
//  BottomSheetViewController.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/17.
//
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class BottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    private var coordinator: MainMapCoordinator?
    private var dataSource: [ChatRoom] = []
    
    // MARK: - UI Components
    static let roomTypeItems: [String] = ["전체 채팅방 목록", "입장 가능한 목록"]
    private let roomTypeSegmentedControl = UISegmentedControl(items: BottomSheetViewController.roomTypeItems).then {
        $0.backgroundColor = .red
        $0.selectedSegmentIndex = 0
    }
    private lazy var chatRoomsTableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(BottomSheetTableViewCell.self,
                    forCellReuseIdentifier: BottomSheetTableViewCell.reuseIdentifier)
        $0.delegate = self
        $0.dataSource = self
    }
    
    // MARK: - Lifecycles
    static func create(with dataSource: [ChatRoom] = [], coordinator: MainMapCoordinator) -> BottomSheetViewController {
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.dataSource = dataSource
        bottomSheetVC.coordinator = coordinator
        
        return bottomSheetVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubViews()
        self.configureConstraints()
        self.configureLayout()
    }
    
    // MARK: - Methods
    func fetch(with dataSource: [ChatRoom]) {
        self.dataSource = dataSource
    }
    
    private func addSubViews() {
        self.view.addSubview(roomTypeSegmentedControl)
        self.view.addSubview(chatRoomsTableView)
    }
    
    private func configureConstraints() {
        self.roomTypeSegmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
        }
        
        self.chatRoomsTableView.snp.makeConstraints { make in
            make.top.equalTo(self.roomTypeSegmentedControl.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func configureLayout() {
        self.chatRoomsTableView.estimatedRowHeight = 80.0
        self.view.backgroundColor = .systemOrange
        
        if let sheet = self.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.preferredCornerRadius = 20
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
    }
}

// MARK: - Extensions
extension BottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BottomSheetTableViewCell.reuseIdentifier, for: indexPath) as? BottomSheetTableViewCell
        else { return BottomSheetTableViewCell() }
        
        cell.fetch(with: self.dataSource[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoom = self.dataSource[indexPath.row]
        
        if let chatRoomID = chatRoom.uuid {
            self.coordinator?.closeBottomSheet(bottomSheetVC: self)
            self.coordinator?.showChatRoomView(chatRoomID: chatRoomID)
        }
    }
}
