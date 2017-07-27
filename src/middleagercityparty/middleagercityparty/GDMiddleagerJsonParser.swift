//
//  MiddleagerJsonParser.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 20/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDMiddleagerJsonParser {
    
    func shows(fromJson: JSONArray) -> [GDShow] {
        var result = [GDShow]()
        fromJson.forEach { (object : AnyObject) in
            let showJson = object as! JSONObject
            let s = show(fromJson: showJson)
            result.append(s)
        }
        return result
    }
    
    func show(fromJson: JSONObject) -> GDShow {
        let id = fromJson["id"] as! Int
        let name = fromJson["name"] as? String
        
        let show = GDShow(id: id)
        show.name = name

        return show
    }
    
    func places(fromJson: JSONArray) -> [GDPlace] {
        var result = [GDPlace]()
        fromJson.forEach { (object : AnyObject) in
            let placeJson = object as! JSONObject
            let p = place(fromJson: placeJson)
            result.append(p)
        }
        return result
    }
    
    func place(fromJson: JSONObject) -> GDPlace {
        let id = fromJson["id"] as! Int
        let name = fromJson["name"] as? String
        let lat = fromJson["lat"] as? Double
        let lon = fromJson["lon"] as? Double
        let index = fromJson["index"] as? Int
        let type = fromJson["type"] as? String

        var place : GDPlace
        if "Stage" == type {
            place = GDStage(id: id)
        } else if "ParkingArea" == type {
            place = GDParkingArea(id: id)
        } else if "Toilet" == type {
            place = GDToilet(id: id)
        } else {
            place = GDPlace(id: id)
        }
        
        place.name = name
        place.lat = lat
        place.lon = lon
        place.index = index
        
        return place
    }
    
    func times(fromJson: JSONArray) -> [GDTime] {
        var result = [GDTime]()
        fromJson.forEach { (object : AnyObject) in
            let timeJson = object as! JSONObject
            let t = time(fromJson: timeJson)
            result.append(t)
        }
        
        return result
    }
    
    func time(fromJson: JSONObject) -> GDTime {
        let id = fromJson["id"] as! Int
        let startStamp = fromJson["startStamp"] as? Double
        
        var start : Date? = nil
        if let s = startStamp {
            let seconds = s / 1000 //ms to s
            start = Date(timeIntervalSince1970: seconds)
        }
        
        let time = GDTime(id: id)
        time.date = start
        
        return time
    }
    
    func relations(fromShowsJson: JSONArray) -> (showStageRelations: [GDShowStageRelation], showTimeRelations: [GDShowTimeRelation]) {
        var showStageRelations = [GDShowStageRelation]()
        var showTimeRelations = [GDShowTimeRelation]()
        
        fromShowsJson.forEach { (object) in
            let showJson = object as! JSONObject
            if let showStageRel = showStageRelation(fromShowJson: showJson) {
                showStageRelations.append(showStageRel)
            }
            
            let showTimeRel = showTimeRelation(fromShowJson: showJson)
            showTimeRelations.append(showTimeRel)
        }
        
        return (showStageRelations, showTimeRelations)
    }
    
    func showStageRelation(fromShowJson: JSONObject) -> GDShowStageRelation? {
        let idShow = fromShowJson["id"] as! Int
        let idPlace = fromShowJson["idPlace"] as? Int
        
        if idPlace != nil {
            let rel = GDShowStageRelation(idShow: idShow, idPlace: idPlace!)
    
            return rel
        } else {
            return nil
        }
    }
    
    func showTimeRelation(fromShowJson: JSONObject) -> GDShowTimeRelation {
        let idShow = fromShowJson["id"] as! Int
        let idTime = fromShowJson["idTime"] as! Int
        
        let rel = GDShowTimeRelation(idShow: idShow, idTime: idTime)
        rel.idShow = idShow
        rel.idTime = idTime
        
        return rel
    }
}
