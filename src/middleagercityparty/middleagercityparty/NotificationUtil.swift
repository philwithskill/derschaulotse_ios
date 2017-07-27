//
//  NotificationUtil.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 28/01/2017.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation

class NotificationUtil : NSObject {
    
    static var nameApplicationDidBecomeActive = Notification.Name("applicationDidBecomeActive")
    
    static var nameApplicationWillEnterForeground = Notification.Name("applicationWillEnterForeground")
    
    static var nameUserConfiguredNotificationSettings = Notification.Name("userConfiguredNotificationSettings")
    
    private static var keyAskedForUserNotifications = "AskedForUserNotifications"
    
    static func alreadyAskedForUserNotifications() -> Bool {
        return UserDefaults.standard.bool(forKey: NotificationUtil.keyAskedForUserNotifications)
    }
    
    static func saveAskedForUserNotifications() {
        UserDefaults.standard.set(true, forKey: NotificationUtil.keyAskedForUserNotifications)
    }
}
