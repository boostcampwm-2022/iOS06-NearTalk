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
    
    // MARK: - UI Proporties
    
    lazy var rangeLabel = UILabel().then {
        $0.text = "1km"
    }
    
    lazy var rangeSlider = UISlider().then {
        $0.maximumValue = 10
        $0.minimumValue = 1
        $0.value = 1
    }
    
    private lazy var minRangeLabel = UILabel().then {
        $0.text = "1km"
        $0.font = .systemFont(ofSize: 11.0, weight: .light)
    }
    
    private lazy var maxRangeLabel = UILabel().then {
        $0.text = "10km"
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
