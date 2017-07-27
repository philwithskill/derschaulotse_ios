//
//  AbstractDatasource.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 23/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class AbstractDatasource {
    
    enum DatasourceError: Error {
        case noTransaction
        case transactionInProgress
        case inconsistentData(expected: String)
    }
    
    private(set) var shows : [GDShow]
    
    private(set) var places : [GDPlace]
    
    private(set) var stages : [GDStage]
    
    private(set) var parkingAreas : [GDParkingArea]
    
    private(set) var toilets : [GDToilet]
    
    private(set) var times : [GDTime]
    
    private(set) var days : [GDDay]
    
    private(set) var showObservers : [GDSourceObserver<GDShow>]
    
    private(set) var placeObservers : [GDSourceObserver<GDPlace>]
    
    private(set) var timeObservers : [GDSourceObserver<GDTime>]
    
    private(set) var dayObservers : [GDSourceObserver<GDDay>]
    
    private var toBeNotified : [AnyObject]
    
    private var transaction : GDTransaction?
    
    init() {
        shows = [GDShow]()
        places = [GDPlace]()
        stages = [GDStage]()
        parkingAreas = [GDParkingArea]()
        toilets = [GDToilet]()
        times = [GDTime]()
        days = [GDDay]()
        showObservers = [GDSourceObserver<GDShow>]()
        placeObservers = [GDSourceObserver<GDPlace>]()
        timeObservers = [GDSourceObserver<GDTime>]()
        dayObservers = [GDSourceObserver<GDDay>]()
        toBeNotified = [AnyObject]()
    }
    
    // MARK: Transactions
    
    func startTransaction() throws {
        if transaction != nil {
            throw DatasourceError.transactionInProgress
        }
        transaction = GDTransaction()
    }
    
    func commit() throws {
        try checkTransactionStarted()
        
        self.clear()
        transaction?.commit()
        transaction = nil
        
        notifyObservers()
    }
    
    func discard() {
        transaction?.discard()
        
        transaction = nil
    }
    
    func checkTransactionStarted() throws {
        if transaction == nil {
            throw DatasourceError.noTransaction
        }
    }
    
    func notifyObservers() {
        toBeNotified.forEach { (el) in
            if el is GDSourceObserver<GDShow> {
                let obs = el as! GDSourceObserver<GDShow>
                obs.updated?(self.shows)
            } else if el is GDSourceObserver<GDPlace> {
                let obs = el as! GDSourceObserver<GDPlace>
                obs.updated?(self.places)
            } else if el is GDSourceObserver<GDTime> {
                let obs = el as! GDSourceObserver<GDTime>
                obs.updated?(self.times)
            }
        }
        
        toBeNotified.removeAll()
    }
    
    // MARK: Data Accessors
    
    func add(show: GDShow) throws {
        try checkTransactionStarted()
        
        let change = {() -> () in
            if !ModelUtil.contains(element: show, inCollection: self.shows) {
                self.shows.append(show)
                self.add(asToBeNotified: self.showObservers)
            }
        }
        
        self.transaction?.transact(change: change)
    }
    
    func add(shows: [GDShow]) throws {
        try checkTransactionStarted()
        
        try shows.forEach { (show) in
            try add(show: show)
        }
    }
    
    func show(forId: Int) -> GDShow? {
        return ModelUtil.element(forId: forId, inCollection: self.shows) as? GDShow
    }
    
    func add(parkingArea: GDParkingArea) throws{
        try checkTransactionStarted()
        
        let change = {() -> () in
            if !ModelUtil.contains(element: parkingArea, inCollection: self.parkingAreas) {
                self.parkingAreas.append(parkingArea)
                self.places.append(parkingArea)
                self.add(asToBeNotified: self.placeObservers)
            }
        }
        
        self.transaction?.transact(change: change)
    }
    
    func add(parkingAreas: [GDParkingArea]) throws {
        try checkTransactionStarted()
        
        try parkingAreas.forEach { (p) in
            try add(parkingArea: p)
        }
    }
    
    func add(stage: GDStage) throws {
        try checkTransactionStarted()
        
        let change = {() -> () in
            if !ModelUtil.contains(element: stage, inCollection: self.stages) {
                self.stages.append(stage)
                self.places.append(stage)
                self.add(asToBeNotified: self.placeObservers)
            }
        }
        
        self.transaction?.transact(change: change)
    }
    
    func add(stages: [GDStage]) throws {
        try checkTransactionStarted()
        
        try stages.forEach { (s) in
            try add(stage: s)
        }
    }
    
    func add(toilet: GDToilet) throws {
        try checkTransactionStarted()
        
        let change = {() -> () in
            if !ModelUtil.contains(element: toilet, inCollection: self.toilets) {
                self.toilets.append(toilet)
                self.places.append(toilet)
                self.add(asToBeNotified: self.placeObservers)
            }
        }
        
        self.transaction?.transact(change: change)
    }
    
    func add(toilets: [GDToilet]) throws {
        try checkTransactionStarted()
        
        try toilets.forEach { (t) in
            try add(toilet: t)
        }
    }
     
    func place(forId: Int) -> GDPlace? {
        return ModelUtil.element(forId: forId, inCollection: self.places) as? GDPlace
    }
    
    func add(time: GDTime) throws {
        try checkTransactionStarted()
        
        let change = {() -> () in
            if !ModelUtil.contains(element: time, inCollection: self.times) {
                self.times.append(time)
                self.add(asToBeNotified: self.timeObservers)
            }
        }
        
        self.transaction?.transact(change: change)
    }
    
    func add(times: [GDTime]) throws {
        try checkTransactionStarted()
        
        try times.forEach { (t) in
            try add(time: t)
        }
    }
    
    func time(forId: Int) -> GDTime? {
        return ModelUtil.element(forId: forId, inCollection: self.times) as? GDTime
    }
    
    func add(day: GDDay) throws {
        try checkTransactionStarted()
        
        let change = {
            if !ModelUtil.contains(element: day, inCollection: self.days) {
                self.days.append(day)
                self.add(asToBeNotified: self.dayObservers)
            }
        }
        
        self.transaction?.transact(change: change)
    }
    
    func add(days: [GDDay]) throws {
        try checkTransactionStarted()
        
        try days.forEach({ (d) in
            try add(day: d)
        })
    }
    
    func day(forId: Int) -> GDDay? {
        return ModelUtil.element(forId: forId, inCollection: self.days) as? GDDay
    }
    
    func clear() {        
        self.shows.removeAll()
        self.times.removeAll()
        self.stages.removeAll()
        self.toilets.removeAll()
        self.parkingAreas.removeAll()
        self.places.removeAll()
        self.days.removeAll()
    }
    
    // MARK: Observer accessors
    
    func add(showObserver: GDSourceObserver<GDShow>) {
        showObservers.append(showObserver)
    }
    
    func remove(showObserver: GDSourceObserver<GDShow>) {
        if let index = showObservers.index (where: { $0 === showObserver }) {
            showObservers.remove(at: index)
        }
    }
    
    func add(placeObserver: GDSourceObserver<GDPlace>) {
        placeObservers.append(placeObserver)
    }
    
    func remove(placeObserver: GDSourceObserver<GDPlace>) {
        if let index = placeObservers.index (where: { $0 === placeObserver }) {
            placeObservers.remove(at: index)
        }
    }
    
    func add(timeObserver: GDSourceObserver<GDTime>) {
        timeObservers.append(timeObserver)
    }
    
    func remove(timeObserver: GDSourceObserver<GDTime>) {
        if let index = timeObservers.index (where: { $0 === timeObserver }) {
            timeObservers.remove(at: index)
        }
    }
    
    func add(dayObserver: GDSourceObserver<GDDay>) {
        dayObservers.append(dayObserver)
    }
    
    func remove(dayObserver: GDSourceObserver<GDDay>) {
        if let index = dayObservers.index(where: { $0 === dayObserver}) {
            dayObservers.remove(at: index)
        }
    }
    
    private func remove(observer: GDSourceObserver<GDModelElement>, fromCollection: inout [GDSourceObserver<GDModelElement>]) {
        if let index = fromCollection.index (where: { $0 === observer}) {
            fromCollection.remove(at: index)
        }
    }
    
    private func add(asToBeNotified: [AnyObject]) {
        asToBeNotified.forEach { (element) in
            if !toBeNotified.contains(where: { (alreadyInside) -> Bool in
                return element === alreadyInside
            }) {
                toBeNotified.append(element)
            }
        }
    }
}
