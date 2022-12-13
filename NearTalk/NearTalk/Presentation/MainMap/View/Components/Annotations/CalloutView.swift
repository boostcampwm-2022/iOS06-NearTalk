//
//  CalloutView.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/12/09.
//

import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class CalloutView: UIView {
    
    // MARK: - UI Compoments
    private let chatRoomImage = UIImageView().then {
        $0.layer.cornerRadius = 30
        $0.image = UIImage(named: "ChatLogo")
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
        $0.numberOfLines = 1
    }
    private let chatRoomEnterButton = UIButton().then {
        guard let normalColor: UIColor = .secondaryLabel,
              let highlightColor: UIColor = .primaryColor
        else {
            return
        }
        
        let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 24)
        let image = UIImage(systemName: "arrow.right.circle")?
            .withTintColor(normalColor, renderingMode: .alwaysOriginal)
            .withConfiguration(buttonImageConfig)
        let highlightedImage = UIImage(systemName: "arrow.right.circle")?
            .withTintColor(highlightColor, renderingMode: .alwaysOriginal)
            .withConfiguration(buttonImageConfig)
        $0.setImage(image, for: .normal)
        $0.setImage(highlightedImage, for: .highlighted)
    }
    
    // MARK: - Properties
    private let annotation: ChatRoomAnnotation
    private let coordinator: MainMapCoordinator?
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - LifeCycles
    init(annotation: ChatRoomAnnotation, coordinator: MainMapCoordinator?) {
        self.annotation = annotation
        self.coordinator = coordinator

        super.init(frame: .zero)

        self.addSubviews()
        self.configureConstraints()
        self.fetch()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func addSubviews() {
        self.addSubview(self.chatRoomImage)
        self.addSubview(self.infoStackView)
        self.addSubview(self.chatRoomEnterButton)
    }
    
    private func configureConstraints() {
        self.chatRoomImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        self.chatRoomEnterButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        self.infoStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.chatRoomImage.snp.trailing).offset(6)
            make.trailing.equalTo(self.chatRoomEnterButton.snp.leading).offset(-6)
            make.top.bottom.equalToSuperview().inset(4)
        }
    }
    
    private func fetch() {
        let chatRoomInfo = self.annotation.chatRoomInfo
        self.chatRoomName.text = chatRoomInfo.roomName
        self.chatRoomDescription.text = chatRoomInfo.roomDescription
        self.fetchImage(path: chatRoomInfo.roomImagePath)
        self.fetchChatRoomDistance()
    }
    
    private func bind() {
        self.chatRoomEnterButton.rx.tap
            .bind { [weak self] _ in
                if let chatRoomID = self?.annotation.chatRoomInfo.uuid {
                    self?.coordinator?.showChatRoomView(chatRoomID: chatRoomID)
                }
            }
            .disposed(by: self.disposeBag)
    }
}

extension CalloutView {
    private func fetchImage(path imagePath: String?) {
        guard let path = imagePath,
              let url = URL(string: path)
        else {
            return
        }
        
        self.chatRoomImage.kf.setImage(with: url)
    }
    
    private func fetchChatRoomDistance() {
        guard let chatRoomLatitude = self.annotation.chatRoomInfo.latitude,
              let chatRoomLongitude = self.annotation.chatRoomInfo.longitude,
              let chatRoomAccessibleRadius = self.annotation.chatRoomInfo.accessibleRadius
        else {
            return
        }
        
        Observable.zip(
            UserDefaults.standard.rx.observe(Double.self, UserDefaultsKey.currentUserLatitude.string),
            UserDefaults.standard.rx.observe(Double.self, UserDefaultsKey.currentUserLongitude.string)
        )
        .subscribe(onNext: { [weak self] (currentUserLatitude, currentUserLongitude) in
            self?.chatRoomEnterButton.isEnabled = false
            
            guard let currentUserLatitude,
                  let currentUserLongitude
            else {
                return
            }
            
            let currentUserNCLocation: NCLocation = NCLocation(latitude: currentUserLatitude, longitude: currentUserLongitude)
            let chatRoomNCLocation: NCLocation = NCLocation(latitude: chatRoomLatitude, longitude: chatRoomLongitude)
            let distance = chatRoomNCLocation.distance(from: currentUserNCLocation)
            self?.chatRoomDistance.text = distance < 1000 ? String(format: "%.0f", distance) + " m" : String(format: "%.2f", distance / 1000) + " km"
            self?.chatRoomEnterButton.isEnabled = distance <= chatRoomAccessibleRadius * 1000
        })
        .disposed(by: disposeBag)
    }
}
