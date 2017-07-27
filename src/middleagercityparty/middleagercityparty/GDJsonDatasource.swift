//
//  GDJsonDatasource.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 24/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class GDJsonDatasource : AbstractDatasource {
    
    func refresh(fromJson: JSONObject) throws {
        try checkTransactionStarted()
        
        let shows = parseShows(fromJson: fromJson)
        let places = parsePlaces(fromJson: fromJson)
        let times = parseTimes(fromJson: fromJson)
        let rels = parseRelations(fromJson: fromJson)
        
        try connect(shows: shows, withTimes: times, byResolvingRelations: rels.showTimeRelations)
        try connect(shows: shows, withStages: places, byResolvingRelations: rels.showStageRelations)
                
        try add(shows: shows)
        try add(times: times)
        try dayetize(times: times)
        let stages = places.filter { $0 is GDStage } as! [GDStage]
        let parkingAreas = places.filter {$0 is GDParkingArea } as! [GDParkingArea]
        let toilets = places.filter { $0 is GDToilet } as! [GDToilet]
        
        try add(stages: stages)
        try add(parkingAreas: parkingAreas)
        try add(toilets: toilets)
    }
    
    private func parseShows(fromJson: JSONObject) -> [GDShow]{
        let showsJson = fromJson["shows"] as! JSONArray
        let parser = GDMiddleagerJsonParser()
        let shows = parser.shows(fromJson: showsJson)
        return shows
    }
    
    private func parseTimes(fromJson: JSONObject) -> [GDTime] {
        let json = fromJson["times"] as! JSONArray
        let parser = GDMiddleagerJsonParser()
        let times = parser.times(fromJson: json)
        return times
    }
    
    private func parsePlaces(fromJson: JSONObject) -> [GDPlace] {
        let json = fromJson["places"] as! JSONArray
        let parser = GDMiddleagerJsonParser()
        let places = parser.places(fromJson: json)
        return places
    }
    
    private func parseRelations(fromJson: JSONObject) -> (showStageRelations: [GDShowStageRelation], showTimeRelations: [GDShowTimeRelation]) {
        let parser = GDMiddleagerJsonParser()
        let showsJson = fromJson["shows"] as! JSONArray
        let rels = parser.relations(fromShowsJson: showsJson)
        return rels
    }
    
    private func connect(shows: [GDShow], withStages: [GDPlace], byResolvingRelations: [GDShowStageRelation]) throws {
        try byResolvingRelations.forEach { (rel) in
            try connect(shows: shows, withStages: withStages, byResolvingRelation: rel)
        }
    }
    
    private func connect(shows: [GDShow], withTimes: [GDTime], byResolvingRelations: [GDShowTimeRelation]) throws {
        try byResolvingRelations.forEach { (rel) in
            try connect(shows: shows, withTimes: withTimes, byResolvingRelation: rel)
        }
    }
    
    private func connect(shows: [GDShow], withTimes: [GDTime], byResolvingRelation: GDShowTimeRelation) throws {
        let showIndex = shows.index { (show) -> Bool in
            return show.id == byResolvingRelation.idShow
        }
        
        let timeIndex = withTimes.index { (time) -> Bool in
            return time.id == byResolvingRelation.idTime
        }
        
        if showIndex != nil && timeIndex != nil {
            let show = shows[showIndex!]
            let time = withTimes[timeIndex!]
            
            show.time = time
        } else if showIndex == nil {
            throw DatasourceError.inconsistentData(expected: "Expected show with id \(byResolvingRelation.idShow)")
        } else if timeIndex == nil {
            throw DatasourceError.inconsistentData(expected: "Expected time with id \(byResolvingRelation.idTime)")
        }
    }
    
    private func connect(shows: [GDShow], withStages: [GDPlace], byResolvingRelation: GDShowStageRelation) throws {
        let showIndex = shows.index { (show) -> Bool in
            return show.id == byResolvingRelation.idShow
        }
        
        let stageIndex = withStages.index { (stage) -> Bool in
            return stage.id == byResolvingRelation.idPlace
        }
        
        if showIndex != nil && stageIndex != nil {
            let show = shows[showIndex!]
            let stage = withStages[stageIndex!] as! GDStage
            
            show.stage = stage
        } else if showIndex == nil {
            throw DatasourceError.inconsistentData(expected: "Expected show with id \(byResolvingRelation.idShow)")
        } else if stageIndex == nil {
            throw DatasourceError.inconsistentData(expected: "Expected stage with id \(byResolvingRelation.idPlace)")
        }
    }
    
    private func dayetize(times: [GDTime]) throws {
        
        var lastTime : GDTime? = nil
        var day : GDDay? = nil
        var id = 1
        try times.forEach { (time) in
            if lastTime == nil {
                day = GDDay(id: id)
                id = id + 1
                day?.begin = time.date
            } else if TimeUtil.isNewDay(first: lastTime!.date!, second: time.date!) {
                day?.end = lastTime?.date
                try add(day: day!)
                
                day = GDDay(id: id)
                id = id + 1
                day?.begin = time.date
            }
            
            day?.add(time: time)
            time.shows.forEach({ (show) in
                day?.add(show: show)
            })
            
            lastTime = time
        }
        
        day?.end = lastTime?.date
        try add(day: day!)
    }
}
