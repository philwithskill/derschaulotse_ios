//
//  GDPlaceDatasource.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 11/02/2017.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDPlaceDatasource : GDViewControllerDatasource<GDPlace> {
    
    override var elements: [GDPlace] {
        get {
            if datasource != nil {
                return datasource!.places
            } else {
                return [GDPlace]()
            }
        }
        set {
            // just needed for overriding
        }
    }
    
    var datasource : AbstractDatasource? {
        willSet {
            //remove old observer
            datasource?.remove(placeObserver: observer)
        }
        
        didSet {
            datasource?.add(placeObserver: observer)
            observer.updated?(datasource?.places ?? [GDPlace]())
        }
    }
    
    override var observer: GDSourceObserver<GDPlace> {
        willSet {
            datasource?.remove(placeObserver: observer)
        }
        
        didSet {
            datasource?.add(placeObserver: observer)
        }
    }
}
