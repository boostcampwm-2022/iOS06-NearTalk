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
    private let tableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(ChatRoomListCell.self, forCellReuseIdentifier: ChatRoomListCell.identifier)
    }
    // MARK: - Properties
    private var openDataSource: UITableViewDiffableDataSource<Int, OpenChatRoomListData>?
    private var dmDataSource: UITableViewDiffableDataSource<Int, DMChatRoomListData>?
    
    private var viewModel: ChatRoomListViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
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
        let openChatButton: UIBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openChatButtonTapped))
        let creatOpenChatButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapCreateChatRoomButton))
        
        self.navigationItem.leftBarButtonItems = [dmChatButton, openChatButton]
        self.navigationItem.rightBarButtonItem = creatOpenChatButton
    }
    
    private func configureDatasource() {
        
        self.openDataSource = UITableViewDiffableDataSource<Int, OpenChatRoomListData>(tableView: self.tableView, cellProvider: { tableView, indexPath, model in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomListCell.identifier, for: indexPath) as? ChatRoomListCell
            else {
                print("살려주세요")
                return UITableViewCell()
            }
            print(model)
            cell.configure(openData: model)
            return cell
        })
        
        self.dmDataSource = UITableViewDiffableDataSource<Int, DMChatRoomListData>(tableView: self.tableView, cellProvider: { tableView, indexPath, model in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomListCell.identifier, for: indexPath) as? ChatRoomListCell
            else { return UITableViewCell() }
            cell.configure(dmData: model)
            return cell
        })
    }
    
    // MARK: - bind
    private func bind() {
        self.viewModel.openChatRoomData
            .subscribe(onNext: { model in
                var snapshot = NSDiffableDataSourceSnapshot<Int, OpenChatRoomListData>()
                snapshot.appendSections([0])
                snapshot.appendItems(model)
                print(model)
                self.openDataSource?.apply(snapshot)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper
    @objc private func didTapCreateChatRoomButton() {
        print("채팅방 생성 이동")
    }
    
    @objc private func dmChatRoomListButtonTapped() {
    }
    
    @objc private func openChatButtonTapped() {
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
