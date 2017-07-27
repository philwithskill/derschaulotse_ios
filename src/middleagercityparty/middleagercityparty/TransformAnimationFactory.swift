//
//  TransformAnimationFactory.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 07/01/2017.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation

class TransformAnimationFactory {
    
    func createTransformCheckmarkAnimation(reminderStateIcon: GDReminderStateIcon) -> IconAnimationStep {
        
        let grow = GrowAnimationStep(reminderStateIcon: reminderStateIcon)
        if (!reminderStateIcon.initializedWithCheckmark) {
            let sync = SyncAnimationStep(reminderStateIcon: reminderStateIcon)
            let align = AlignAnimationStep(reminderStateIcon: reminderStateIcon)
            
            sync.nextState = align
            align.nextState = grow
            
            return sync
        } else {
            let sync = SyncRotatedAnimationStep(reminderStateIcon: reminderStateIcon)
            let align = AlignRotatedAnimationStep(reminderStateIcon: reminderStateIcon)
            
            sync.nextState = align
            align.nextState = grow
            
            return sync
        }
        
    }
    
    func createTransformPlusAnimation(reminderStateIcon: GDReminderStateIcon) -> IconAnimationStep {
        let shrink = ShrinkAnimationStep(reminderStateIcon: reminderStateIcon)
        if (!reminderStateIcon.initializedWithCheckmark) {
            let reAlign = ReAlignAnimationStep(reminderStateIcon: reminderStateIcon)
            shrink.nextState = reAlign
            
            return shrink
        } else {
            let reAlign = ReAlignRotatedAnimationStep(reminderStateIcon: reminderStateIcon)
            shrink.nextState = reAlign
            
            return shrink
        }
    }
}
