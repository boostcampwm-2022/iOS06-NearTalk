//
//  ChatViewController.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit
import RxSwift

class ChatViewController: UIViewController {
    // MARK: - Proporties
    
    private let viewModel: ChatViewModel
    private var messgeItems: [MessageItem]
    
    private let disposeBag: DisposeBag = DisposeBag()
    private lazy var dataSource: DataSource = makeDataSource()
    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = self.createLayout()
    
    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: compositionalLayout
    ).then {
        $0.backgroundColor = .systemGreen
        $0.showsVerticalScrollIndicator = false
        $0.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: ChatCollectionViewCell.identifier)
        $0.delegate = self
    }
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = ChatInputAccessoryView().then {
        $0.backgroundColor = .systemPurple
    }
        
    // MARK: - Lifecycles
    
    init(viewModel: ChatViewModel) {
        self.messgeItems = []
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        bind()
        
        // 키보드
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandler(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandler(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // diffableDataSource
        applySnapshot(animatingDifferences: false)
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
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(40.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(40))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func scrolltoBottom() {
        let indexPath = IndexPath(item: messgeItems.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: - Bind
    
    private func bind() {
        chatInputAccessoryView.sendButton.rx.tap
            .withLatestFrom(chatInputAccessoryView.messageInputTextField.rx.text.orEmpty)
            .bind { [weak self] message in
                print("1. 전송할 메세지: ", message)
                self?.viewModel.sendMessage(message)
                self?.chatInputAccessoryView.messageInputTextField.text = nil
            }
            .disposed(by: disposeBag)
        
        self.viewModel.chatMessages
            .subscribe { event in
                switch event {
                case .next(let newMessage):
                    print("3.  받은 메세지: ", newMessage.text ?? "unknown")
                    let messageItem = MessageItem(
                        id: newMessage.uuid ?? UUID().uuidString,
                        message: newMessage.text,
                        type: newMessage.senderID == "532BEDF5-F47C-4D83-A60E-539075D257E0" ? MessageType.send : MessageType.receive
                    )
                    self.messgeItems.append(messageItem)
                    self.applySnapshot()
                    self.scrolltoBottom()
                case .error(let error):
                    print(">>ERROR: ", error)
                case .completed:
                    print(">>observeMessage completed")
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionView Diffable DataSource

private extension ChatViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, MessageItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MessageItem>
    
    enum MessageType: String {
        case send
        case receive
    }
    
    struct MessageItem: Hashable {
        var id: String
        var message: String?
        var type: MessageType
    }

    enum Section {
        case main
    }
    
    func makeDataSource() -> DataSource {
        let datasource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatCollectionViewCell.identifier,
                for: indexPath) as? ChatCollectionViewCell,
                  let newMessage = itemIdentifier.message
            else {
                return UICollectionViewCell()
            }
            
            let messageType = itemIdentifier.type
            cell.configure(isInComing: messageType == .receive ? true : false, message: newMessage)
            
            return cell
        }
        return datasource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(messgeItems)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - Keyboard

private extension ChatViewController {
    @objc
    func keyboardHandler(_ notification: Notification) {
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
    func hideKeyboard(_ sender: Any) {
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
}
