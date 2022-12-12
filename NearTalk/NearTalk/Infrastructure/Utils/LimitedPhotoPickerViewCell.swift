//
//  LimitedPhotoPickerViewCell.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/11.
//

import Photos
import SnapKit
import UIKit

final class LimitedPhotoPickerViewCell: UICollectionViewCell {
    static let identifer: String = String(describing: UICollectionViewCell.self)
    
    private let imageView: UIImageView = UIImageView()
    private let checkMark: UIImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")).then {
        $0.tintColor = .secondaryColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addViews()
        self.configConstraints()
        
        self.isUserInteractionEnabled = true
        self.checkMark.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.isSelected = false
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = UIColor.secondaryColor?.cgColor
                self.layer.borderWidth = 2.0
            } else {
                self.layer.borderWidth = 0.0
                self.layer.borderColor = nil
            }
            self.checkMark.isHidden = !isSelected
        }
    }
}

extension LimitedPhotoPickerViewCell {
    var image: UIImage? {
        get {
            self.imageView.image
        } set {
            self.imageView.image = newValue ?? UIImage(systemName: "photo")
        }
    }
}

private extension LimitedPhotoPickerViewCell {
    func addViews() {
        self.addSubview(self.imageView)
        self.imageView.addSubview(self.checkMark)
    }
    
    func configConstraints() {
        self.configImageViewConstraints()
        self.configCheckMarkConstraints()
    }
    
    func configImageViewConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configCheckMarkConstraints() {
        self.checkMark.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.width.height.equalTo(self.snp.width).dividedBy(4)
        }
    }
}
