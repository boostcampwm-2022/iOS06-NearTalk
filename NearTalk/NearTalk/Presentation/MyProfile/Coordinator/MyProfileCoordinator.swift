//
//  MyProfileCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import PhotosUI
import RxCocoa
import RxSwift
import UIKit

protocol MyProfileCoordinatorDependency {
    func makeMyProfileViewController() -> MyProfileViewController
}

final class MyProfileCoordinator: Coordinator {
    var navigationController: UINavigationController?
    
    weak var parentCoordinator: Coordinator?
    
    var childCoordinators: [Coordinator] = []
    
    func start() {
        showMyProfileViewController()
    }
    
    init(navigationController: UINavigationController? = nil, parentCoordinator: Coordinator? = nil, childCoordinators: [Coordinator] = []) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.childCoordinators = childCoordinators
    }
    
    func showMyProfileViewController() {
        let vc: MyProfileViewController = MyProfileViewController(
            coordinator: self,
            viewModel: DefaultMyProfileViewModel(
                profileLoadUseCase: DefaultMyProfileLoadUseCase(
                    profileRepository: DefaultUserProfileRepository(),
                    uuidRepository: DefaultUserUUIDRepository())))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAppSettingViewController() {
        let vc: AppSettingViewController = AppSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfileSettingViewController() {
        let vc: ProfileSettingViewController = ProfileSettingViewController(coordinator: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private var imageReceiveHandler: Binder<UIImage?>?
}

extension MyProfileCoordinator: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider else {
            return
        }
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(
                ofClass: UIImage.self,
                completionHandler: { [weak self] image, _ in
                guard let image = image as? UIImage, let handler = self?.imageReceiveHandler else {
                    return
                }
                handler.onNext(image)
                self?.imageReceiveHandler = nil
            })
        } else {
            #if DEBUG
            print("Cannot Import Photo")
            #endif
        }
    }
    
    func showPHPickerViewController(_ imageSelectHandler: Binder<UIImage?>) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorization in
            switch authorization {
            case .authorized, .limited:
                Task {
                    await self.presentPHPickerViewController(imageSelectHandler)
                }
            default:
                #if DEBUG
                print("Photo 접근 권한 없어용")
                #endif
                Task {
                    await self.goAuthorizationSettingPage()
                }
            }
        }
    }
    
    @MainActor
    private func goAuthorizationSettingPage() {
        guard let appName = Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String else {
            return
        }
        let message: String = "\(appName)이(가) 앨범 접근 허용되어 있지않습니다. \r\n 설정화면으로 가시겠습니까?"
        let alert = UIAlertController(title: "설정", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .default) { (UIAlertAction) in
            print("\(String(describing: UIAlertAction.title)) 클릭")
        }
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
            self.navigationController?.topViewController?.dismiss(animated: false)
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }

        alert.addAction(cancel)
        alert.addAction(confirm)
        
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
    
    @MainActor
    private func presentPHPickerViewController(_ imageSelectHandler: Binder<UIImage?>) {
        guard let callerViewController = self.navigationController?.topViewController else { return }
        var config: PHPickerConfiguration = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let vc: PHPickerViewController = PHPickerViewController(configuration: config)
        vc.delegate = self
        self.imageReceiveHandler = imageSelectHandler
        self.navigationController?.topViewController?.present(vc, animated: true)
    }
}
