//
//  ChatViewController.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

class ChatViewController: UIViewController {
    var messgeList: [MessageItem] = []
    struct MessageItem: Hashable {
        var id: String
        var message: String?
    }

    enum Section {
        case me
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, MessageItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MessageItem>

    private lazy var dataSource: DataSource = makeDataSource()

    private let collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 1
        $0.minimumInteritemSpacing = 1
        $0.scrollDirection = .vertical
        
    }
    
    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout).then {
        $0.backgroundColor = .systemGreen
        $0.showsVerticalScrollIndicator = false
        $0.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: ChatCollectionViewCell.identifier)
        $0.delegate = self
    }
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = ChatInputAccessoryView().then {
        $0.backgroundColor = .systemPurple
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        
        // 키보드
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandler(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandler(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // diffableDataSource
        applySnapshot(animatingDifferences: false)
        
        // 전송 버튼
        chatInputAccessoryView.sendButton.addTarget(self, action: #selector(tapSendButton(_:)), for: .touchUpInside)        
    }
    
    private func addSubviews() {
        [collectionView, chatInputAccessoryView].forEach {
            self.view.addSubview($0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(50)
        }
        
        chatInputAccessoryView.snp.makeConstraints { make in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(50)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    @objc
    private func keyboardHandler(_ notification: Notification) {
        print(#function)
        
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]  as? NSValue,
              let keyboardAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let keyboardCurve = UIView.AnimationCurve(rawValue: keyboardAnimationCurve)
        else {
            return
        }
        
        let keyboardSize = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardSize.height
        
        let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0)
        let bottomConstant: CGFloat = 20
        let newConstant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
        
        self.chatInputAccessoryView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().inset(newConstant)
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(50)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.collectionView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(chatInputAccessoryView.snp.top) // .inset(newConstant)
        }
        
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
        scrolltoBottom()
    }
    
    @objc
    private func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
        self.chatInputAccessoryView.snp.remakeConstraints { make in
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(50)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.collectionView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(50)
        }
    }
    
    @objc
    private func tapSendButton(_ sender: Any) {
        guard let text = chatInputAccessoryView.messageInputTextField.text else {
            return
        }
        chatInputAccessoryView.messageInputTextField.text = ""
        
        print("전송확인>>>>>>>>>>>", text)
        messgeList.append(MessageItem(id: UUID().uuidString, message: text))
        applySnapshot()
        
        let indexPath = IndexPath(item: messgeList.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    private func makeDataSource() -> DataSource {
        let datasource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatCollectionViewCell.identifier,
                for: indexPath) as? ChatCollectionViewCell,
                  let newMessage = itemIdentifier.message
            else {
                return UICollectionViewCell()
            }
            cell.textAlignment = true
            cell.message = newMessage
            cell.sizeToFit()
            cell.frame.size = CGSize(width: self.view.frame.width, height: 100)
            return cell
        }
        return datasource
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.me])
        snapshot.appendItems(messgeList)
//        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func scrolltoBottom() {
        let indexPath = IndexPath(item: messgeList.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
}
