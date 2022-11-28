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

final class OnboardingCoordinator: Coordinator {
    var navigationController: UINavigationController?
    private let imagePublisher: PublishSubject<Data?> = PublishSubject()
    private let onboardingDIContainer: DefaultOnboardingDIContainer
    
    init(
        container: DefaultOnboardingDIContainer,
        navigationController: UINavigationController?
    ) {
        self.onboardingDIContainer = container
        self.navigationController = navigationController
    }
    
    func start() {
        let onboardingViewController: OnboardingViewController = self.onboardingDIContainer.resolveOnboardingViewController()
        self.navigationController?.pushViewController(onboardingViewController, animated: true)
    }
}

extension OnboardingCoordinator {
    #warning("이미지 피커가 뜨지 않습니다")
    func presentImagePicker() -> Single<Data?> {
        return self.imagePublisher.asSingle()
    }
    
    func presentRegisterFailure() {
        let alert: UIAlertController = .init(
            title: "등록 실패",
            message: "프로필 등록에 실패했습니다. 조금 있다 다시 시도해보세요",
            preferredStyle: .alert)
        let action: UIAlertAction = .init(title: "OK", style: .destructive)
        alert.addAction(action)
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
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
                    let imageData: Data? = image as? Data
                    self?.imagePublisher.onNext(imageData)
            })
        } else {
            #if DEBUG
            print("Cannot Import Photo")
            #endif
        }
    }
    
    func showPHPickerViewController() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorization in
            switch authorization {
            case .authorized, .limited:
                Task {
                    await self.presentPHPickerViewController()
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
    private func presentPHPickerViewController() {
        var config: PHPickerConfiguration = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let vc: PHPickerViewController = PHPickerViewController(configuration: config)
        vc.delegate = self
        self.navigationController?.topViewController?.present(vc, animated: true)
    }
}
