//
//  NCMapRegion.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/29.
//

import Foundation

struct NCMapRegion {
    let centerLocation: NCLocation
    let latitudeDelta: Double
    let longitudeDelta: Double
    
    init(centerLocation: NCLocation, latitudeDelta: Double, longitudeDelta: Double) {
        self.centerLocation = centerLocation
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
}
