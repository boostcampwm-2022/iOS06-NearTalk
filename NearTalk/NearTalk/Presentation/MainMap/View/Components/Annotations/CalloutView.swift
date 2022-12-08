//
//  CalloutView.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/12/09.
//

import Kingfisher
import RxSwift
import RxCocoa
import SnapKit
import UIKit

final class CalloutView: UIView {
    // MARK: - UI Compoments
    private let chatRoomImage = UIImageView().then {
        $0.layer.cornerRadius = 30
        $0.image = UIImage(systemName: "photo")
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
        $0.addArrangedSubview(self.chatRoomName)
        $0.addArrangedSubview(self.chatRoomDistance)
    }
    private let chatRoomName = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    private let chatRoomDistance = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    private let chatRoomDescription = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.numberOfLines = 1
    }
    private let chatRoomEnterButton = UIButton().then {
        let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 24)
        let buttonImage = UIImage(systemName: "arrow.right.circle",
                                  withConfiguration: buttonImageConfig)
        $0.setImage(buttonImage, for: .normal)
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
            make.width.height.equalTo(30)
        }
        
        self.chatRoomEnterButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
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
        self.chatRoomDistance.text = self.calcChatRoomDistance(with: chatRoomInfo.location)
        self.fetchImage(path: chatRoomInfo.roomImagePath)
        self.chatRoomDescription.text = chatRoomInfo.roomDescription
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
        else { return }
        
        self.chatRoomImage.kf.setImage(with: url)
    }
    
    private func calcChatRoomDistance(with chatRoomLocation: NCLocation?) -> String {
        guard let chatRoomLocation = chatRoomLocation,
              let userLatitude = UserDefaults.standard.object(forKey: "CurrentUserLatitude") as? Double,
              let userLongitude = UserDefaults.standard.object(forKey: "CurrentUserLongitude") as? Double
        else { return "입장불가" }
        
        let userLocation = NCLocation(latitude: userLatitude, longitude: userLongitude)
        let distance = chatRoomLocation.distance(from: userLocation)
        
        return String(format: "%.2f", distance / 1000) + " km"
    }
}
