//
//  GDShowsViewController.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 31/10/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import UIKit
import UserNotifications

class GDShowsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, NavigationBarButtonDelegateProtocol {

    private let tableHeaderIdentifier = "cellTime"
    
    @IBOutlet weak var tableview: UITableView!
    
    private lazy var reminderUtil = ReminderUtil()
    
    var requestedReminder = false
    
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
    
    private var times = [GDTime]()
    
    var dayDatasource : GDViewControllerDatasource<GDDay>?
    
    private var scrolledOnAppStart = false
    
    private var currentTime : GDTime? {
        return TimeUtil.containsCurrentTime(times)
    }
    
    // MARK: Initializing methods of view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToCurrentTimeOnAppstart()
    }
    
    deinit {
        unregisterObserver()
    }
    
    func didBecomeActive() {
        scrollToCurrentTime(animated: true)
    }
    
    // MARK: UITableViewDatasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return times.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let shows = times[section].shows
        return shows.count
    }
    
    var iconReminder = UIImage(contentsOfFile: "icon_reminder")
    
    var iconReminderEnabled = UIImage(contentsOfFile: "icon_reminder_enabled")
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let time = times[indexPath.section]
        let show = time.shows[indexPath.row]
    
        var result : UITableViewCell
        
        
        if show.stage != nil {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "cellShow", for: indexPath) as! GDShowTableViewCell
            cell.show = show
            cell.reminderButtonTapped = { (wantsToEnable : Bool) in
                if wantsToEnable {
                    let didSet = ReminderUtil.DidSetReminder {
                        //ggf. ubdate reminder button
                        NSLog("didSet Reminder")
                        self.requestedReminder = false
                        
                    }
                    
                    let didFailed = ReminderUtil.DidFailedSettingReminder {
                        //ggd. update reminder button
                        NSLog("didFailed Reminder")
                        self.requestedReminder = false
                        cell.deselectReminderButton()
                        
                    }
                    
                    self.requestedReminder = true
                    self.reminderUtil.remindFor(show: show, didSetReminder: didSet, didFailedSettingReminder: didFailed, presentingVC: self)
                    
                } else {
                    self.reminderUtil.removeReminderFor(show: show)
                    cell.deselectReminderButton()
                }
            }
            
            if reminderUtil.hasReminderFor(show: show) && self.reminderUtil.isAbleToSetReminders() {
                cell.reuseWithReminder()
            } else {
                cell.reuseWithoutReminder()
            }
            
            result = cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFirstShow", for: indexPath) as! GDFirstShowTableViewCell
            cell.show = show
            result = cell
        }
        
        result.selectionStyle = UITableViewCellSelectionStyle.none
        return result
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableview.dequeueReusableCell(withIdentifier: tableHeaderIdentifier) as! GDTimeSectionHeader
        let time = times[section]
        let formatted = format(time: time, inSection: section)
        header.labelTime.text = formatted
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(56.6)
    }
    
    private func format(time: GDTime, inSection: Int) -> String {
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
    
    //MARK: NavigationBarButtonDelegateProtocol
    
    func didTapNavigationBarButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.view.tintColor = GDColors.green
        
        
        
        //Check if its festival time and possible give opportunity to scroll to current show
        if let currentTime = currentTime {
            let rightNow = UIAlertAction(title: "Zurzeit", style: UIAlertActionStyle.default) { (action) in
                self.scrollTo(time: currentTime, animated: true)
            }
            alert.addAction(rightNow)
        }
        
        //Give opportunity to scroll to beginning of every day
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de")
        formatter.dateFormat = "EEEE"
       
        let days = dayDatasource!.elements as [GDDay]
        days.forEach { (day) in
            if let begin = day.begin {
                let title = formatter.string(from: begin)
                let action = UIAlertAction(title: title, style: UIAlertActionStyle.default) { (action) in
                    if day.times.count > 0 {
                        let time = day.times[0]
                        self.scrollTo(time: time, animated: true)
                    }
                }
                alert.addAction(action)
            }
        }
        
        let cancel = UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cancel)
        present(alert, animated:true, completion: nil)
    }
    
    // MARK: Scrolling to times
    
    private func scrollTo(time: GDTime, animated: Bool) {
        if let section = ModelUtil.indexOfModelElement(withId: time.id, inCollection: times) {
            let indexPath = IndexPath(row: 0, section: section)
            
            if !requestedReminder {
                self.tableview.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: animated)
            } else {
                NSLog("Ignored")
            }
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
    
    // MARK: Observing
    
    private func registerObserver() {
        observeDidBecomeActive()
    }
    
    private func observeDidBecomeActive() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NotificationUtil.nameApplicationDidBecomeActive, object: nil)
    }
    
    private func observeDatasource() {
        let observer = GDSourceObserver<GDTime>()
        observer.updated = { (elements: [GDTime]) in
            OperationQueue.main.addOperation {
                self.times = elements
                self.tableview.reloadData()
            }
        }
        datasource?.observer = observer
    }
    
    private func unregisterObserver() {
        dontObserveDidBecomeActive()
        dontObserveDatasource()
    }
    
    private func dontObserveDidBecomeActive() {
        NotificationCenter.default.removeObserver(observer: self)
    }
    
    private func dontObserveDatasource() {
        datasource?.observer.updated = nil
    }
}
