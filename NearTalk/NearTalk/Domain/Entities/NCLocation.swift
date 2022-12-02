//
//  NCLocation.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/17.
//

import Foundation

struct NCLocation: Codable {
    // 미터 당 위경도
    static let decimalDegreePerMeter: Double = 0.000009009 // 도/m
    static let meterPerDecimalDegree: Double = 111000 // m/도
    
    var longitude: Double
    var latitude: Double
    
    /// http://wiki.gis.com/wiki/index.php/Decimal_degrees
    func add(longitudeMeters: Double, latitudeMeters: Double) -> NCLocation {
        return NCLocation(longitude: self.longitude + (longitudeMeters * Self.decimalDegreePerMeter),
                          latitude: self.latitude + (latitudeMeters * Self.decimalDegreePerMeter))
    }
    
    func add(longitudeDelta: Double, latitudeDelta: Double) -> NCLocation {
        return NCLocation(longitude: self.longitude + longitudeDelta,
                          latitude: self.latitude + latitudeDelta)
    }
    
    func distance(from location: NCLocation) -> Double {
        let longitudeDeltaMeters = abs(self.longitude - location.longitude) * Self.meterPerDecimalDegree
        let latitudeDeltaMeters = abs(self.latitude - location.latitude) * Self.meterPerDecimalDegree
        
        return sqrt(pow(longitudeDeltaMeters, 2) + pow(latitudeDeltaMeters, 2))
    }
}
