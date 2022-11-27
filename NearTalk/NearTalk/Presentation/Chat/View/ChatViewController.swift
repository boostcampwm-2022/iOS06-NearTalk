//
//  ChatViewController.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

import RxSwift

class ChatViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private var messgeList: [MessageItem] = []
    
    struct MessageItem: Hashable {
        var id: String
        var message: String?
    }

    enum Section {
        case main
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, MessageItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MessageItem>

    private lazy var dataSource: DataSource = makeDataSource()

    private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout().then { layout in
        layout.scrollDirection = .vertical
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        layout.estimatedItemSize = CGSize(width: width, height: height)
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
    
    private let viewModel: ChatViewModel
    
    // MARK: - Lifecycles
    init(viewModel: ChatViewModel) {
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
        
        // 전송 버튼
//        chatInputAccessoryView.sendButton.addTarget(self, action: #selector(tapSendButton(_:)), for: .touchUpInside)
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
    
    private func scrolltoBottom() {
        let indexPath = IndexPath(item: messgeList.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    private func bind() {
//        chatInputAccessoryView.sendButton.rx.tap
//            .withLatestFrom(chatInputAccessoryView.messageInputTextField.rx.text)
            
                
//            self?.chatInputAccessoryView.messageInputTextField.text = nil
//
//            self.viewModel.sendMessage($0)
//            self.messgeList.append(MessageItem(id: UUID().uuidString, message: $0))
//            self.applySnapshot()
//
//            let indexPath = IndexPath(item: self.messgeList.count - 1, section: 0)
//            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - Diffable ataSource

private extension ChatViewController {
    func makeDataSource() -> DataSource {
        let datasource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatCollectionViewCell.identifier,
                for: indexPath) as? ChatCollectionViewCell,
                  let newMessage = itemIdentifier.message
            else {
                return UICollectionViewCell()
            }
            
            cell.message = newMessage
            
            cell.isInComing = indexPath.row % 2 == 0
            
            print(indexPath.row, cell.isInComing)
            return cell
        }
        return datasource
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(messgeList)
        //        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

//    func com() -> UICollectionViewCompositionalLayout {
//        let itemHeight = self.view.frame.width * 0.20
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                              heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                               heightDimension: .absolute(itemHeight))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
//                                                         subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//    }
