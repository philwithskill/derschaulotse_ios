//
//  PlaceAnnotation.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 11/02/2017.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class PlaceAnnotation : NSObject, MKAnnotation {
    var place : GDPlace
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: place.lat!, longitude: place.lon!)
    }
    
    var title: String? {
        return place.name
    }
    
    var image: UIImage? {
        let name = PlaceUtil.iconNameFor(place: place)
        return UIImage(named: name)
    }
    
    
    init(place: GDPlace) {
        self.place = place
        super.init()
    }
}
