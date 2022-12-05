//
//  RxMKMapViewDelegateProxy.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/28.
//

import MapKit
import RxCocoa
import RxSwift

extension MKMapView: HasDelegate {
    public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {

    public weak private(set) var mapView: MKMapView?

    public init(mapView: ParentObject) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}
