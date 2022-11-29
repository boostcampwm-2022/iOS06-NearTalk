//
//  NCMapRegion.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/29.
//

import Foundation

struct NCMapRegion {
    let centerLocation: NCLocation
    let radiusDistanceMeters: Double
    let latitudinalMeters: Double
    let longitudinalMeters: Double
    
    init(centerLocation: NCLocation, radiusDistanceMeters: Double, latitudinalMeters: Double, longitudinalMeters: Double) {
        self.centerLocation = centerLocation
        self.radiusDistanceMeters = radiusDistanceMeters
        self.latitudinalMeters = latitudinalMeters
        self.longitudinalMeters = longitudinalMeters
    }
}
