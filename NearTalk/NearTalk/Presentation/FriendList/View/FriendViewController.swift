//
//  FriendsListView.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class FriendListViewController: UIViewController {
    // MARK: - UI properties
    private let tableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(FriendListCell.self, forCellReuseIdentifier: FriendListCell.identifier)
    }
    
    // MARK: - Properties
    private let disposeBag: DisposeBag = DisposeBag()
    private var viewModel: FriendListViewModel!
    
    private var dataSource: UITableViewDiffableDataSource<Section, Friend>?
    
    enum Section {
        case main
    }
    
    // MARK: - Lifecycles
    static func create(with viewModel: FriendListViewModel) -> FriendListViewController {
        let view = FriendListViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSubviews()
        self.configureConstraints()
    }
    
    // MARK: - Helper
    private func addSubviews() {
        self.view.addSubview(tableView)
    }

    private func configureConstraints() {
        self.configureView()
        self.configureTableView()
        self.configureNavigation()
        self.configureDatasource()
        self.bind()
    }
    
    private func configureView() {
        self.view.backgroundColor = .systemBackground
    }
    
    private func configureTableView() {
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.trailing.leading.equalTo(view)
        }
    }
    
    private func configureNavigation() {
        self.navigationItem.title = "친구 목록"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapCreateChatRoomButton))
    }
    
    // 데이터소스 세팅
    private func configureDatasource() {
        self.dataSource = UITableViewDiffableDataSource<Section, Friend>(tableView: self.tableView, cellProvider: { tableView, indexPath, model in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendListCell.identifier, for: indexPath) as? FriendListCell
            else { return UITableViewCell() }
            cell.configure(model: model)
            return cell
        })
    }
    
    private func bind() {
        self.viewModel.friendsData
            .bind(onNext: { [weak self] model in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Friend>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model)
                self?.dataSource?.defaultRowAnimation = .fade
                self?.dataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { event in
                self.viewModel.didSelectItem(at: event[1])
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func didTapCreateChatRoomButton() {
        print("친구 추가 이동")
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct FriendsListViewControllerPreview: PreviewProvider {
    static var previews: some View {
        lazy var firestoreService: DefaultFirestoreService = {
            return DefaultFirestoreService()
        }()
        lazy var firebaseAuthService: DefaultFirebaseAuthService = {
            return DefaultFirebaseAuthService()
        }()
        let dependencies = FriendListDIContainer.Dependencies(firestoreService: firestoreService, firebaseAuthService: firebaseAuthService)
        let diContainer = FriendListDIContainer(dependencies: dependencies)
        let actions = FriendListViewModelActions(showDetailFriend: {_ in })
        let viewController = diContainer.makeFriendListViewController(actions: actions)
        return UINavigationController(rootViewController: viewController).showPreview(.iPhone14Pro)
    }
}
#endif
