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
    private lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: createBasicListLayout()).then {
        $0.register(ChatRoomListCell.self, forCellWithReuseIdentifier: ChatRoomListCell.identifier)
    }
    
    // MARK: - Properties
    private var groupDataSource: UICollectionViewDiffableDataSource<Section, GroupChatRoomListData>?
    private var dmDataSource: UICollectionViewDiffableDataSource<Section, DMChatRoomListData>?
    
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
        self.view.addSubview(collectionView)
    }
    
    func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.trailing.leading.equalTo(view)
        }
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureNavigation() {
        let dmChatButton: UIBarButtonItem = UIBarButtonItem(title: "DM", style: .plain, target: self, action: #selector(dmChatRoomListButtonTapped))
        let groupChatButton: UIBarButtonItem = UIBarButtonItem(title: "Group", style: .plain, target: self, action: #selector(groupChatButtonTapped))
        let createGroupChatButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapCreateChatRoomButton))
        
        self.navigationItem.leftBarButtonItems = [dmChatButton, groupChatButton]
        self.navigationItem.rightBarButtonItem = createGroupChatButton
    }
    
    private func configureDatasource() {
        
        self.groupDataSource = UICollectionViewDiffableDataSource<Section, GroupChatRoomListData>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatRoomListCell.identifier,
                for: indexPath) as? ChatRoomListCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(groupData: itemIdentifier)
            return cell
        })
        
        self.dmDataSource = UICollectionViewDiffableDataSource<Section, DMChatRoomListData>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatRoomListCell.identifier,
                for: indexPath) as? ChatRoomListCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(dmData: itemIdentifier)
            return cell
        })
    }
    
    // MARK: - bind
    private func bind() {
        self.collectionView.rx.itemSelected
            .subscribe(onNext: { event in
                self.viewModel.didSelectItem(at: event[1])
            })
            .disposed(by: disposeBag)
        
        self.viewModel.dmChatRoomData
            .bind(onNext: { [weak self] model in
                var snapshot = NSDiffableDataSourceSnapshot<Section, DMChatRoomListData>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model)
                self?.dmDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.groupChatRoomData
            .bind(onNext: { [weak self] model in
                var snapshot = NSDiffableDataSourceSnapshot<Section, GroupChatRoomListData>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model)
                self?.groupDataSource?.apply(snapshot, animatingDifferences: true)
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
        print("채팅방 생성 이동")
    }
    
    @objc private func dmChatRoomListButtonTapped() {
        self.collectionView.dataSource = self.dmDataSource
        self.collectionView.reloadData()
    }
    
    @objc private func groupChatButtonTapped() {
        self.collectionView.dataSource = self.groupDataSource
        self.collectionView.reloadData()
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
