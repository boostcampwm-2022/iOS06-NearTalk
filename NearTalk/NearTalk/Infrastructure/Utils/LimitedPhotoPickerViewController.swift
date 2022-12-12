//
//  LimitedPhotoPickerViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/11.
//

import Photos
import PhotosUI
import RxRelay
import RxSwift
import SnapKit
import UIKit

enum PhotoSection: Hashable, Sendable {
    case main
}

final class LimitedPhotoPickerViewController: UIViewController {
    private lazy var contentView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.makeViewLayout()).then {
        $0.backgroundColor = .primaryBackground
        $0.register(
            LimitedPhotoPickerViewCell.self,
            forCellWithReuseIdentifier: LimitedPhotoPickerViewCell.identifer)
    }

    private lazy var dataSouce: UICollectionViewDiffableDataSource<PhotoSection, PHAsset> = UICollectionViewDiffableDataSource(
        collectionView: self.contentView) { collectionView, indexPath, itemIdentifier in
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LimitedPhotoPickerViewCell.identifer,
            for: indexPath) as? LimitedPhotoPickerViewCell
        else {
            return UICollectionViewCell()
        }
        
        PHImageManager.default().requestImage(
            for: itemIdentifier,
            targetSize: .init(width: 320, height: 320),
            contentMode: .aspectFit,
            options: nil) { image, _ in
            cell.image = image
        }

        return cell
    }
    
    private let disposeBag: DisposeBag = .init()
    private var fetchResults: PHFetchResult<PHAsset>?
    private let selectedIndex: BehaviorRelay<IndexPath?> = BehaviorRelay(value: nil)
    
    var itemSelectedEvent: ((_ image: UIImage?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        self.initDataSource()
        self.contentView.delegate = self
        self.configureNavigation()
        self.addSubViews()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension LimitedPhotoPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextCell = collectionView.cellForItem(at: indexPath) as? LimitedPhotoPickerViewCell
        else {
            return
        }
        
        if let prevSelectedIndex = self.selectedIndex.value,
           let prevCell = collectionView.cellForItem(at: prevSelectedIndex) {
            prevCell.isSelected = false
        }
        
        nextCell.isSelected = true
        self.selectedIndex.accept(indexPath)
    }
}

extension LimitedPhotoPickerViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResults = self.fetchResults
        else {
            return
        }
        
        if let changes = changeInstance.changeDetails(for: fetchResults) {
            var snapShot = self.dataSouce.snapshot()
            snapShot.deleteAllItems()
            snapShot.appendSections([.main])
            changes.fetchResultAfterChanges.enumerateObjects { asset, _, _ in
                snapShot.appendItems([asset], toSection: .main)
            }
            self.dataSouce.apply(snapShot, animatingDifferences: true)
            self.selectedIndex.accept(nil)
        }
    }
}

private extension LimitedPhotoPickerViewController {
    func addSubViews() {
        self.view.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func initDataSource() {
        var snapShot = NSDiffableDataSourceSnapshot<PhotoSection, PHAsset>()
        let fetchResults = PHAsset.fetchAssets(with: .image, options: nil)
        self.fetchResults = fetchResults
        snapShot.appendSections([.main])
        fetchResults.enumerateObjects { asset, _, _ in
            snapShot.appendItems([asset], toSection: .main)
        }
        self.dataSouce.apply(snapShot, animatingDifferences: true)
    }
    
    func configureNavigation() {
        self.configureNavigationItemUI()
        self.bindNavigationButtonEvents()
    }
    
    func bindNavigationButtonEvents() {
        self.bindCancelButtonEvent()
        self.bindSelectButtonEvent()
    }
    
    func bindCancelButtonEvent() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "취소", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.rx
            .tap
            .asSignal()
            .emit(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindSelectButtonEvent() {
        let selectButton: UIBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = selectButton
        self.navigationItem.leftBarButtonItem?.rx
            .tap
            .asSignal()
            .emit(onNext: { [weak self] _ in
                guard let index = self?.selectedIndex.value,
                      let cell = self?.contentView.cellForItem(at: index) as? LimitedPhotoPickerViewCell,
                      let image = cell.image
                else {
                    self?.itemSelectedEvent?(nil)
                    self?.dismiss(animated: true)
                    return
                }
                self?.itemSelectedEvent?(image)
                self?.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        self.selectedIndex.asDriver()
            .map {
                guard let indexPath = $0,
                      self.contentView.cellForItem(at: indexPath) as? LimitedPhotoPickerViewCell != nil
                else {
                    return false
                }
                return true
            }
            .drive(selectButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
    
    func configureNavigationItemUI() {
        let appearance: UINavigationBarAppearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGray6
        
        self.contentView.contentInsetAdjustmentBehavior = .never
        self.navigationItem.title = "사진 선택"
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.compactAppearance = appearance
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.compactScrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.tintColor = .label
    }
    
    func makeViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize: NSCollectionLayoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .fractionalWidth(0.25))
        let item: NSCollectionLayoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize: NSCollectionLayoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.25))
        let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item])

        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group)
        let layout: UICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}
