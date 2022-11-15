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
    // TODO: - 최대 참여 인원 수 의논 필요
    private let rangeList: [Int] = Array((10...100))
    
    private lazy var thumnailImageView = UIImageView().then {
        $0.layer.cornerRadius = 40
        $0.clipsToBounds = true
        $0.backgroundColor = .systemOrange
        
        $0.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.addImageButtonAction))
        $0.addGestureRecognizer(tapGR)
        $0.isUserInteractionEnabled = true
    }

    private lazy var titleTextField = UITextField().then {
        $0.placeholder = "채팅방 제목을 입력해주세요."
        $0.borderStyle = .roundedRect
    }

    private lazy var descriptionTextField = UITextField().then {
        $0.placeholder = "채팅방 상세설명을 입력해주세요."
        $0.borderStyle = .roundedRect
    }
    
    private lazy var limitPickerLabel = UILabel().then {
        $0.text = "최대 참여 인원 수"
        $0.font = .systemFont(ofSize: 11.0, weight: .light)
    }
    
    private lazy var limitPicker = UIPickerView().then {
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var rangeZoneLabel = UILabel().then {
        $0.text = "최대  채팅방 입장 가능 범위"
        $0.font = .systemFont(ofSize: 11.0, weight: .light)
    }
    
    private lazy var rangeZoneView = RangeZoneView()
    
    private lazy var chatButton = UIButton().then {
        $0.setTitle("채팅방 생성하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .bold)
        $0.layer.cornerRadius = 15.0
        $0.backgroundColor = .systemOrange
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configLayout()
    }
}

private extension GroupChatCreationViewController {
    private func configLayout() {
        let stackView = UIStackView(arrangedSubviews: [thumnailImageView, titleTextField, descriptionTextField, limitPickerLabel, limitPicker, rangeZoneLabel, rangeZoneView, chatButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 15.0
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        titleTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(self.view.frame.width)
        }
        
        descriptionTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(self.view.frame.width)
        }
        
        limitPickerLabel.snp.makeConstraints {
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(rangeZoneLabel.font.lineHeight)
        }
        
        limitPicker.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.width.equalTo(self.view.frame.width)
        }
        
        rangeZoneLabel.snp.makeConstraints {
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(rangeZoneLabel.font.lineHeight)
        }
        
        rangeZoneView.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.width.equalTo(self.view.frame.width)
        }

        chatButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(self.view.frame.width)
        }
    }
    
    @objc
    private func addImageButtonAction() {
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
        rangeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if !(0..<rangeList.count).contains(row) {
            return nil
        }
        
        return String(rangeList[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(rangeList[row])
    }
}
