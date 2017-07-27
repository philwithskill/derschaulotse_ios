//
//  GDMiddleagerDatabase.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 31/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDMidleagerDatabase {
    
    private let keyDatabase = "de.geekdevelopment.middleagercityparty.database"
    
    var bundle : Bundle?
    
    func insert(database: JSONObject) {
        let defaults = UserDefaults.standard
        defaults.setValue(database, forKey: keyDatabase)
        defaults.synchronize()
    }
    
    func database() -> JSONObject {
        if let databaseDict = UserDefaults.standard.value(forKey: keyDatabase)  {
            let database = databaseDict as! JSONObject
            return database
        } else {
            //first time, we need to insert default database
            var bundle : Bundle
            if self.bundle == nil {
                bundle = Bundle.main
            } else {
                bundle = self.bundle!
            }
            
            let url = bundle.url(forResource: "middleagercityparty", withExtension: "json")
            let jsonData = try! Data(contentsOf: url!)
            let json = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as! JSONObject
            insert(database: json)
            return json
        }
    }
}
