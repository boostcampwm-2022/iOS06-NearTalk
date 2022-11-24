//
//  NCLocation.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/17.
//

import Foundation

struct NCLocation: Codable {
    var longitude: Double
    var latitude: Double
    
    // http://wiki.gis.com/wiki/index.php/Decimal_degrees
    func add(longitudeMeters: Double, latitudeMeters: Double) -> NCLocation {
        let decimalDegreePerMeter = 0.00001 / 1.11
        
        return NCLocation(
            longitude: self.longitude + (longitudeMeters * decimalDegreePerMeter),
            latitude: self.latitude + (latitudeMeters * decimalDegreePerMeter)
        )
    }
}
