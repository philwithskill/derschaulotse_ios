//
//  GDModelUpdater.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 30/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDModelUpdater {
    
    lazy var updateServer = GDUrls.updateServer
    
    let source : GDJsonDatasource
    
    let currentDatabase : JSONObject
    
    var onUpdated : ((JSONObject) -> ())?
    
    var onUpdateFailed : (() -> ())?
    
    var onUpdateIgnored : (() -> ())?
    
    init(source: GDJsonDatasource, currentDatabase: JSONObject) {
        self.source = source
        self.currentDatabase = currentDatabase
    }
    
    func update() {
        let url = URL(string: updateServer)
        
        if(url == nil) {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do {
                if error != nil {
                    self.onUpdateFailed?()
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! JSONObject
                
                let newLastUpdated = json["lastUpdated"] as! Int
                let lastUpdated = self.currentDatabase["lastUpdated"] as! Int
                
                if newLastUpdated > lastUpdated {
                    //a bit nasty, I know. But I want to insert the database before updating the source. So I just execute mostly the same code twice.
                    if self.isValid(json) {
                        GDMidleagerDatabase().insert(database: json)
                    }
                    
                    try self.source.startTransaction()
                    try self.source.refresh(fromJson: json)
                    try self.source.commit()
                    self.onUpdated?(json)
                    
                } else {
                    self.onUpdateIgnored?()
                }
                
            } catch {
                self.onUpdateFailed?()
            }
        }
        
        task.resume()
    }
    
    private func isValid(_ newDatabase : JSONObject) -> Bool{
        let helperSource = GDJsonDatasource()
        do {
            try helperSource.startTransaction()
            try helperSource.refresh(fromJson: newDatabase)
            try helperSource.commit()
            return true
        } catch {
            return false
        }
    }
}
