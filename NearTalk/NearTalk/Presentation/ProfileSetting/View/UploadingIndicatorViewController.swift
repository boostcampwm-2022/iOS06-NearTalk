//
//  UploadingIndicatorViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/03.
//

import UIKit

final class UploadIndicatorViewController: UIViewController {
    private let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureIndicator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.indicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.indicator.startAnimating()
    }
}

private extension UploadIndicatorViewController {
    func configureView() {
        self.view.backgroundColor = .init(white: 1.0, alpha: 0.8)
    }
    
    func configureIndicator() {
        self.view.addSubview(indicator)
        self.indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
