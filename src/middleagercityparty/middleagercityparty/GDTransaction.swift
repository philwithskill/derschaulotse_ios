//
//  Transaction.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 23/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDTransaction {
    
    private(set) var changes : [() -> ()]
    
    init() {
        changes = [() -> ()]()
    }
    
    func transact(change: @escaping () -> ()) {
        changes.append(change)
    }
    
    func commit() {
        changes.forEach({ (change) in
            change()
        })
        changes.removeAll()
    }
    
    func discard() {
        changes.removeAll()
    }
}
