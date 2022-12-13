//
//  UIImage+Resize.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/25.
//

import UIKit

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 이미지 리사이즈
    /// 기본적으로 512KB 이하로 압축한다.
    /// 변수 단위는 kB 입니다.
    func resized(toKB size: Double = 512) -> UIImage? {
        guard let imageData = self.jpegData(compressionQuality: 1.0)
        else {
            return nil
        }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / size
        
        while imageSizeKB > size {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.7),
                  let imageData = resizedImage.jpegData(compressionQuality: 1.0)
            else {
                      return nil
                  }
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / size
        }
        
        return resizingImage
    }
}
