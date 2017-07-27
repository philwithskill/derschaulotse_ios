//
//  GDTimeDatasource.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 19/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDTimeDatasource : GDViewControllerDatasource<GDTime> {
    
    override var elements: [GDTime] {
        get {
            if datasource != nil {
                return datasource!.times
            } else {
                return [GDTime]()
            }
        }
        set {
            // just needed for overriding
        }

    }
    
    var datasource : AbstractDatasource? {
        willSet {
            //remove old observer
            datasource?.remove(timeObserver: observer)
        }
        
        didSet {
            datasource?.add(timeObserver: observer)
            observer.updated?(datasource?.times ?? [GDTime]())
        }
    }
    
    override var observer: GDSourceObserver<GDTime> {
        willSet {
            datasource?.remove(timeObserver: observer)
        }
        
        didSet {
            datasource?.add(timeObserver: observer)
        }
    }
}
