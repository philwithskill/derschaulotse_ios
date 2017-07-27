//
//  Time.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 10/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDTime : GDModelElement {
    
    var date : Date?
    
    private(set) var shows : [GDShow]
    
    var day : GDDay? {
        willSet {
            if self.day !== newValue {
                self.day?.remove(time: self)
            }
        }
        
        didSet {
            if oldValue !== self.day {
                self.day?.add(time: self)
            }
        }
    }
    
    override init(id: Int) {
        self.shows = [GDShow]()
        
        super.init(id: id)
    }
    
    @discardableResult
    func add(show : GDShow) -> Bool {
        if ModelUtil.contains(element: show, inCollection: self.shows) {
            return false
        } else {
            self.shows.append(show)
            show.time = self
            return true
        }
    }
    
    @discardableResult
    func remove(show: GDShow) -> Bool {
        if let index = ModelUtil.indexOfModelElement(withId: show.id, inCollection: self.shows) {
            let show = shows[index]
            self.shows.remove(at: index)
            show.time = nil
            
            return true
        } else {
            return false
        }
    }
}
