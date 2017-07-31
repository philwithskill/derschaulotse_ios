//
//  InterfaceController.swift
//  middleagercityparty-watchos Extension
//
//  Created by Christian Trümper on 28.07.17.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController
{
    @IBOutlet var tableView: WKInterfaceTable!
    
    var datasource : GDViewControllerDatasource<GDTime>? {
        willSet {
            //remove
            dontObserveDatasource()
        }
        
        didSet {
            if let source = datasource {
                times = source.elements
            }
            
            observeDatasource()
        }
    }
    
    private var initData : AbstractDatasource!
    
    private var times = [GDTime]()
    
    private var rowTypes = [String]()
    private var rowData = [Any]()
    
    private var currentTime : GDTime? {
        return TimeUtil.containsCurrentTime(times)
    }
    
    private var scrolledOnAppStart = false
    
    private func initDatasource()
    {
        let datasource = GDJsonDatasource()
        try! datasource.startTransaction()
        try! datasource.refresh(fromJson: GDMidleagerDatabase().database())
        try! datasource.commit()
        self.initData = datasource
        
        let source = GDTimeDatasource()
        source.datasource = self.initData
        
        self.datasource = source
    }
    
    func setupTable()
    {
        for index in 0 ..< times.count
        {
            let time = times[index]
            
            self.rowTypes.append("HeaderCell")
            self.rowData.append(time)

            let shows = time.shows
        
            for index2 in 0 ..< shows.count
            {
                let show = shows[index2]
                self.rowTypes.append("ShowCell")
                self.rowData.append(show)
            }
        }
        
        self.tableView.setRowTypes(rowTypes)
        
        for index in 0 ..< self.rowTypes.count
        {
            switch self.rowTypes[index]
            {
                case "HeaderCell":
                    let row = self.tableView.rowController(at: index) as! GDWatchShowSectionTableView
                    
                    let time = self.rowData[index] as! GDTime
                    
                    let formatted = format(time: time, inSection: index)
                    
                     row.sectionHeaderLabel?.setText(formatted)
                    
                case "ShowCell":
                    let row = self.tableView.rowController(at: index) as! GDWatchShowTableViewCell
                    
                    let show = self.rowData[index] as! GDShow
                    
                    row.headerLabel?.setText(show.name)

                    if show.stage != nil
                    {
                        row.locationLabel?.setText(show.stage?.name)
                        
                    } else {
                        row.locationLabel?.setHidden(true)
                    }
                    
                default:
                    print("Not a value row type: " + self.rowTypes[index])
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.initDatasource()
        self.setupTable()
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.scrollToCurrentTime(animated: true)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: Scrolling to times
    
    private func scrollTo(time: GDTime, animated: Bool)
    {
        if let i = self.rowData.index(where: { ($0 as! GDTime).date == time.date }) {
            self.tableView.scrollToRow(at: i)
        }
    }
    
    
    private func scrollToCurrentTime(animated: Bool) {
        if let curr = currentTime {
            scrollTo(time: curr, animated: animated)
        }
    }
    
    private func scrollToCurrentTimeOnAppstart() {
        if !scrolledOnAppStart {
            scrolledOnAppStart = true
            scrollToCurrentTime(animated: true)
        }
    }
    
    private func format(time: GDTime, inSection: Int) -> String
    {
        let formatter = DateFormatter()
        let before = TimeUtil.findTimeBefore(time: time, collection: times)
        let newDay = TimeUtil.isNewDay(first: before.date!, second: time.date!)
        formatter.locale = Locale(identifier: "de")
        
        if newDay || inSection == 0 {
            formatter.dateFormat = "EEEE\nHH:mm"
        } else {
            formatter.dateFormat = "HH:mm"
        }
        
        return formatter.string(from: time.date!) + " Uhr"
    }
    
    private func observeDatasource() {
        let observer = GDSourceObserver<GDTime>()
        observer.updated = { (elements: [GDTime]) in
            OperationQueue.main.addOperation {
                self.times = elements
            }
        }
        
        datasource?.observer = observer
    }
    
    private func dontObserveDatasource() {
        datasource?.observer.updated = nil
    }

}
