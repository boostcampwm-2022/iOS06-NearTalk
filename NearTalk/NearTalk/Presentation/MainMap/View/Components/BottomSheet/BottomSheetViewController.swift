//
//  BottomSheetViewController.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/17.
//
//

import SnapKit
import UIKit

final class BottomSheetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureBottomSheet()
    }
    
    private func configureBottomSheet() {
        self.view.backgroundColor = .systemOrange
        
        if let sheetController = self.sheetPresentationController {
            sheetController.detents = [.medium(), .large()]
            sheetController.preferredCornerRadius = 20
            sheetController.prefersGrabberVisible = true
        }
    }
}
