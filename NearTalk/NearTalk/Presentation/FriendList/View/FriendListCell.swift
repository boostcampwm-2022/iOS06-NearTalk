//
//  FriendsListCell.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Kingfisher
import SnapKit
import Then
import UIKit

final class FriendListCell: UICollectionViewCell {
    
    static let identifier = String(describing: ChatRoomListCell.self)
    private var viewModel: FriendListViewModel?
    
    // MARK: - UI properties
    private let img = UIImageView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "photo")
    }
    
    private let name = UILabel().then {
        $0.font = UIFont(name: "text", size: 18)
        $0.numberOfLines = 1
    }
    
    private let userDescription = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.numberOfLines = 1
    }
    
    private lazy var stactView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 4
        $0.addArrangedSubview(self.name)
        $0.addArrangedSubview(self.userDescription)
    }
    
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.configureConstraints()
    }
    
    // MARK: - Helper
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: Friend) {
        self.name.text = model.username
        self.userDescription.text = model.statusMessage
        self.imageLoad(path: model.profileImagePath)
    }
    
    func imageLoad(path: String?) {
        guard let path = path,
              let url = URL(string: path)
        else {
            img.image = UIImage(systemName: "photo")
            return
        }
        
        img.kf.setImage(with: URL(string: "주소: \(url)"))
        if img.image == nil {
            img.image = UIImage(systemName: "photo")
        }
    }
    
    private func addSubviews() {
        self.contentView.addSubview(img)
        self.contentView.addSubview(stactView)
    }
    
    private func configureConstraints() {
        self.configureImg()
    }
    
    private func configureImg() {
        self.img.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView).offset(16)
            make.centerY.equalTo(self.contentView)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        self.stactView.snp.makeConstraints { make in
            make.leading.equalTo(self.img.snp.trailing).offset(8)
            make.trailing.equalTo(self.contentView).offset(-16)
            make.centerY.equalTo(self.contentView)
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct FriendListCellPreview: PreviewProvider {
    static var previews: some View {
        let width: CGFloat = 393
        let height: CGFloat = width * 0.20
        
        //        let viewModel: FriendListViewModel = DefaultFriendListViewModel(
        //            fetchFriendListUseCase: DefaultFetchFriendListUseCase(
        //                profileRepository: DefaultProfileRepository(
        //                    firestoreService: DefaultFirestoreService(),
        //                    firebaseAuthService: DefaultFirebaseAuthService()
        //                )
        //            ),
        //            imageUseCase: DefaultImageUseCase(
        //                imageRepository: DefaultImageRepository()
        //            )
        //        )
        
        UIViewPreview {
            let cell = FriendListCell(frame: .zero)
            cell.configure(model: Friend(userID: "1234", username: "라이언", statusMessage: "NSCollectionLayoutItem을 이용합니다. Collection View의 가장 기본 컴포넌트입니다. Item은 크기, 개별 content의 size, space, arragnge를 어떻게 할지에 대한 blueprint입니다", profileImagePath: ""))
            return cell
        }.previewLayout(.fixed(width: width, height: height))
    }
}
#endif
