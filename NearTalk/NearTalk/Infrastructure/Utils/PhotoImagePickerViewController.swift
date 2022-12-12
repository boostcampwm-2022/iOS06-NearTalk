//
//  PhotoImagePickerViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/07.
//

import Photos
import UIKit

class PhotoImagePickerViewController: UIViewController {
    func imagePicked(_ image: UIImage?) {}
}

extension PhotoImagePickerViewController {
    func showPHPickerViewController() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorization in
            switch authorization {
            case .authorized, .limited:
                Task(priority: .high) {
                    await MainActor.run { [weak self] in
                        self?.presentLimitedImagePickerViewController()
                    }
                }
            default:
                #if DEBUG
                print("Photo 접근 권한 없습니다")
                #endif
                Task(priority: .high) {
                    await MainActor.run { [weak self] in
                        self?.goAuthorizationSettingPage()
                    }
                }
            }
        }
    }
    
    private func goAuthorizationSettingPage() {
        guard let appName: String = Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String
        else {
            return
        }
        
        let message: String = "\(appName)이(가) 앨범 접근 허용되어 있지않습니다. \r\n 설정화면으로 가시겠습니까?"
        let alert: UIAlertController = UIAlertController(title: "설정", message: message, preferredStyle: .alert)
        let cancel: UIAlertAction = UIAlertAction(title: "취소", style: .default) { (UIAlertAction) in
            print("\(String(describing: UIAlertAction.title)) 클릭")
        }
        let confirm: UIAlertAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.navigationController?.topViewController?.dismiss(animated: false)
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }

        alert.addAction(cancel)
        alert.addAction(confirm)
        
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
    
    private func presentLimitedImagePickerViewController() {
        let imagePicker = LimitedPhotoPickerViewController()
        let nav: UINavigationController = UINavigationController(rootViewController: imagePicker)
        
        imagePicker.itemSelectedEvent = self.imagePicked(_:)
        self.navigationController?.topViewController?.present(nav, animated: true)
    }
    
    func resizeImageByUIGraphics(image: UIImage) -> Data? {
        let widthInPixel: CGFloat = image.scale * image.size.width
        let heightInPixel: CGFloat = image.scale * image.size.height
        let percentage: CGFloat = min(320.0 / (heightInPixel), min(1.0, 320.0 / (widthInPixel)))
        let newImage: UIImage? = image.resized(withPercentage: percentage)
        
        return newImage?.jpegData(compressionQuality: percentage)
    }
}
