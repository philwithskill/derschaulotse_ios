//
//  ModelUtil.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 23/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class ModelUtil {
    static func contains(element: GDModelElement, inCollection: [GDModelElement]) -> Bool{
        return inCollection.contains { (el) -> Bool in
            return el.id == element.id
        }
    }
    
    static func element(forId : Int, inCollection: [GDModelElement]) -> GDModelElement? {
        if let index = indexOfModelElement(withId: forId, inCollection: inCollection) {
            return inCollection[index]
        } else {
            return nil
        }
    }
    
    static func indexOfModelElement(withId: Int, inCollection: [GDModelElement]) -> Int? {
        return inCollection.index(where: { (el) -> Bool in
            return el.id == withId
        })
    }
}
