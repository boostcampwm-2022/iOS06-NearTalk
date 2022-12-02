import AuthenticationServices
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Then
import UIKit

final class LoginViewController: UIViewController {
    private let logoView = UIImageView(image: UIImage(systemName: "map.circle.fill"))
    private let loginButton = ASAuthorizationAppleIDButton(type: .default, style: .black).then {
        $0.cornerRadius = 5
    }
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
        view.backgroundColor = .white
        self.bindToLoginButton()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
private extension LoginViewController {
    func configureUI() {
        view.addSubview(logoView)
        view.addSubview(loginButton)
    }
    func configureConstraint() {
        self.logoView.snp.makeConstraints { (make) in
            make.height.width.equalTo(240)
            make.center.equalToSuperview()
        }
        
        self.loginButton.snp.makeConstraints { (make) in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(loginButton.snp.width).multipliedBy(0.15)
        }
    }
    
    func loginPressed() {
        let appleIDProvider: ASAuthorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
        let request: ASAuthorizationAppleIDRequest = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let authorizationController: ASAuthorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func bindToLoginButton() {
        loginButton.rx.tapGesture()
            .bind {
                if $0.state == .ended {
                    self.loginPressed()
                }
            }
            .disposed(by: disposeBag)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let userIdentifier = appleIDCredential.identityToken, let idTokenString = String(data: userIdentifier, encoding: .utf8) else {
#if DEBUG
                print("Faile to fetch id token")
#endif
                return
            }
            self.viewModel.requestFireBaseLogin(token: idTokenString)
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
#if DEBUG
        print("apple authorization error: \(error)")
#endif
    }
}
