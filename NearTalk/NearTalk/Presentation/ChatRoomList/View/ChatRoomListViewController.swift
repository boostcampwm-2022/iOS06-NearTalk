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
    
    // MARK: - UI properties
    private lazy var tableView = UITableView().then {
        $0.register(ChatRoomListCell.self, forCellReuseIdentifier: ChatRoomListCell.identifier)
    }
    
    // MARK: - Properties
    private var groupDataSource: UITableViewDiffableDataSource<Section, GroupChatRoomListData>?
    private var dmDataSource: UITableViewDiffableDataSource<Section, DMChatRoomListData>?
    
    private var viewModel: ChatRoomListViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    enum Section {
        case main
    }
    
    // MARK: - Lifecycle
    // todo: - 이미지 레파지토리 추가
    static func create(with viewModel: ChatRoomListViewModel) -> ChatRoomListViewController {
        let view = ChatRoomListViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubviews()
        self.configureNavigation()
        self.configureView()
        self.configureConstraints()
        self.configureDatasource()
        self.bind()
    }
    
    // MARK: - Configure views
    func addSubviews() {
        self.view.addSubview(tableView)
    }
    
    func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.trailing.leading.equalTo(view)
        }
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
    }
    
    private func configureNavigation() {
        let dmChatButton: UIBarButtonItem = UIBarButtonItem(title: "DM", style: .plain, target: self, action: #selector(dmChatRoomListButtonTapped))
        let groupChatButton: UIBarButtonItem = UIBarButtonItem(title: "Group", style: .plain, target: self, action: #selector(groupChatButtonTapped))
        let createGroupChatButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapCreateChatRoomButton))
        
        self.navigationItem.leftBarButtonItems = [dmChatButton, groupChatButton]
        self.navigationItem.rightBarButtonItem = createGroupChatButton
    }
    
    private func configureDatasource() {
        self.groupDataSource = UITableViewDiffableDataSource<Section, GroupChatRoomListData>(
            tableView: self.tableView,
            cellProvider: { tableView, indexPath, item in
                
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatRoomListCell.identifier,
                    for: indexPath) as? ChatRoomListCell else {
                    return UITableViewCell()
                }
                
                cell.configure(groupData: item)
                return cell
            })
        
        self.dmDataSource = UITableViewDiffableDataSource<Section, DMChatRoomListData>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatRoomListCell.identifier,
                    for: indexPath) as? ChatRoomListCell else {
                    return UITableViewCell()
                }
                
                cell.configure(dmData: item)
                return cell
            })
    }
    
    // MARK: - bind
    private func bind() {
        self.tableView.rx.itemSelected
            .subscribe(onNext: { event in
                self.viewModel.didSelectItem(at: event[1])
            })
            .disposed(by: disposeBag)
        
        self.viewModel.dmChatRoomData
            .bind(onNext: { [weak self] model in
                var snapshot = NSDiffableDataSourceSnapshot<Section, DMChatRoomListData>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model)
                self?.dmDataSource?.defaultRowAnimation = .fade
                self?.dmDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.groupChatRoomData
            .bind(onNext: { [weak self] model in
                var snapshot = NSDiffableDataSourceSnapshot<Section, GroupChatRoomListData>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model)
                self?.groupDataSource?.defaultRowAnimation = .fade
                self?.groupDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func didTapCreateChatRoomButton() {
        print("채팅방 생성 이동")
    }
    
    @objc private func dmChatRoomListButtonTapped() {
        self.tableView.dataSource = self.dmDataSource
        self.tableView.reloadData()
    }
    
    @objc private func groupChatButtonTapped() {
        self.tableView.dataSource = self.groupDataSource
        self.tableView.reloadData()
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ChatRoomListViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let xxxDIContainer: XXXDIContainer = XXXDIContainer()
        let diContainer: ChatRoomListDIContainer = xxxDIContainer.makeChatRoomListDIContainer()
        let mockAction: ChatRoomListViewModelActions = .init(showChatRoom: {}, showCreateChatRoom: {})
        let mockViewModel: ChatRoomListViewModel = diContainer.makeChatRoomListViewModel(actions: mockAction)
        let viewController: ChatRoomListViewController = ChatRoomListViewController.create(with: mockViewModel)
        return UINavigationController(rootViewController: viewController).showPreview(.iPhone14Pro)
    }
}
#endif
