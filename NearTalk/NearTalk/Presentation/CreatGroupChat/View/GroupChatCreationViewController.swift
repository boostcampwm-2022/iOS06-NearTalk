//
//  GroupChatCreationViewController.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/15.
//

import PhotosUI
import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class CreateGroupChatViewController: UIViewController {
    
    // MARK: - Proporties
    private let pickerComponentList: [Int] = Array((10...100))
    private let viewModel: CreateGroupChatViewModel
    private let disposbag: DisposeBag = DisposeBag()
    
    private enum Matric {
        static let cornerRadius: CGFloat = 20.0
        static let buttonFontSize: CGFloat = 15.0
        static let labelFontSize: CGFloat = 11.0
        static let stackViewSpacing: CGFloat = 15.0
    }
    
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
    
    private lazy var createChatButton: UIButton = UIButton().then {
        $0.setTitle("채팅방 생성하기", for: .normal)
        $0.setTitleColor(.red, for: .disabled)
        $0.titleLabel?.font = .systemFont(ofSize: Matric.buttonFontSize, weight: .bold)
        $0.layer.cornerRadius = Matric.cornerRadius
        $0.backgroundColor = .systemOrange
        $0.isEnabled = false
    }
    
    // MARK: - LifeCycle
    
    init(viewModel: CreateGroupChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        self.addSubviews()
        self.configureConstraints()
        self.binding()
        
        // 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - Private

private extension CreateGroupChatViewController {
    @objc
    private func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    func binding() {
        self.titleTextField.rx.text
            .orEmpty
            .bind { [weak self] in
                self?.viewModel.titleDidEdited($0)
            }
            .disposed(by: disposbag)
        
        self.descriptionTextField.rx.text
            .orEmpty
            .bind { [weak self] in
                self?.viewModel.descriptionDidEdited($0)
            }
            .disposed(by: disposbag)
        
        self.maxNumOfParticipantsPicker.rx.itemSelected
            .map {self.pickerComponentList[$0.row]}
            .bind { [weak self] in
                self?.viewModel.maxParticipantDidChanged($0)
            }
            .disposed(by: disposbag)
        
        self.rangeZoneView.rangeSlider.rx.value
            .map({Int($0)})
            .bind { [weak self] in
                self?.viewModel.maxRangeDidChanged($0)
            }
            .disposed(by: disposbag)

        self.createChatButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.createChatButtonDIdTapped()
            }.disposed(by: disposbag)
                
        viewModel.createChatButtonIsEnabled
            .drive(self.createChatButton.rx.isEnabled)
            .disposed(by: disposbag)
        
        viewModel.maxRangeLabel
            .drive(self.rangeZoneView.rangeLabel.rx.text)
            .disposed(by: disposbag)
    }
    
    func addSubviews() {
        [thumnailImageView, titleTextField, descriptionTextField, pickerLabel, maxNumOfParticipantsPicker, rangeZoneLabel, rangeZoneView].forEach {
            self.stackView.addArrangedSubview($0)
        }
        
        [stackView, createChatButton].forEach {
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
        self.createChatButton.snp.makeConstraints {
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

extension CreateGroupChatViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateGroupChatViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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

/// scenedelegate에서 테스트시 필요한 코드 - 삭제 예정
//guard let windowScene = (scene as? UIWindowScene) else { return }
//window = UIWindow(windowScene: windowScene)
//window = UIWindow(windowScene: windowScene)
//window?.backgroundColor = .white
//
//let vm = DefaultCreateGroupChatViewModel(
//    createGroupChatUseCase: CreateGroupChatUseCase(
//        chatRoomListRepository: DefaultChatRoomListRepository(
//            dataTransferService: DefaultStorageService(),
//            profileRepository: DefaultProfileRepository(
//                firestoreService: DefaultFirestoreService(),
//                firebaseAuthService: DefaultFirebaseAuthService()),
//            databaseService: DefaultRealTimeDatabaseService(),
//            firestoreService: DefaultFirestoreService()
//        )), actions: CreateGroupChatViewModelActions(showChatViewController: {print("showChatViewController")}))
//let navigationController = CreateGroupChatViewController(viewModel: vm)
//window?.rootViewController = navigationController
//window?.makeKeyAndVisible()
