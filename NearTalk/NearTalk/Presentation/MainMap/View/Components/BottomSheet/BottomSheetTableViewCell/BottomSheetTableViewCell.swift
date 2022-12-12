//
//  BottomSheetTableViewCell.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/17.
//

import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class BottomSheetTableViewCell: UITableViewCell {
    
    // MARK: - Class Identifier
    static let reuseIdentifier = String(describing: BottomSheetTableViewCell.self)
    
    // MARK: - UI Components
    private let chatRoomImage = UIImageView().then {
        $0.layer.cornerRadius = 30
        $0.image = UIImage(named: "Logo")
        $0.contentMode = .scaleAspectFit
    }
    private lazy var infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 4
        $0.addArrangedSubview(self.infoHeaderView)
        $0.addArrangedSubview(self.chatRoomDescription)
    }
    private lazy var infoHeaderView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 6
        $0.addArrangedSubview(self.chatRoomName)
        $0.addArrangedSubview(self.chatRoomDistance)
    }
    private let chatRoomName = UILabel().then {
        $0.textColor = .secondaryLabel
        $0.font = .ntTextMediumBold
    }
    private let chatRoomDistance = UILabel().then {
        $0.textColor = .tertiaryLabel
        $0.font = .ntCaption
    }
    private let chatRoomDescription = UILabel().then {
        $0.textColor = .secondaryLabel
        $0.font = .ntTextSmallRegular
        $0.numberOfLines = 2
    }
    private let chatRoomEnterButton = UIButton().then {
        guard let normalColor: UIColor = .secondaryLabel,
              let highlightColor: UIColor = .primaryColor
        else { return }
        
        let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 28)
        let image = UIImage(systemName: "arrow.right.circle")?
            .withTintColor(normalColor, renderingMode: .alwaysOriginal)
            .withConfiguration(buttonImageConfig)
        let highlightedImage = UIImage(systemName: "arrow.right.circle")?
            .withTintColor(highlightColor, renderingMode: .alwaysOriginal)
            .withConfiguration(buttonImageConfig)
        $0.setImage(image, for: .normal)
        $0.setImage(highlightedImage, for: .highlighted)
    }

    private let chatRoomLock = UIImageView().then {
        guard let lockImageColor: UIColor = .primaryBackground,
              let cellCoverColor: UIColor = .tertiaryLabel
        else { return }
        
        let lockImageConfig = UIImage.SymbolConfiguration(pointSize: 40)
        let image = UIImage(systemName: "lock.fill")?
            .withTintColor(lockImageColor, renderingMode: .alwaysOriginal)
            .withConfiguration(lockImageConfig)
        
        $0.image = image
        $0.isHidden = true
        $0.tintColor = .label
    }
    
    // MARK: - Properties
    private var chatRoom: ChatRoom?
    private var coordinator: MainMapCoordinator?
    private var parentVC: UIViewController?
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubviews()
        self.configureConstraints()
        self.bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been impl")
    }
    
    private func addSubviews() {
        self.contentView.addSubview(self.chatRoomImage)
        self.contentView.addSubview(self.infoStackView)
        self.contentView.addSubview(self.chatRoomEnterButton)
        self.contentView.addSubview(self.chatRoomLock)
    }
    
    private func configureConstraints() {
        self.chatRoomImage.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView).offset(8)
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(60)
        }
        
        self.chatRoomEnterButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView).offset(-8)
            make.centerY.equalTo(self.contentView)
            make.width.height.equalTo(40)
        }
        
        self.infoStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.chatRoomImage.snp.trailing).offset(16)
            make.trailing.equalTo(self.chatRoomEnterButton.snp.leading).offset(-16)
            make.top.bottom.equalTo(self.contentView).inset(8)
        }
        
        self.chatRoomLock.snp.makeConstraints { make in
            make.center.equalTo(self.contentView)
        }
    }
    
    private func bind() {
        self.chatRoomEnterButton.rx.tap
            .bind { _ in
                guard let bottomSheetVC = self.parentVC as? BottomSheetViewController,
                      let chatRoomID = self.chatRoom?.uuid
                else { return }
                
                self.coordinator?.closeBottomSheet(bottomSheetVC: bottomSheetVC)
                self.coordinator?.showChatRoomView(chatRoomID: chatRoomID)
            }
            .disposed(by: self.disposeBag)
    }
}

// MARK: - Bind
extension BottomSheetTableViewCell {
    public func fetch(with data: ChatRoom) {
        self.chatRoom = data
        self.chatRoomName.text = data.roomName
        self.chatRoomDescription.text = data.roomDescription
        self.fetch(path: data.roomImagePath)
        self.fetchChatRoomDistance()
    }
    
    private func fetch(path imagePath: String?) {
        guard let path = imagePath,
              let url = URL(string: path)
        else { return }
        
        self.chatRoomImage.kf.setImage(with: url)
    }
    
    func insert(coordinator: MainMapCoordinator?, parentVC: UIViewController?) {
        self.coordinator = coordinator
        self.parentVC = parentVC
    }
    
    private func fetchChatRoomDistance() {
        guard let chatRoomLatitude = self.chatRoom?.latitude,
              let chatRoomLongitude = self.chatRoom?.longitude,
              let chatRoomAccessibleRadius = self.chatRoom?.accessibleRadius
        else { return }
        
        Observable.zip(
            UserDefaults.standard.rx.observe(Double.self, "CurrentUserLatitude"),
            UserDefaults.standard.rx.observe(Double.self, "CurrentUserLongitude")
        )
        .subscribe(onNext: { [weak self] (currentUserLatitude, currentUserLongitude) in
            guard let currentUserLatitude,
                  let currentUserLongitude
            else { return }
            
            let currentUserNCLocation: NCLocation = NCLocation(latitude: currentUserLatitude, longitude: currentUserLongitude)
            let chatRoomNCLocation: NCLocation = NCLocation(latitude: chatRoomLatitude, longitude: chatRoomLongitude)
            let distance = chatRoomNCLocation.distance(from: currentUserNCLocation)
            self?.chatRoomDistance.text = distance < 1000 ? String(format: "%.0f", distance) + " m" : String(format: "%.2f", distance / 1000) + " km"
            self?.chatRoomEnterButton.isEnabled = distance <= chatRoomAccessibleRadius * 1000
        })
        .disposed(by: disposeBag)
    }
}
