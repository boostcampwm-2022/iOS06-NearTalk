//
//  RangeZoneView.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/15.
//

import UIKit

import SnapKit
import Then

final class RangeZoneView: UIView {
    
    // MARK: - Proporties
    
    var range: String? {
        didSet {
            self.rangeLabel.text = range
        }
    }
    
    // MARK: - UI Proporties
    
    lazy var rangeLabel = UILabel().then {
        $0.text = "0.1 km"
    }
    
    let rangeSlider: UISlider = UISlider().then { slider in
        slider.minimumValue = 0.1
        slider.maximumValue = 1
        slider.value = 0.1
        slider.isContinuous = true
        slider.tintColor = .primaryColor
    }
    
    private lazy var minRangeLabel = UILabel().then {
        $0.text = "0.1 km"
        $0.font = .systemFont(ofSize: 11.0, weight: .light)
    }
    
    private lazy var maxRangeLabel = UILabel().then {
        $0.text = "1 km"
        $0.font = .systemFont(ofSize: 11.0, weight: .light)
    }
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews()
        self.configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension RangeZoneView {
    func addSubviews() {
        [rangeLabel, rangeSlider, minRangeLabel, maxRangeLabel].forEach {
            self.addSubview($0)
        }
    }
    
    func configureConstraints() {
        configureSlider()
        configureLabels()
    }
    
    func configureSlider() {
        self.rangeSlider.snp.makeConstraints {
            $0.top.equalTo(rangeLabel.snp.bottom).inset(-10)
            $0.width.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    func configureLabels() {
        self.rangeLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.equalTo(self.safeAreaLayoutGuide).inset(10)
        }

        self.minRangeLabel.snp.makeConstraints {
            $0.top.equalTo(rangeSlider.snp.bottom).inset(-10)
            $0.leading.equalTo(self.safeAreaLayoutGuide).inset(10)
        }
        
        self.maxRangeLabel.snp.makeConstraints {
            $0.top.equalTo(rangeSlider.snp.bottom).inset(-10)
            $0.trailing.equalTo(self.safeAreaLayoutGuide).inset(10)
        }
    }
}
