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
                repository: DefaultUserProfileRepository()))
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
    
    private var imageReceiveHandler: AnyObserver<UIImage?>?
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
    
    func presentPictureSelectViewController(_ imageSelectHandler: AnyObserver<UIImage?>) {
        guard let calleeViewController = self.navigationController?.topViewController else {
            return
        }
        
        // Check the app's authorization status (either read/write or add-only access).
        var config: PHPickerConfiguration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1

        let phPicker: PHPickerViewController = PHPickerViewController(configuration: config)
        phPicker.delegate = self
        calleeViewController.present(phPicker, animated: true)
        self.imageReceiveHandler = imageSelectHandler
    }
}
