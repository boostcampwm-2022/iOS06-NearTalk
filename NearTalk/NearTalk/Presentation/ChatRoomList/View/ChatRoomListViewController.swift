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
        $0.backgroundColor = UIColor.primaryBackground
        $0.register(ChatRoomListCell.self, forCellWithReuseIdentifier: ChatRoomListCell.identifier)
    }
    
    private(set) lazy var groupCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: createBasicListLayout()).then {
        $0.backgroundColor = UIColor.primaryBackground
        $0.register(ChatRoomListCell.self, forCellWithReuseIdentifier: ChatRoomListCell.identifier)
    }
    
    private lazy var chatTypeSegment = UISegmentedControl(items: ["Group Chat", "DM"]).then {
        $0.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        $0.backgroundColor = .tertiaryLabel
        $0.tintColor = .label
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
        
        var index: Int {
            switch self {
            case .group: return 0
            case .dm: return 1
            }
        }
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
        self.groupCollectionView.reloadData()
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
        self.view.addSubview(self.chatTypeSegment)
        self.view.addSubview(self.dmCollectionView)
        self.view.addSubview(self.groupCollectionView)
    }
    
    func configureConstraints() {
        
        self.chatTypeSegment.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.centerX.equalTo(self.view)
            make.width.equalTo(300)
            make.height.equalTo(32)
        }
        
        self.dmCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.chatTypeSegment.snp.bottom).offset(12)
            make.bottom.trailing.leading.equalTo(self.view)
        }
        
        self.groupCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.chatTypeSegment.snp.bottom).offset(12)
            make.bottom.trailing.leading.equalTo(self.view)
        }
    }
    
    private func configureView() {
        self.view.backgroundColor = .primaryBackground
        self.chatTypeSegment.selectedSegmentIndex = ChatType.group.rawValue
        self.dmCollectionView.isHidden = true
    }
    
    private func configureNavigation() {
        let createGroupChatButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        createGroupChatButton.tintColor = .label
        self.navigationItem.rightBarButtonItem = createGroupChatButton
        self.navigationItem.title = "채팅 목록"
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
                snapshot.appendItems(model.sorted { $0.recentMessageDate ?? Date() > $1.recentMessageDate ?? Date() })
                self?.dmDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.groupChatRoomData
            .bind(onNext: { [weak self] (model: [GroupChatRoomListData]) in
                var snapshot = NSDiffableDataSourceSnapshot<Section, GroupChatRoomListData>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model.sorted { $0.recentMessageDate ?? Date() > $1.recentMessageDate ?? Date() })
                self?.groupDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        self.chatTypeSegment.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] (index: Int) in
                switch index {
                case ChatType.group.index:
                    self?.viewModel.didGroupChatRoomList()
                case ChatType.dm.index:
                    self?.viewModel.didDMChatRoomList()
                default:
                    break
                }
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

