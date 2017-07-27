//
//  GDViewControllerDatasource.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 13/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDViewControllerDatasource<T: GDModelElement> {
    
    lazy var observer : GDSourceObserver<T> = GDSourceObserver<T>()
    
    lazy var elements : [T] = [T]()
    
    func countOfElements() -> Int {
        return elements.count
    }
    
    func element(atIndex: Int) -> T {
        return elements[atIndex]
    }
}
