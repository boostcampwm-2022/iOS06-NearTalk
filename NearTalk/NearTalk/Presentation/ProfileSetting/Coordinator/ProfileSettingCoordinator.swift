//
//  ProfileSettingCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/22.
//

import Foundation
import PhotosUI
import RxRelay
import RxSwift
import UIKit

protocol ProfileSettingCoordinatorDependency {
    func makeProfileSettingViewController(action: ProfileSettingViewModelAction) -> ProfileSettingViewController
}

final class ProfileSettingCoordinator: NSObject, Coordinator {
    private let dependency: any ProfileSettingCoordinatorDependency
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator]
    
    init(navigationController: UINavigationController?,
         parentCoordinator: Coordinator? = nil,
         dependency: any ProfileSettingCoordinatorDependency) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.childCoordinators = []
        self.dependency = dependency
    }
    
    func start() {
        showProfileSettingViewController()
    }
    
    func showProfileSettingViewController() {
        let action: Action = Action(
            presentUpdateFailure: self.presentUpdateFailure,
            presentImagePicker: self.presentImagePicker)
        let profileSettingViewController: ProfileSettingViewController = self.dependency.makeProfileSettingViewController(action: action)
        self.navigationController?.pushViewController(profileSettingViewController, animated: true)
    }
    
    struct Action: ProfileSettingViewModelAction {
        let presentUpdateFailure: (() -> Void)?
        let presentImagePicker: ((BehaviorRelay<Data?>) -> Void)?
    }
    
    private var imageObserver: BehaviorRelay<Data?>?
}

extension ProfileSettingCoordinator {
    func presentImagePicker(observer: BehaviorRelay<Data?>) {
        self.imageObserver = observer
        self.showPHPickerViewController()
    }
    
    func presentUpdateFailure() {
        let alert: UIAlertController = .init(
            title: "업데이트 실패",
            message: "프로필 수정에 실패했습니다. 조금 있다 다시 시도해보세요",
            preferredStyle: .alert)
        let action: UIAlertAction = .init(title: "OK", style: .destructive)
        alert.addAction(action)
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
}

extension ProfileSettingCoordinator {
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
}

extension ProfileSettingCoordinator {
    func showPHPickerViewController() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorization in
            switch authorization {
            case .authorized, .limited:
                Task {
                    await self.presentUIImagePickerViewController()
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
}

extension ProfileSettingCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @MainActor
    private func presentUIImagePickerViewController() {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.navigationController?.topViewController?.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.resizeImageByUIGraphics(image: image)
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.resizeImageByUIGraphics(image: image)
        } else {
            self.imageObserver?.accept(nil)
            self.imageObserver = nil
        }
    }
    
    func resizeImageByUIGraphics(image: UIImage) {
        let widthInPixel: CGFloat = image.scale * image.size.width
        let heightInPixel: CGFloat = image.scale * image.size.height
        let percentage: CGFloat = min(320.0 / (heightInPixel), min(1.0, 320.0 / (widthInPixel)))
        let newImage = image.resized(withPercentage: percentage)
        let data = newImage?.jpegData(compressionQuality: percentage)
        self.imageObserver?.accept(data)
        self.imageObserver = nil
    }
}
