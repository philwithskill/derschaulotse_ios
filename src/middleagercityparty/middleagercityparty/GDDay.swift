//
//  Day.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 08/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDDay : GDModelElement {
    
    private(set) var shows : [GDShow]
    
    private(set) var times : [GDTime]
    
    var begin : Date?
    
    var end : Date?
    
    override init(id: Int) {
        shows = [GDShow]()
        times = [GDTime]()
        
        super.init(id: id)
    }
    
    @discardableResult
    func add(show : GDShow) -> Bool {
        if ModelUtil.contains(element: show, inCollection: self.shows) {
            return false
        } else {
            shows.append(show)
            show.day = self
            return true
        }
    }
    
    @discardableResult
    func remove(show: GDShow) -> Bool {
        if let index = ModelUtil.indexOfModelElement(withId: show.id, inCollection: self.shows) {
            let show = shows[index]
            shows.remove(at: index)
            show.day = nil
            
            return true
        } else {
            return false
        }
    }
    
    @discardableResult
    func add(time : GDTime) -> Bool {
        if ModelUtil.contains(element: time, inCollection: self.times) {
            return false
        } else {
            times.append(time)
            time.day = self
            return true
        }
    }
    
    @discardableResult
    func remove(time: GDTime) -> Bool {
        if let index = ModelUtil.indexOfModelElement(withId: time.id, inCollection: self.times) {
            let time = times[index]
            times.remove(at: index)
            time.day = nil
            
            return true
        } else {
            return false
        }
    }
}
