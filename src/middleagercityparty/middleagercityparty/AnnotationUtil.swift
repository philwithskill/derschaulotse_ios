//
//  AnnotationUtil.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 12/02/2017.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation
import AddressBook
import MapKit

class AnnotationUtil {
    
    static func toMapItem(_ annotation : PlaceAnnotation) -> MKMapItem {
        let addressDict = [String(kABPersonAddressStreetKey): annotation.title]
        let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: addressDict)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = annotation.title
        
        return mapItem
    }
    
}
