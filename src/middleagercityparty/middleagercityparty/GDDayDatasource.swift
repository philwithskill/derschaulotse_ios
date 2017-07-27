//
//  File.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 19/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDDayDatasource : GDViewControllerDatasource<GDDay> {
    
    override var elements: [GDDay] {
        get {
            if datasource != nil {
                return datasource!.days
            } else {
                return [GDDay]()
            }
        }
        set {
            // just needed for overriding
        }
    }
    
    var datasource : AbstractDatasource? {
        willSet {
            //remove old observer
            datasource?.remove(dayObserver: observer)
        }
        
        didSet {
            datasource?.add(dayObserver: observer)
            observer.updated?(datasource?.days ?? [GDDay]())
        }
    }
    
    override var observer: GDSourceObserver<GDDay> {
        willSet {
            datasource?.remove(dayObserver: observer)
        }
        
        didSet {
            datasource?.add(dayObserver: observer)
        }
    }
}
