//
//  ShowUtil.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 13/03/2017.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation

class ShowUtil {
    
    static func notificationMessageFor(show: GDShow) -> String {
        
        var message : String
        if let stage = show.stage {
            message = show.name! + " "
            message = message + NSLocalizedString("ReminderNotificationMessageFormat", comment: "")
            message = message + " "
            message = message + stage.name!
            message = message + "."
        } else {
            message = show.name! + " "
            message = message + NSLocalizedString("ReminderNotificationMessageNoStageFormat", comment: "")
            message = message + "."
        }
        
        return message
    }
}
