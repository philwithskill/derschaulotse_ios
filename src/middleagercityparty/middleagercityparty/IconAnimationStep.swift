//
//  IconAnimationState.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 31/12/2016.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation
import UIKit

class IconAnimationStep : NSObject, CAAnimationDelegate  {
    
    var reminderStateIcon : GDReminderStateIcon
    
    var nextState : IconAnimationStep?
    
    init(reminderStateIcon: GDReminderStateIcon) {
        self.reminderStateIcon = reminderStateIcon
    }
    
    func animate() {
        //OVERRIDE IN SUBCLASSES
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        //OVERRIDE IN SUBLCASSES
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //OVERRIDE IN SUBCLASSES
    }
}
