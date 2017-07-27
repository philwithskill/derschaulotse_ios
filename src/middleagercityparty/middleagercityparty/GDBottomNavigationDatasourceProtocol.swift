//
//  GDBottomNavigationDatasource.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 02/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

protocol GDBottomNavigationDatasourceProtocol {
    
    func numberOfItems(forBottomNavigation: GDBottomNavigationController) -> Int
    
    func navigationItemAt(index: Int, forBottomNavigation: GDBottomNavigationController) -> GDNavigationItem
}
