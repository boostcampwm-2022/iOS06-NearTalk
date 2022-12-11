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
    private let sheetLabel: UILabel = .init().then {
        $0.text = "채팅방 목록"
        $0.font = .ntTextMediumBold
    }
    private lazy var chatRoomsTableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(BottomSheetTableViewCell.self,
                    forCellReuseIdentifier: BottomSheetTableViewCell.reuseIdentifier)
        $0.delegate = self
        $0.dataSource = self
        $0.delaysContentTouches = false
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
        self.view.addSubview(self.sheetLabel)
        self.view.addSubview(self.chatRoomsTableView)
    }
    
    private func configureConstraints() {
        self.sheetLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        
        self.chatRoomsTableView.snp.makeConstraints { make in
            make.top.equalTo(self.sheetLabel.snp.bottom).offset(20)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BottomSheetTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? BottomSheetTableViewCell
        else { return BottomSheetTableViewCell() }
        
        cell.fetch(with: self.dataSource[indexPath.row])
        cell.insert(coordinator: self.coordinator, parentVC: self)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.dequeueReusableCell(withIdentifier: BottomSheetTableViewCell.reuseIdentifier,
                                            for: indexPath) as? BottomSheetTableViewCell != nil
        else { return }
        
        let chatRoom = self.dataSource[indexPath.row]

        if let chatRoomID = chatRoom.uuid {
            self.coordinator?.closeBottomSheet(bottomSheetVC: self)
            self.coordinator?.showChatRoomView(chatRoomID: chatRoomID)
        }
    }
}
