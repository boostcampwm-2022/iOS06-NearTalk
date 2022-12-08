//
//  AppSettingView.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import AuthenticationServices
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class AppSettingViewController: UIViewController {
    private let tableView: UITableView = UITableView()
    
    private let viewModel: any AppSettingViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private lazy var dataSource: UITableViewDiffableDataSource<AppSettingSection, AppSettingItem> = {
        UITableViewDiffableDataSource<AppSettingSection, AppSettingItem>(tableView: self.tableView) { _, _, item in
            let cell: UITableViewCell

            if item == .alarmOnOff {
                let notiCell = AppSettingTableViewCell()
                self.viewModel.notificationOnOffSwitch
                    .drive(notiCell.toggleSwitch.rx.isOn)
                    .disposed(by: self.disposeBag)
                
                notiCell.toggleSwitch.rx
                    .value
                    .changed
                    .bind { [weak self] toggle in
                    self?.viewModel.notificationSwitchToggled(on: toggle)
                }
                .disposed(by: self.disposeBag)
                
                cell = notiCell
            } else { cell = UITableViewCell() }

            var config: UIListContentConfiguration = cell.defaultContentConfiguration()
            config.text = item.rawValue
            config.textProperties.alignment = .natural
            config.textProperties.font = UIFont.systemFont(ofSize: 16)
            cell.contentConfiguration = config
            cell.backgroundColor = .secondaryBackground
            cell.selectionStyle = .none
            
            return cell
        }
    }()
    
    init(viewModel: any AppSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.configureConstraint()
        self.initDataSource()
        self.configureTableView()
        self.configureNavigationBar()
        self.bindToModel()
    }
    
    override func viewDidLayoutSubviews() {
        self.viewModel.viewWillAppear()
        super.viewDidLayoutSubviews()
        
        tableView.snp.remakeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(15)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(self.tableView.visibleCells.reduce(0, { partialResult, cell in
                partialResult + cell.frame.height
            }))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.viewWillAppear()
        super.viewWillAppear(animated)
    }
}

extension AppSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.tableRowSelected(item: self.dataSource.itemIdentifier(for: indexPath))
    }
}

private extension AppSettingViewController {
    func configureUI() {
        navigationItem.title = "앱 설정"
        view.addSubview(tableView)
        view.backgroundColor = .primaryBackground
    }
    
    func configureNavigationBar() {
        let newNavBarAppearance: UINavigationBarAppearance = UINavigationBarAppearance()
        newNavBarAppearance.configureWithOpaqueBackground()
        newNavBarAppearance.backgroundColor = .secondaryBackground
        
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationItem.standardAppearance = newNavBarAppearance
        self.navigationItem.compactAppearance = newNavBarAppearance
        self.navigationItem.scrollEdgeAppearance = newNavBarAppearance
        self.navigationItem.compactScrollEdgeAppearance = newNavBarAppearance
    }
    
    func configureConstraint() {
        tableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(15)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            $0.bottom.equalToSuperview()
        }
    }
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.register(
            AppSettingTableViewCell.self,
            forCellReuseIdentifier: AppSettingTableViewCell.identifier)
        self.tableView.dataSource = self.dataSource
        self.tableView.separatorInset = .zero
        self.tableView.layer.cornerRadius = 5.0
        self.tableView.isScrollEnabled = false
    }
    
    func initDataSource() {
        var snapshot: NSDiffableDataSourceSnapshot = self.dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(AppSettingItem.allCases, toSection: .main)
        self.dataSource.apply(snapshot)
    }
    
    func bindToModel() {
        self.bindToTouchEnable()
    }
    
    func bindToTouchEnable() {
        self.viewModel.interactionEnable
            .drive(self.tableView.rx.isUserInteractionEnabled)
            .disposed(by: self.disposeBag)
    }
}

extension AppSettingViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let userIdentifier = appleIDCredential.identityToken,
                  let idTokenString = String(data: userIdentifier, encoding: .utf8)
            else {
#if DEBUG
                print("Faile to fetch id token")
#endif
                return
            }
            
            self.viewModel.reauthenticate(token: idTokenString)
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
#if DEBUG
        print("apple authorization error: \(error)")
#endif
        self.viewModel.failToAuthenticate()
    }
    
    func presentReauthenticationViewController() {
        let appleIDProvider: ASAuthorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
        let request: ASAuthorizationAppleIDRequest = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let authorizationController: ASAuthorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}
