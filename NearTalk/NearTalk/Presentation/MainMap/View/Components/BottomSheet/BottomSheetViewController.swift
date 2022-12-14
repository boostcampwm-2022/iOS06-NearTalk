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
    
    private enum Text: String {
        case sheetTitle = "채팅방 목록"
        
        var optional: String? {
            return Optional(self.rawValue)
        }
    }
    
    // MARK: - Properties
    private var coordinator: MainMapCoordinator?
    private var dataSource: [ChatRoom] = []
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - UI Components
    private let sheetLabel: UILabel = .init().then {
        $0.text = Text.sheetTitle.optional
        $0.font = .ntTextMediumBold
        $0.textColor = .label
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
    private func addSubViews() {
        self.view.addSubview(self.sheetLabel)
        self.view.addSubview(self.chatRoomsTableView)
    }
    
    private func configureConstraints() {
        self.sheetLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
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
        self.view.backgroundColor = .secondaryBackground
        
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
    
    func fetch(with dataSource: [ChatRoom]) {
        self.dataSource = dataSource.sorted(by: { self.calcChatRoomDistance(with: $0) < self.calcChatRoomDistance(with: $1) })
    }
    
    private func calcChatRoomDistance(with chatRoom: ChatRoom) -> Double {
        guard let userLatitude = UserDefaults.standard.object(forKey: UserDefaultsKey.currentUserLatitude.string) as? Double,
              let userLongitude = UserDefaults.standard.object(forKey: UserDefaultsKey.currentUserLongitude.string) as? Double,
              let chatRoomLatitude = chatRoom.latitude,
              let chatRoomLongitude = chatRoom.longitude
        else {
            return Double.infinity
        }
        
        let userLocation = NCLocation(latitude: userLatitude,
                                      longitude: userLongitude)
        let chatRoomLocation = NCLocation(latitude: chatRoomLatitude,
                                          longitude: chatRoomLongitude)
        
        return chatRoomLocation.distance(from: userLocation)
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
        else {
            return BottomSheetTableViewCell()
        }
        
        let chatRoom = self.dataSource[indexPath.row]
        cell.fetch(with: chatRoom)
        cell.insert(coordinator: self.coordinator, parentVC: self)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // return UITableView.automaticDimension
        return 80
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
