//
//  NCLocation.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/17.
//

import Foundation

struct NCLocation: Codable {
    static let decimalDegreePerMeter = 0.00001 / 1.11
    
    var longitude: Double
    var latitude: Double
    
    /// http://wiki.gis.com/wiki/index.php/Decimal_degrees
    func add(longitudeMeters: Double, latitudeMeters: Double) -> NCLocation {
        return NCLocation(
            longitude: self.longitude + (longitudeMeters * Self.decimalDegreePerMeter),
            latitude: self.latitude + (latitudeMeters * Self.decimalDegreePerMeter)
        )
    }
    
    func distance(from location: NCLocation) -> Double {
        let longitudeDeltaMeters = abs(self.longitude - location.longitude) * Self.decimalDegreePerMeter
        let latitudeDeltaMeters = abs(self.latitude - location.latitude) * Self.decimalDegreePerMeter
        
        return sqrt(pow(longitudeDeltaMeters, 2) + pow(latitudeDeltaMeters, 2))
    }
}
