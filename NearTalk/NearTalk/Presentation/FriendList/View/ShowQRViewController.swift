//
//  ShowQRViewController.swift
//  NearTalk
//
//  Created by 고병학 on 2022/12/14.
//

import SnapKit
import Then
import UIKit

// 내 UUID를 QR코드로 보여주는 viewcontroller
final class ShowQRViewController: UIViewController {
    // MARK: - UI properties
    private lazy var qrImageView: UIImageView = UIImageView().then {
        $0.backgroundColor = UIColor.primaryBackground
        $0.image = self.generateQRCode(from: self.myUUID)
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .label
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Properties
    private let myUUID: String
    
    // MARK: - Lifecycles
    static func create(myUUID: String) -> ShowQRViewController {
        let view: ShowQRViewController = ShowQRViewController(myUUID: myUUID)
        return view
    }
    
    init(myUUID: String) {
        self.myUUID = myUUID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubviews()
        self.configureConstraints()
    }
    
    // MARK: - Helper
    private func addSubviews() {
        self.view.addSubview(qrImageView)
        self.view.addSubview(closeButton)
    }
    
    private func configureConstraints() {
        self.configureView()
        self.configureImageView()
        self.configureCloseButton()
    }
    
    private func configureView() {
        self.view.backgroundColor = UIColor.primaryBackground
    }
    
    private func configureImageView() {
        self.qrImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(300)
        }
    }
    
    private func configureCloseButton() {
        self.closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }
    }
    
    // MARK: - Action
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = "neartalk:\(string)".data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
