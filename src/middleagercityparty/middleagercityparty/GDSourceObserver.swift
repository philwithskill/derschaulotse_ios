//
//  GDSourceObserver.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 29/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDSourceObserver<T: GDModelElement> : GDSourceObserverProtocol {

    typealias AssociatesModelElement = T

    var updated: (([T]) -> ())?
}
