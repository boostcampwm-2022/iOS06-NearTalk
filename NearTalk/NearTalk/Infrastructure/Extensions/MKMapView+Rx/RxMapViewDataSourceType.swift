//
//  RxMapViewDataSourceType.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/28.
//

import MapKit
import RxSwift

public protocol RxMapViewDataSourceType {
    associatedtype Element

    func mapView(_ mapView: MKMapView, observedEvent: Event<[Element]>)
}
