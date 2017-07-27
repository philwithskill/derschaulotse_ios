//
//  Stage.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 08/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDStage : GDPlace {
    
    private(set) var shows : [GDShow]
    
    override init(id: Int) {
        shows = [GDShow]()
        super.init(id: id)
    }
    
    @discardableResult
    func add(show : GDShow) -> Bool {
        if ModelUtil.contains(element: show, inCollection: self.shows) {
            return false
        } else {
            shows.append(show)
            show.stage = self
            return true
        }
    }
    
    @discardableResult
    func remove(show: GDShow) -> Bool {
        if let index = ModelUtil.indexOfModelElement(withId: show.id, inCollection: self.shows) {
            let show = shows[index]
            shows.remove(at: index)
            show.stage = nil
            
            return true
        } else {
            return false
        }
    }
}
