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
    private(set) lazy var dmCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: createBasicListLayout()).then {
        $0.register(ChatRoomListCell.self, forCellWithReuseIdentifier: ChatRoomListCell.identifier)
    }
    
    private(set) lazy var groupCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: createBasicListLayout()).then {
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
    
    enum ChatType: Int {
        case group = 0
        case dm = 1
    }
    
    // MARK: - Lifecycle
    // todo: - 이미지 레파지토리 추가
    static func create(with viewModel: ChatRoomListViewModel) -> ChatRoomListViewController {
        let view = ChatRoomListViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.viewWillAppear()
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
        self.view.addSubview(dmCollectionView)
        self.view.addSubview(groupCollectionView)
    }
    
    func configureConstraints() {
        dmCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.trailing.leading.equalTo(view)
        }
        
        groupCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.trailing.leading.equalTo(view)
        }
    }
    
    private func configureView() {
        self.view.backgroundColor = .systemBackground
        self.dmCollectionView.isHidden = true
    }
    
    private func configureNavigation() {
        let dmChatButton: UIBarButtonItem = UIBarButtonItem(title: "DM", style: .plain, target: self, action: nil)
        let groupChatButton: UIBarButtonItem = UIBarButtonItem(title: "Group", style: .plain, target: self, action: nil)
        let createGroupChatButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        
        self.navigationItem.leftBarButtonItems = [groupChatButton, dmChatButton]
        self.navigationItem.rightBarButtonItem = createGroupChatButton
    }
    
    private func configureDatasource() {
        
        self.groupDataSource = UICollectionViewDiffableDataSource<Section, GroupChatRoomListData>(
            collectionView: self.groupCollectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatRoomListCell.identifier,
                for: indexPath) as? ChatRoomListCell else {
                return UICollectionViewCell()
            }

            cell.configure(groupData: itemIdentifier, viewModel: self.viewModel)
            return cell
        })
        
        self.groupCollectionView.dataSource = self.groupDataSource
        
        self.dmDataSource = UICollectionViewDiffableDataSource<Section, DMChatRoomListData>(
            collectionView: self.dmCollectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatRoomListCell.identifier,
                for: indexPath) as? ChatRoomListCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(dmData: itemIdentifier, viewModel: self.viewModel)
            return cell
        })
        
        self.dmCollectionView.dataSource = self.dmDataSource
    }
    
    // MARK: - bind
    private func bind() {
        
        self.viewModel.dmChatRoomData
            .bind(onNext: { [weak self] (model: [DMChatRoomListData]) in
                var snapshot = NSDiffableDataSourceSnapshot<Section, DMChatRoomListData>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model.sorted{ $0.recentMessageDate ?? Date() > $1.recentMessageDate ?? Date() })
                self?.dmDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.groupChatRoomData
            .bind(onNext: { [weak self] (model: [GroupChatRoomListData]) in
                var snapshot = NSDiffableDataSourceSnapshot<Section, GroupChatRoomListData>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model.sorted{ $0.recentMessageDate ?? Date() > $1.recentMessageDate ?? Date() })
                self?.groupDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItems?[ChatType.dm.rawValue].rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.didDMChatRoomList()
            })
            .disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItems?[ChatType.group.rawValue].rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.didGroupChatRoomList()
            })
            .disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.didCreateChatRoom()
            })
            .disposed(by: disposeBag)
    }
    
    private func createBasicListLayout() -> UICollectionViewLayout {
        let itemHeight = self.view.frame.width * 0.20
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ChatRoomListViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let navigation = UINavigationController()
        
        let diContainer: ChatRoomListDIContainer = ChatRoomListDIContainer()
        let coordinator = diContainer.makeChatRoomListCoordinator(navigationController: navigation)
        coordinator.start()
        
        return navigation.showPreview(.iPhone14Pro)
    }
}
#endif
