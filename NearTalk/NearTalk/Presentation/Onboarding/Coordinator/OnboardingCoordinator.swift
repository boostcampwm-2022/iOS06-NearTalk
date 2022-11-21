//
//  OnboardingCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

import Foundation
import PhotosUI
import RxSwift
import UIKit

protocol OnboardingCoordinatorDependency {
    func makeOnboardingViewModel() -> any OnboardingViewModel
}

final class DefaultOnboardingCoordinatorDependency: OnboardingCoordinatorDependency {
    func makeOnboardingViewModel() -> any OnboardingViewModel {
        return DefaultOnboardingViewModel(
            validateUseCase: DefaultOnboardingValidateUseCase(),
            saveProfileUseCase: DefaultOnboardingSaveProfileUseCase(
                profileRepository: DefaultUserProfileRepository(),
                uuidRepository: DefaultUserUUIDRepository(),
                imageRepository: DefaultImageRepository()))
    }
}

final class OnboardingCoordinator: Coordinator {
    private let dependency: any OnboardingCoordinatorDependency
    var navigationController: UINavigationController?
    
    var parentCoordinator: Coordinator?
    
    var childCoordinators: [Coordinator]
    
    init(navigationController: UINavigationController,
         parentCoordinator: Coordinator? = nil,
         dependency: any OnboardingCoordinatorDependency) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.childCoordinators = []
        self.dependency = dependency
    }
    
    func start() {
        showOnboardingViewController()
    }
    
    func showOnboardingViewController() {
        self.navigationController?.pushViewController(
            OnboardingViewController(viewModel: dependency.makeOnboardingViewModel(),
                                     coordinator: self), animated: true)
    }
    
    func finish() {
        
    }
    
    private var imageReceiveHandler: Binder<UIImage?>?
}

extension OnboardingCoordinator: PHPickerViewControllerDelegate {
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
        var config: PHPickerConfiguration = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let vc: PHPickerViewController = PHPickerViewController(configuration: config)
        vc.delegate = self
        self.imageReceiveHandler = imageSelectHandler
        self.navigationController?.topViewController?.present(vc, animated: true)
    }
}
