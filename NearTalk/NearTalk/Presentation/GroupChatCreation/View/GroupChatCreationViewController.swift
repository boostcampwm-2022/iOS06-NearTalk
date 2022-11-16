//
//  GroupChatCreationViewController.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/15.
//

import PhotosUI
import UIKit

import SnapKit
import Then

class GroupChatCreationViewController: UIViewController {
    
    // MARK: - Proporties
    
    private enum Matric {
        static let cornerRadius: CGFloat = 20.0
        static let buttonFontSize: CGFloat = 15.0
        static let labelFontSize: CGFloat = 11.0
        static let stackViewSpacing: CGFloat = 15.0
    }
    
    private let pickerComponentList: [Int] = Array((10...100))
    
    // MARK: - UI Proporties
    
    private lazy var stackView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fillProportionally
        $0.spacing = Matric.stackViewSpacing
    }
    
    private lazy var thumnailImageView: UIImageView = UIImageView().then {
        $0.layer.cornerRadius = Matric.cornerRadius
        $0.clipsToBounds = true
        $0.backgroundColor = .systemOrange
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.addImageButtonAction))
        $0.addGestureRecognizer(tapGR)
        $0.isUserInteractionEnabled = true
    }

    private lazy var titleTextField: UITextField = UITextField().then {
        $0.placeholder = "채팅방 제목을 입력해주세요."
        $0.borderStyle = .roundedRect
    }

    private lazy var descriptionTextField: UITextField = UITextField().then {
        $0.placeholder = "채팅방 상세설명을 입력해주세요."
        $0.borderStyle = .roundedRect
    }
    
    private lazy var pickerLabel: UILabel = UILabel().then {
        $0.text = "최대 참여 인원 수"
        $0.font = .systemFont(ofSize: Matric.labelFontSize, weight: .light)
    }
    
    private lazy var maxNumOfParticipantsPicker: UIPickerView = UIPickerView().then {
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var rangeZoneLabel: UILabel = UILabel().then {
        $0.text = "최대  채팅방 입장 가능 범위"
        $0.font = .systemFont(ofSize: Matric.labelFontSize, weight: .light)
    }
    
    private lazy var rangeZoneView: RangeZoneView = RangeZoneView()
    
    private lazy var chatButton: UIButton = UIButton().then {
        $0.setTitle("채팅방 생성하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: Matric.buttonFontSize, weight: .bold)
        $0.layer.cornerRadius = Matric.cornerRadius
        $0.backgroundColor = .systemOrange
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubviews()
        self.configureConstraints()
    }
}

private extension GroupChatCreationViewController {
    func addSubviews() {
        [thumnailImageView, titleTextField, descriptionTextField, pickerLabel, maxNumOfParticipantsPicker, rangeZoneLabel, rangeZoneView].forEach {
            self.stackView.addArrangedSubview($0)
        }
        
        [stackView, chatButton].forEach {
            self.view.addSubview($0)
        }
    }
    
    func configureConstraints() {
        self.configureStackView()
        self.configureImageView()
        self.configureTextfields()
        self.configureLabels()
        self.configurePicker()
        self.configRangeZoneView()
        self.configureButtons()
    }
    
    func configureStackView() {
        self.stackView.snp.makeConstraints {
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
    }
    
    func configureImageView() {
        self.thumnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }
    }
    
    func configureTextfields() {
        self.titleTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(self.view.frame.width)
        }
        
        self.descriptionTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(self.view.frame.width)
        }
    }
    
    func configureLabels() {
        self.pickerLabel.snp.makeConstraints {
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(rangeZoneLabel.font.lineHeight)
        }
        
        self.rangeZoneLabel.snp.makeConstraints {
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(rangeZoneLabel.font.lineHeight)
        }
    }
    
    func configurePicker() {
        self.maxNumOfParticipantsPicker.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.width.equalTo(self.view.frame.width)
        }
    }
    
    func configRangeZoneView() {
        self.rangeZoneView.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.width.equalTo(self.view.frame.width)
        }
    }
    
    func configureButtons() {
        self.chatButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    @objc
    func addImageButtonAction() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension GroupChatCreationViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
    }
}

extension GroupChatCreationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.pickerComponentList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if !(0..<self.pickerComponentList.count).contains(row) {
            return nil
        }
        
        return String(self.pickerComponentList[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(self.pickerComponentList[row])
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct GroupChatViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UINavigationController(rootViewController: GroupChatCreationViewController()) .showPreview(.iPhone14Pro)
    }
}
#endif
