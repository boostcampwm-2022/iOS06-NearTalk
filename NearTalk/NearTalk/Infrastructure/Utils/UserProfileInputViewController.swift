//
//  UserProfileInputViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/06.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class UserProfileInputViewController: PhotoImagePickerViewController {
    // MARK: - UI properties
    let rootView: UserProfileInputView

    private let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.keyboardDismissMode = .onDrag
        $0.bounces = false
    }
    
    // MARK: - Properties
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(inputData: NecessaryProfileComponent) {
        self.rootView = UserProfileInputView(inputData: inputData)
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        self.rootView = UserProfileInputView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.rootView)
        self.configureScrollViewConstraint()
        self.configureRootViewConstraint()
        self.configureNavigationBar()
        self.bindToViewModel()
        self.rootView.designateMessageViewDelegate(self)
    }
    
    // MARK: - Helpers
    func bindDisposable(_ disposable: any Disposable...) {
        self.disposeBag.insert(disposable)
    }
    
    func setNavigationTitle(title: String) {
        self.navigationItem.title = title
    }
    
    func configureNavigationBar() {
        let newNavBarAppearance = UINavigationBarAppearance()
        newNavBarAppearance.configureWithOpaqueBackground()
        newNavBarAppearance.backgroundColor = .secondaryBackground
        
        self.navigationItem.standardAppearance = newNavBarAppearance
        self.navigationItem.compactAppearance = newNavBarAppearance
        self.navigationItem.scrollEdgeAppearance = newNavBarAppearance
        self.navigationItem.compactScrollEdgeAppearance = newNavBarAppearance
    }
    
    func configureScrollViewConstraint() {
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
            make.width.height.equalTo(self.view)
        }
    }
    
    func configureRootViewConstraint() {
        self.rootView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }
    
    func bindToViewModel() {
        self.bindNickNameField()
        self.bindMessageField()
        self.bindProfileTap()
        self.bindRegisterButton()
    }
    
    func bindNickNameField() {
        self.rootView.keyboardWillShowOnNickNameField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: { self.moveKeyboardUp(keyboardPopInfo: $0) })
            .disposed(by: self.disposeBag)
        
        self.rootView.keyboardWillDismissFromNickNameField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: { self.moveKeyboardDown(keyboardPopInfo: $0) })
            .disposed(by: self.disposeBag)
    }
    
    func bindMessageField() {
        self.rootView.keyboardWillShowOnMessageField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: { self.moveKeyboardUp(keyboardPopInfo: $0) })
            .disposed(by: self.disposeBag)
        
        self.rootView.keyboardWillDismissFromMessageField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: { self.moveKeyboardDown(keyboardPopInfo: $0) })
            .disposed(by: self.disposeBag)
    }
    
    func bindProfileTap() {}
    
    func bindRegisterButton() {}
}

private extension UserProfileInputViewController {
    func moveKeyboardUp(keyboardPopInfo: KeyboardPopInfo) {
        self.scrollToUp(keyboardPopInfo: keyboardPopInfo)
    }
    
    func moveKeyboardDown(keyboardPopInfo: KeyboardPopInfo) {
        self.scrollToDown()
    }
    
    func scrollToUp(keyboardPopInfo: KeyboardPopInfo) {
        let keyboardHeight: CGFloat = keyboardPopInfo.frame.height
        let inset: UIEdgeInsets = .init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        self.scrollView.contentInset = inset
        self.scrollView.scrollIndicatorInsets = inset
    }

    func scrollToDown() {
        self.scrollView.contentInset = .zero
        self.scrollView.scrollIndicatorInsets = .zero
    }
}

extension UserProfileInputViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      if text == "\n" { textView.resignFirstResponder() }

      return true
    }
}
