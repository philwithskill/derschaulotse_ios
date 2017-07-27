//
//  PlaceUtil.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 20/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class PlaceUtil {
    
    static func iconNameFor(place: GDPlace?) -> String {
        if place == nil {
            return "icon_marker_1"
        }
        
        if place is GDStage {
            if let index = place!.index {
                if index <= 7 {
                    return "icon_marker_\(index)" //we have enough assets
                } else {
                    return "icon_marker_7" //just return default asset
                }
            }
        } else if place is GDParkingArea {
            return "icon_parking"
        }
        
        return "icon_marker_1"
    }    
}
