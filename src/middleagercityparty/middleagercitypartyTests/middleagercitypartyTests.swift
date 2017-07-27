//
//  middleagercitypartyTests.swift
//  middleagercitypartyTests
//
//  Created by Philipp Faßheber on 08/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import XCTest
@testable import middleagercityparty

class middleagercitypartyTests: XCTestCase {
    
    // MARK: Attributes
    
    var json : JSONObject?
    
    // MARK: Init - Deinit
    
    override func setUp() {
        super.setUp()
        setupJson()
    }
    
    func setupJson() {
        self.json = createJson(fromName: "middleagercityparty")
    }
    
    func createJson(fromName: String) -> JSONObject {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: fromName, withExtension: "json")
        let jsonData = try! Data(contentsOf: url!)
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as! JSONObject
        return json
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Model Tests
    
    func testBuildModel() {
        var id = 1
        let show = GDShow(id: id)
        id = id + 1
        
        let show2 = GDShow(id: id)
        id = id + 1
        
        let stage1 = GDStage(id: id)
        id = id + 1
        
        let stage2 = GDStage(id: id)
        id = id + 1
        
        let time1 = GDTime(id: id)
        id = id + 1
        
        let time2 = GDTime(id: id)
        id = id + 1
        
        show.time = time1
        time1.add(show: show)
        show.stage = stage1
        stage1.add(show: show)
        
        
        show2.time = time2
        time2.add(show: show2)
        show2.stage = stage2
        stage2.add(show: show2)
        
        assert(show.time === time1)
        assert(time1.shows[0] === show)
        assert(show.stage === stage1)
        assert(stage1.shows[0] === show)
        
        assert(show2.time === time2)
        assert(time2.shows[0] === show2)
        assert(show2.stage === stage2)
        assert(stage2.shows[0] === show2)
        
        time1.add(show: show)
        stage1.add(show: show)
        
        assert(time1.shows.count == 1)
        assert(stage1.shows.count == 1)
        
        time1.remove(show: show)
        stage1.remove(show: show)
        
        time2.remove(show: show2)
        stage2.remove(show: show2)
        
        assert(time1.shows.count == 0)
        assert(time2.shows.count == 0)
        assert(stage1.shows.count == 0)
        assert(stage2.shows.count == 0)
    }
    
    func testRefrentialIntegrity() {
        
        var id = 1
        let show = GDShow(id: id)
        id = id + 1
        
        let show2 = GDShow(id: id)
        id = id + 1
        
        let stage1 = GDStage(id: id)
        id = id + 1
        
        let stage2 = GDStage(id: id)
        id = id + 1
        
        let time1 = GDTime(id: id)
        id = id + 1
        
        let time2 = GDTime(id: id)
        id = id + 1
        
        //add relation one way
        show.time = time1
        show.stage = stage1

        assert(show.time === time1)
        assert(time1.shows.count > 0)
        assert(time1.shows[0] === show)
        assert(show.stage === stage1)
        assert(stage1.shows.count > 0)
        assert(stage1.shows[0] === show)
        
        //add relation the other way around
        time2.add(show: show2)
        stage2.add(show: show2)
        
        assert(show2.time === time2)
        assert(time2.shows.count > 0)
        assert(time2.shows[0] === show2)
        assert(show2.stage === stage2)
        assert(stage2.shows.count > 0)
        assert(stage2.shows[0] === show2)
        
        //switch relation one way
        show.time = time2
        assert(show.time === time2)
        assert(time2.shows.count == 2)
        assert(time1.shows.count == 0)
        assert(time2.shows[1] === show)
        
        //switch relation the other way around
        stage2.add(show: show)
        assert(show.stage === stage2)
        assert(stage2.shows.count == 2)
        assert(stage1.shows.count == 0)
        assert(stage2.shows[1] === show)
        
        //remove relation one way
        assert(show.stage !== nil)
        stage2.remove(show: show)
        assert(stage2.shows.count == 1)
        assert(show.stage === nil)
        
        //remove relation the other way around
        show.time = nil
        assert(time2.shows.count == 1)
        assert(time2.shows[0] !== show)
    }
    
    // MARK: Json Parsing
    
    func testParseShows() {
        let parser = GDMiddleagerJsonParser()
        let showsJson = json!["shows"] as! JSONArray
        let shows = parser.shows(fromJson: showsJson)
        
        assert(showsJson.count == shows.count, "Shows Json and Shows instances have different lengths.")
        assert(shows.count > 0, "No shows where parsed")
        shows.forEach { (show) in
            assert(show.id != 0, "Show has no id")
            assert(show.name != nil, "Show has no name")
        }
    }
    
    func testParsePlaces() {
        let parser = GDMiddleagerJsonParser()
        let json = self.json!["places"] as! JSONArray
        let places = parser.places(fromJson: json)
        
        assert(json.count == places.count, "Places Json and Places instances have different lengths.")
        assert(places.count > 0, "No places where parsed")
        places.forEach { (place) in
            assert(place.id != 0)
            assert(place.lat != 0 && place.lat != nil)
            assert(place.lon != 0 && place.lon != nil)
            assert(place.name != nil)
        }
    }
    
    func testParseTimes() {
        let parser = GDMiddleagerJsonParser()
        let json = self.json!["times"] as! JSONArray
        let times = parser.times(fromJson: json)
        
        assert(json.count == times.count)
        assert(times.count > 0)
        times.forEach { (time) in
            assert(time.id != 0)
            assert(time.date != nil)
        }
    }
    
    func testParseRelations() {
        let parser = GDMiddleagerJsonParser()
        let json = self.json!["shows"] as! JSONArray
        let result = parser.relations(fromShowsJson: json)
        
        let showStageRelations = result.showStageRelations
        let showTimeRelations = result.showTimeRelations
        
        assert(showStageRelations.count > 0)
        assert(showTimeRelations.count > 0)
        
        showStageRelations.forEach { (rel) in
            assert(rel.idShow != 0)
            assert(rel.idPlace > 0)
        }
        
        showTimeRelations.forEach { (rel) in
            assert(rel.idShow != 0)
            assert(rel.idTime != 0)
        }
    }
    
    // MARK: Datasource
    
    func testMissingTransaction() {
        let source = AbstractDatasource()
        do {
            try source.add(parkingArea: GDParkingArea(id: 1))
            assert(false)
        } catch {
            
        }
        
        do {
            try source.add(parkingAreas: [GDParkingArea]())
            assert(false)
        } catch {
            
        }
        
        do {
            try source.add(toilet: GDToilet(id: 1))
            assert(false)
        } catch {
            
        }
        
        do {
            try source.add(toilets: [GDToilet]())
            assert(false)
        } catch {
            
        }
        
        do {
            try source.add(stage: GDStage(id: 1))
            assert(false)
        } catch {
            
        }
        
        do {
            try source.add(stages: [GDStage]())
            assert(false)
        } catch {
            
        }
        
        do {
            try source.add(show: GDShow(id: 1))
            assert(false)
        } catch {
            
        }
        
        do {
            try source.add(shows: [GDShow]())
            assert(false)
        } catch {
            
        }
        
        do {
            try source.add(time: GDTime(id: 1))
            assert(false)
        } catch {
            
        }
        
        do {
            try source.add(times: [GDTime]())
            assert(false)
        } catch {
            
        }
    }
    
    func testTransactionStarted() {
        let source = AbstractDatasource()
        try! source.startTransaction()
        do {
            try source.add(parkingArea: GDParkingArea(id: 1))
        } catch {
            assert(false)
        }
        
        do {
            try source.add(parkingAreas: [GDParkingArea]())
        } catch {
            assert(false)
        }
        
        do {
            try source.add(toilet: GDToilet(id: 1))
        } catch {
            assert(false)
        }
        
        do {
            try source.add(toilets: [GDToilet]())
        } catch {
            assert(false)
        }
        
        do {
            try source.add(stage: GDStage(id: 1))
        } catch {
            assert(false)
        }
        
        do {
            try source.add(stages: [GDStage]())
        } catch {
            assert(false)
        }
        
        do {
            try source.add(show: GDShow(id: 1))
        } catch {
            assert(false)
        }
        
        do {
            try source.add(shows: [GDShow]())
        } catch {
            assert(false)
        }
        
        do {
            try source.add(time: GDTime(id: 1))
        } catch {
            assert(false)
        }
        
        do {
            try source.add(times: [GDTime]())
        } catch {
            assert(false)
        }
        
        try! source.commit()
        do {
            try source.add(times: [GDTime]())
            assert(false)
        } catch {
    
        }
    }
    
    func testCommitTransaction() {
        let source = AbstractDatasource()
        
        do {
            try source.startTransaction()
            
            let show1 = GDShow(id: 1)
            let show2 = GDShow(id: 2)
            let show3 = GDShow(id: 3)
            let shows = [show2, show3]
            
            try source.add(show: show1)
            try source.add(shows: shows)
            
            let stage1 = GDStage(id: 1)
            let stage2 = GDStage(id: 2)
            let stage3 = GDStage(id: 3)
            let stages = [stage2, stage3]
            
            try source.add(stage: stage1)
            try source.add(stages: stages)
            
            let parkingArea1 = GDParkingArea(id: 1)
            let parkingArea2 = GDParkingArea(id: 2)
            let parkingArea3 = GDParkingArea(id: 3)
            let parkingAreas = [parkingArea2, parkingArea3]
            
            try source.add(parkingArea: parkingArea1)
            try source.add(parkingAreas: parkingAreas)
            
            let toilet1 = GDToilet(id: 1)
            let toilet2 = GDToilet(id: 2)
            let toilet3 = GDToilet(id: 3)
            let toilets = [toilet2, toilet3]
            
            try source.add(toilet: toilet1)
            try source.add(toilets: toilets)
            
            let time1 = GDTime(id: 1)
            let time2 = GDTime(id: 2)
            let time3 = GDTime(id: 3)
            let times = [time2, time3]
            
            try source.add(time: time1)
            try source.add(times: times)
            
            assert(source.shows.count == 0)
            assert(source.stages.count == 0)
            assert(source.parkingAreas.count == 0)
            assert(source.toilets.count == 0)
            assert(source.times.count == 0)
            
            try source.commit()
            
            assert(source.shows.count == 3)
            assert(source.stages.count == 3)
            assert(source.parkingAreas.count == 3)
            assert(source.toilets.count == 3)
            assert(source.times.count == 3)
            
        } catch {
            assert(false)
        }
    }
    
    func testDiscard() {
        do {
            let source = AbstractDatasource()
            let show = GDShow(id: 1)
            
            try source.startTransaction()
            try source.add(show: show)
            source.discard()
            
            assert(source.shows.count == 0)
            
            try source.commit()
            assert(false)
        } catch {
            
        }
        
        // does it work correct after discard?
        do {
            let source = AbstractDatasource()
            let show = GDShow(id: 1)
            
            try source.startTransaction()
            try source.add(show: show)
            
            assert(source.shows.count == 0)
            try source.commit()
            assert(source.shows.count == 1)
        } catch {
            assert(false)
        }
    }
    
    func testDuplicateTransaction() {
        let source = AbstractDatasource()
        try! source.startTransaction()
        
        do {
            try source.startTransaction()
            assert(false)
        } catch {
            
        }
    }
    
    func testRemovedOldModels() {
        let source = GDJsonDatasource()
        try! source.startTransaction()
        try! source.refresh(fromJson: json!)
        try! source.commit()
        
        let places = source.places
        let shows = source.shows
        let times = source.times
        
        try! source.startTransaction()
        try! source.refresh(fromJson: json!)
        try! source.commit()
        
        // check if old instances where removed
        places.forEach { (place) in
            if source.places.contains(where: { (new) -> Bool in
                return place === new
            }) {
                assert(false)
            }
        }
        
        times.forEach { (time) in
            if source.times.contains(where: { (new) -> Bool in
                return time === new
            }) {
                assert(false)
            }
        }
        
        shows.forEach { (show) in
            if source.shows.contains(where: { (new) -> Bool in
                return show === new
            }) {
                assert(false)
            }
        }
    }
    
    // MARK: Test Json Datasource
    
    func testConsistendModel() {
        let source = GDJsonDatasource()
        try! source.startTransaction()
        try! source.refresh(fromJson: json!)
        try! source.commit()
        
        let times = source.times
        assert(times.count > 0)
        times.forEach {
            assert($0.date != nil)
            assert($0.id > 0)
            assert($0.shows.count > 0)
        }
        
        let shows = source.shows
        assert(shows.count > 0)
        shows.forEach {
            assert($0.name != nil)
            assert($0.time != nil)
            assert($0.id > 0)
        }
        
        let places = source.places
        assert(places.count > 0)
        places.forEach {
            assert($0.id > 0)
            assert($0.lat! > 0)
            assert($0.lon! > 0)
            assert($0.name != nil)
            assert($0.index != nil)
        }
        
        // sorting
        var old = places[0]
        for i in 1...(places.count - 1) {
            let curr = places[i]
            assert(curr.index! > old.index!)
            old = curr
        }
        
        let days = source.days
        assert(days.count > 0)
        days.forEach { (day) in
            assert(day.times.count > 0)
            assert(day.shows.count > 0)
            assert(day.begin == day.times[0].date)
            assert(day.end == day.times[day.times.count - 1].date)
        }
    }
    
    // MARK: Test consistency
    
    func testMissingTime() {
        let json = createJson(fromName: "middleagercityparty_missing_time")
        
        do {
            let source = GDJsonDatasource()
            try source.startTransaction()
            try source.refresh(fromJson: json)
            try source.commit()
            assert(false)
        } catch AbstractDatasource.DatasourceError.inconsistentData(let expected) {
            assert(expected.contains("id 3"))
        } catch {
            assert(false)
        }
    }
    
    func testMissingPlace() {
        let json = createJson(fromName: "middleagercityparty_missing_place")
        
        do {
            let source = GDJsonDatasource()
            try source.startTransaction()
            try source.refresh(fromJson: json)
            try source.commit()
            assert(false)
        } catch AbstractDatasource.DatasourceError.inconsistentData(let expected) {
            assert(expected.contains("id 2"))
        } catch {
            assert(false)
        }
    }
    
    // MARK: Test observers
    
    func testObservers() {
        let source = GDJsonDatasource()
        
        var notifiedPlaces = false
        var notifiedShows = false
        var notifiedTimes = false
        
        let placesObserver = GDSourceObserver<GDPlace>()
        placesObserver.updated = { (updated: [GDPlace]) in
            assert(!notifiedPlaces) //not called multiple times
            notifiedPlaces = true
            assert(updated.count == source.places.count)
            updated.forEach({ (place) in
                let contains = source.places.contains(where: { (inside) -> Bool in
                    return place === inside
                })
                assert(contains)
            })
        }
        
        let showsObserver = GDSourceObserver<GDShow>()
        showsObserver.updated = { (updated: [GDShow]) in
            assert(!notifiedShows) //not called multiple times
            notifiedShows = true
            assert(updated.count == source.shows.count)
            updated.forEach({ (show) in
                let contains = source.shows.contains(where: { (inside) -> Bool in
                    return show === inside
                })
                assert(contains)
            })
        }
        
        let timesObserver = GDSourceObserver<GDTime>()
        timesObserver.updated = { (updated: [GDTime]) in
            assert(!notifiedTimes) //not called multiple times
            notifiedTimes = true
            assert(updated.count == source.times.count)
            updated.forEach({ (time) in
                let contains = source.times.contains(where: { (inside) -> Bool in
                    return time === inside
                })
                assert(contains)
            })
        }
        
        source.add(showObserver: showsObserver)
        source.add(placeObserver: placesObserver)
        source.add(timeObserver: timesObserver)
        
        try! source.startTransaction()
        try! source.add(show: GDShow(id: 1))
        try! source.commit()
        
        assert(notifiedShows)
        notifiedShows = false
        
        try! source.startTransaction()
        try! source.add(shows: [GDShow(id: 2), GDShow(id: 3)])
        try! source.commit()
        
        assert(notifiedShows)
        notifiedShows = false
        
        
        try! source.startTransaction()
        try! source.add(time: GDTime(id: 1))
        try! source.commit()
        
        assert(notifiedTimes)
        notifiedTimes = false
        
        try! source.startTransaction()
        try! source.add(times: [GDTime(id: 2), GDTime(id: 3)])
        try! source.commit()
        
        assert(notifiedTimes)
        notifiedTimes = false
        
        
        try! source.startTransaction()
        try! source.add(stage: GDStage(id: 1))
        try! source.commit()
        
        assert(notifiedPlaces)
        notifiedPlaces = false
        
        try! source.startTransaction()
        try! source.add(stages: [GDStage(id: 2), GDStage(id: 3)])
        try! source.commit()
        
        assert(notifiedPlaces)
        notifiedPlaces = false
        
        
        try! source.startTransaction()
        try! source.add(parkingArea: GDParkingArea(id: 4))
        try! source.commit()
        
        assert(notifiedPlaces)
        notifiedPlaces = false
        
        try! source.startTransaction()
        try! source.add(parkingAreas: [GDParkingArea(id: 5), GDParkingArea(id: 6)])
        try! source.commit()
        
        assert(notifiedPlaces)
        notifiedPlaces = false
        
        
        try! source.startTransaction()
        try! source.add(toilet: GDToilet(id: 7))
        try! source.commit()
        
        assert(notifiedPlaces)
        notifiedPlaces = false
        
        try! source.startTransaction()
        try! source.add(toilets: [GDToilet(id: 8), GDToilet(id: 9)])
        try! source.commit()
        
        assert(notifiedPlaces)
        notifiedPlaces = false
        
        
        try! source.startTransaction()
        try! source.add(show: GDShow(id: 4))
        try! source.add(stage: GDStage(id: 10))
        try! source.add(time: GDTime(id: 4))
        try! source.commit()
        
        assert(notifiedShows)
        assert(notifiedPlaces)
        assert(notifiedTimes)
        
        notifiedTimes = false
        notifiedPlaces = false
        notifiedShows = false
        
        source.remove(showObserver: showsObserver)
        source.remove(placeObserver: placesObserver)
        source.remove(timeObserver: timesObserver)
        
        try! source.startTransaction()
        try! source.add(show: GDShow(id: 5))
        try! source.add(stage: GDStage(id: 11))
        try! source.add(time: GDTime(id: 5))
        try! source.commit()
        
        assert(!notifiedShows)
        assert(!notifiedTimes)
        assert(!notifiedPlaces)
    }
    
    // MARK: Test update model
    func testUpdateModel() {
        let source = GDJsonDatasource()
        try! source.startTransaction()
        try! source.refresh(fromJson: json!)
        try! source.commit()
        
        let updater = GDModelUpdater(source: source, currentDatabase: json!)
        updater.updateServer = "https://geekdevelopment.de/test_middleagercityparty.json"
        
        
        var busyWait = true
        updater.onUpdated = { (newDatabase: JSONObject) in
            busyWait = false
            assert(true)
        }
        
        updater.onUpdateIgnored = {
            busyWait = false
            assert(false)
        }
        
        updater.onUpdateFailed = {
            busyWait = false
            assert(false)
        }
        
        updater.update()
        
        while busyWait {
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    func testUpdateInconsistentData() {
        let source = GDJsonDatasource()
        try! source.startTransaction()
        try! source.refresh(fromJson: json!)
        try! source.commit()
        
        let updater = GDModelUpdater(source: source, currentDatabase: json!)
        updater.updateServer = "https://geekdevelopment.de/invalid_data_middleagercityparty.json"
        
        
        var busyWait = true
        
        updater.onUpdated = { (newDatabase: JSONObject) in
            busyWait = false
            assert(false)
        }
        
        updater.onUpdateIgnored = {
            busyWait = false
            assert(false)
        }
        
        updater.onUpdateFailed = {
            busyWait = false
            assert(true)
        }
        
        updater.update()
        
        while busyWait {
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    func testUpdateInvalidJson() {
        let source = GDJsonDatasource()
        try! source.startTransaction()
        try! source.refresh(fromJson: json!)
        try! source.commit()
        
        let updater = GDModelUpdater(source: source, currentDatabase: json!)
        updater.updateServer = "https://geekdevelopment.de/invalid_json_middleagercityparty.json"
        
        
        var busyWait = true
        
        updater.onUpdated = { (newDatabase: JSONObject) in
            busyWait = false
            assert(false)
        }
        
        updater.onUpdateIgnored = {
            busyWait = false
            assert(false)
        }
        
        updater.onUpdateFailed = {
            busyWait = false
            assert(true)
        }
        
        updater.update()
        
        while busyWait {
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    func testUpdateOldModel() {
        let source = GDJsonDatasource()
        try! source.startTransaction()
        try! source.refresh(fromJson: json!)
        try! source.commit()
        
        let updater = GDModelUpdater(source: source, currentDatabase: json!)
        updater.updateServer = "https://geekdevelopment.de/old_middleagercityparty.json"
        
        
        var busyWait = true
        
        updater.onUpdated = { (newDatabase: JSONObject) in
            busyWait = false
            assert(false)
        }
        
        updater.onUpdateIgnored = {
            busyWait = false
            assert(true)
        }
        
        updater.onUpdateFailed = {
            busyWait = false
            assert(false)
        }
        
        updater.update()
        
        while busyWait {
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    func testUpdateWithObservers() {
        let source = GDJsonDatasource()
        try! source.startTransaction()
        try! source.refresh(fromJson: json!)
        try! source.commit()
        
        var notifiedPlaces = false
        var notifiedShows = false
        var notifiedTimes = false
        var notifiedDays = false
        
        let placesObserver = GDSourceObserver<GDPlace>()
        placesObserver.updated = { (updated: [GDPlace]) in
            assert(!notifiedPlaces) //not called multiple times
            notifiedPlaces = true
            assert(updated.count == source.places.count)
            updated.forEach({ (place) in
                let contains = source.places.contains(where: { (inside) -> Bool in
                    return place === inside
                })
                assert(contains)
            })
        }
        
        let showsObserver = GDSourceObserver<GDShow>()
        showsObserver.updated = { (updated: [GDShow]) in
            assert(!notifiedShows) //not called multiple times
            notifiedShows = true
            assert(updated.count == source.shows.count)
            updated.forEach({ (show) in
                let contains = source.shows.contains(where: { (inside) -> Bool in
                    return show === inside
                })
                assert(contains)
            })
        }
        
        let timesObserver = GDSourceObserver<GDTime>()
        timesObserver.updated = { (updated: [GDTime]) in
            assert(!notifiedTimes) //not called multiple times
            notifiedTimes = true
            assert(updated.count == source.times.count)
            updated.forEach({ (time) in
                let contains = source.times.contains(where: { (inside) -> Bool in
                    return time === inside
                })
                assert(contains)
            })
        }
        
        let daysObserver = GDSourceObserver<GDDay>()
        daysObserver.updated = { (updated: [GDDay]) in
            assert(!notifiedDays)
            notifiedDays = true
            assert(updated.count == source.days.count)
            updated.forEach({ (day) in
                let contains = source.days.contains(where: { (inside) -> Bool in
                    return day === inside
                })
                assert(contains)
            })
        }
        
        source.add(showObserver: showsObserver)
        source.add(placeObserver: placesObserver)
        source.add(timeObserver: timesObserver)
        source.add(dayObserver: daysObserver)
        
        let updater = GDModelUpdater(source: source, currentDatabase: json!)
        updater.updateServer = "https://geekdevelopment.de/test_middleagercityparty.json"
        
        
        var busyWait = true
        
        updater.onUpdated = { (newDatabase: JSONObject) in
            busyWait = false
            assert(true)
        }
        
        updater.onUpdateIgnored = {
            busyWait = false
            assert(false)
        }
        
        updater.onUpdateFailed = {
            busyWait = false
            assert(false)
        }
        
        updater.update()
        
        while busyWait {
            Thread.sleep(forTimeInterval: 0.2)
        }
        
        assert(notifiedShows)
        assert(notifiedTimes)
        assert(notifiedPlaces)
    }
    
    // MARK: Database
    
    func testDatabase() {
        var database = GDMidleagerDatabase()
        let bundle = Bundle(for: type(of: self))
        database.bundle = bundle
        var json = database.database()
        
        let lastUpdated = json["lastUpdated"] as! Int
        
        json["lastUpdated"] = (lastUpdated + 1) as AnyObject
        database.insert(database: json)
        
        database = GDMidleagerDatabase()
        database.bundle = bundle
        json = database.database()
        
        assert((json["lastUpdated"] as! Int) == (lastUpdated + 1))
    }
    
    // MARK: Day calculation
    
    func testNewDayBetweenDates() {
        //test same day
        let date1 = Date()
        let date2 = Date()
        assert(!TimeUtil.isNewDay(first: date1, second: date2))  
        
        //test different day
        let diff1 = Date()
        var diff2 = Date()
        diff2.addTimeInterval(86400) //seconds of one day
        assert(TimeUtil.isNewDay(first: diff1, second: diff2))
    }
    
    func testDayetizing() {
        let source = GDJsonDatasource()
        try! source.startTransaction()
        try! source.refresh(fromJson: json!)
        try! source.commit()
        
        source.times.forEach { (time) in
            assert(time.day != nil)
        }
        
        assert(source.days.count == 2)
    }
    
    func testItsFestivalTime() {
        let time1 = GDTime(id: 0)
        let time2 = GDTime(id: 1)
        
        time1.date = Date(timeIntervalSince1970: 0)
        time2.date = Date(timeIntervalSince1970: 172800)
        
        assert(!TimeUtil.itsFestivalTime([time1, time2]))
        
        time1.date = Date(timeIntervalSinceNow: -172800)
        time2.date = Date()
        
        let time3 = GDTime(id: 3)
        time3.date = Date(timeIntervalSinceNow: 172800)
        
        assert(TimeUtil.itsFestivalTime([time1, time2, time3]))
    }
}
