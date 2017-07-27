//
//  GDSourceObserver.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 29/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

protocol GDSourceObserverProtocol {
    
    associatedtype AssociatesModelElement
    
    var updated : ((([AssociatesModelElement]) -> ()))? { get set }
}
