//
//  NCLocation.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/17.
//

import Foundation

struct NCLocation: Codable {
    static let defaultNCLocation = NCLocation(longitude: 127.1051, latitude: 37.3589) // Naver 1784
    // 미터 당 위경도
    static let decimalDegreePerMeter = 0.000009009
    
    var longitude: Double
    var latitude: Double
}
