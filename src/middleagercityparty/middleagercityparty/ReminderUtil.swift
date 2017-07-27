//
//  ReminderUtil.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 13/03/2017.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class ReminderUtil : NSObject {

    struct Keys {
        static let reminders = "KEY_REMINDERS"
    }
    
    typealias DidSetReminder = (() -> ())?
    
    typealias DidFailedSettingReminder = (() -> ())?
    
    private var didSetReminder : DidSetReminder
    
    private var didFailedSettingReminder : DidFailedSettingReminder
    
    private var show : GDShow?
    
    // MARK: Initialization
    
    override init() {
        super.init()
        registerObserver()
    }
    
    deinit {
        deregisterObserver()
    }
    
    func remindFor(show: GDShow, didSetReminder: DidSetReminder, didFailedSettingReminder: DidFailedSettingReminder, presentingVC: UIViewController) {
        self.didSetReminder = didSetReminder
        self.didFailedSettingReminder = didFailedSettingReminder
        self.show = show
        
        if !isAbleToSetReminders() {
            showAlert(presentingVC)
        } else {
            saveReminder(show)
            didSetReminder?()
            
            self.didFailedSettingReminder = nil
            self.didSetReminder = nil
            self.show = nil
        }
    }
    
    private func saveReminder(_ show: GDShow) {
        let notification = UILocalNotification()
        if let date = show.time?.date {
            
            if #available(iOS 8.2, *) {
                notification.alertTitle = NSLocalizedString("ReminderNotificationTitle", comment: "")
            }
            
            let offset = -4.0 * 60.0 //four minutes
            let fireDate = Date(timeInterval: offset, since: date)
            notification.fireDate = fireDate
            notification.alertBody = ShowUtil.notificationMessageFor(show: show)
            notification.soundName = UILocalNotificationDefaultSoundName
            
            notification.userInfo =  [AnyHashable : Any]()
            notification.userInfo!["idShow"] = show.id
            UIApplication.shared.scheduleLocalNotification(notification)
            
            saveToUserDefaults(show)
            
        } else {
            assert(false)
        }
    }
    
    func removeReminderFor(show: GDShow) {
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            for notification in notifications {
                if let userInfo = notification.userInfo {
                    if (userInfo["idShow"] as? Int) == show.id {
                        UIApplication.shared.cancelLocalNotification(notification)
                        break
                    }
                }
            }
        } else {
            assert(false)
        }
        
        removeFromUserDefaults(show)
    }
    
    private func saveToUserDefaults(_ show: GDShow) {
        var reminders = remindersFromDefaults()
        
        if !reminders.contains(show.id) {
            reminders.append(show.id)
            UserDefaults.standard.set(reminders, forKey: Keys.reminders)
            UserDefaults.standard.synchronize()
        }
        
        
    }
    
    private func removeFromUserDefaults(_ show: GDShow) {
        var reminders = remindersFromDefaults()
        
        if let index = reminders.index(where:  { (i) -> Bool in
            return i == show.id
        }) {
            reminders.remove(at: index)
            UserDefaults.standard.set(reminders, forKey: Keys.reminders)
            UserDefaults.standard.synchronize()
        }
    }
    
    private func remindersFromDefaults() -> [Int] {
        var reminders = [Int]()
        if let temp = UserDefaults.standard.array(forKey: Keys.reminders) as? [Int] {
            reminders = temp
        }
        
        return reminders
    }
    
    func isAbleToSetReminders() -> Bool {
        if let settings = UIApplication.shared.currentUserNotificationSettings {
            return settings.types != []
        }
        
        return false
    }
    
    func hasReminderFor(show: GDShow) -> Bool{
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            for notification in notifications {
                if let userInfo = notification.userInfo {
                    if (userInfo["idShow"] as? Int) == show.id {
                        return true
                    }
                }
            }
        }
            
        if remindersFromDefaults().contains(show.id) {
            return true
        }
        
        return false
    }
    
    
    
    // MARK: Alert View
    
    private func showAlert(_ presentingVC : UIViewController) {
        if (!NotificationUtil.alreadyAskedForUserNotifications()) {
            showFirstAlert(presentingVC)
        } else {
            showOrdinaryAlert(presentingVC)
        }
    }
    
    func showFirstAlert(_ presentingVC: UIViewController) {
        NotificationUtil.saveAskedForUserNotifications()
        
        let message = NSLocalizedString("ReminderAlertFirstMessage", comment: "")
        let alert = createAlertController(message: message)
        presentingVC.present(alert, animated: true, completion: nil)
    }
    
    func showOrdinaryAlert(_ presentingVC: UIViewController) {
        let message = NSLocalizedString("ReminderAlertMessage", comment: "")
        let alert = createAlertController(message: message)
        presentingVC.present(alert, animated: true, completion: nil)
    }
    
    private func createAlertController(message: String) -> UIAlertController {
        let title = NSLocalizedString("ReminderAlertTitle", comment: "")
        let button = NSLocalizedString("ReminderAlertButtonOK", comment: "")
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let registerAction = UIAlertAction(title: button, style: UIAlertActionStyle.cancel) { action in
            let newSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(newSettings)
        }
        
        controller.addAction(registerAction)
        return controller
    }


    
    // MARK: Observing
    
    private func registerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didConfigured), name: NotificationUtil.nameUserConfiguredNotificationSettings, object: nil)
    }
    
    private func deregisterObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func didConfigured() {
        let settings = UIApplication.shared.currentUserNotificationSettings
        if settings?.types == [] {
            didFailedSettingReminder?()
        } else {
            if(show != nil) {
                saveReminder(self.show!)
            } else {
                assert(false)
            }
            didSetReminder?()
        }
        
        didFailedSettingReminder = nil
        didSetReminder = nil
        show = nil
    }
}
