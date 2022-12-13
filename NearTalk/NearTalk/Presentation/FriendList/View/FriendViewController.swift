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
        $0.backgroundColor = UIColor.primaryBackground
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
        self.view.backgroundColor = UIColor.primaryBackground
    }
    
    private func configureTableView() {
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.trailing.leading.equalTo(view)
        }
    }
    
    private func configureNavigation() {
        let newNavBarAppearance: UINavigationBarAppearance = UINavigationBarAppearance()

        newNavBarAppearance.configureWithOpaqueBackground()
        newNavBarAppearance.backgroundColor = .secondaryBackground
        
        self.navigationController?
            .navigationBar
            .topItem?
            .backButtonDisplayMode = .minimal
        self.navigationController?.navigationBar.tintColor = .label

        self.navigationItem.title = "마이 프로필"
        self.navigationItem.hidesBackButton = true
        self.navigationItem.standardAppearance = newNavBarAppearance
        self.navigationItem.compactAppearance = newNavBarAppearance
        self.navigationItem.scrollEdgeAppearance = newNavBarAppearance
        self.navigationItem.compactScrollEdgeAppearance = newNavBarAppearance
        
        self.navigationItem.title = "친구 목록"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        self.navigationItem.rightBarButtonItems?[0].tintColor = .label
    }
    
    // 데이터소스 세팅
    private func configureDatasource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Friend>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendListCell.identifier, for: indexPath) as? FriendListCell
            else {
                return UICollectionViewCell()
            }
            cell.configure(model: itemIdentifier, viewModel: self.viewModel)
            return cell
        })
    }
    
    private func bind() {
        self.viewModel.friendsData
            .bind(onNext: { [weak self] (model: [Friend]) in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Friend>()
                snapshot.appendSections([.main])
                snapshot.appendItems(model)
                self?.dataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.showAlert()
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
    
    func showAlert() {
        let alert = UIAlertController(title: "친구추가", message: "UUID를 입력해주세요", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField()
        
        let cancelAction =  UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel)
        let addFriendAction = UIAlertAction(title: "친구추가", style: UIAlertAction.Style.default) { [weak self] _ in
            
            if let self = self, let textFiled = alert.textFields?.first, let uuid = textFiled.text {
                self.viewModel.addFriend(uuid: uuid)
                    .asObservable()
                    .subscribe { completable in
                        switch completable {
                        case .completed:
                            print("Completed")
                            self.viewModel.reload()
                        case .error(let error):
                            print("Completed with an error: \(error.localizedDescription)")
                        }
                    }
                    .disposed(by: self.disposeBag)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addFriendAction)
        
        self.present(alert, animated: true)
    }
    
}
