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
    private lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: createBasicListLayout()).then {
        $0.register(FriendListCell.self, forCellWithReuseIdentifier: FriendListCell.identifier)
    }
    
    // MARK: - Properties
    private let disposeBag: DisposeBag = DisposeBag()
    private var viewModel: FriendListViewModel!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Friend>?
    
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
        self.view.addSubview(collectionView)
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
        self.collectionView.snp.makeConstraints { make in
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
        self.dataSource = UICollectionViewDiffableDataSource<Section, Friend>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendListCell.identifier, for: indexPath) as? FriendListCell
            else { return UICollectionViewCell() }
            cell.configure(model: itemIdentifier)
            return cell
        })
    }
    
    private func bind() {
        self.viewModel.friendsData
            .bind(onNext: { [weak self] model in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Friend>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model)
                self?.dataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { event in
                self.viewModel.didSelectItem(at: event[1])
            })
            .disposed(by: disposeBag)
    }
    
    private func createBasicListLayout() -> UICollectionViewLayout {
        let itemHeight = self.view.frame.width * 0.20
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(itemHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
      
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
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
