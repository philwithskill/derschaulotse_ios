    //
//  Show.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 08/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDShow : GDModelElement {
    
    var time : GDTime? {
        willSet {
            if self.time !== newValue {
                self.time?.remove(show: self)
            }
        }
        
        didSet {
            if oldValue !== self.time {
                self.time?.add(show: self)
            }
        }
    }
    
    var stage : GDStage? {
        willSet {
            if self.stage !== newValue {
                self.stage?.remove(show: self)
            }
        }
        
        didSet {
            if oldValue !== self.stage {
                self.stage?.add(show: self)
            }
        }
    }

    var name : String?
    
    var day : GDDay? {
        willSet {
            if self.day !== newValue {
                self.day?.remove(show: self)
            }
        }
        
        didSet {
            if oldValue !== self.day {
                self.day?.add(show: self)
            }
        }
    }
}
