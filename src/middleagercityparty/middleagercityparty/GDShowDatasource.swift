//
//  GDShowDatasource.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 13/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDShowDatasource : GDViewControllerDatasource<GDShow> {
    
    override var elements: [GDShow] {
        get {
            if datasource != nil {
                return datasource!.shows
            } else {
                return [GDShow]()
            }
        }
        set {
            // just needed for overriding
        }
    }
    
    var datasource : AbstractDatasource? {
        willSet {
            //remove old observer
            datasource?.remove(showObserver: observer)
        }
        
        didSet {
            datasource?.add(showObserver: observer)
            observer.updated?(datasource?.shows ?? [GDShow]())
        }
    }
    
    override var observer: GDSourceObserver<GDShow> {
        willSet {
            datasource?.remove(showObserver: observer)
        }
        
        didSet {
            datasource?.add(showObserver: observer)
        }
    }
}
