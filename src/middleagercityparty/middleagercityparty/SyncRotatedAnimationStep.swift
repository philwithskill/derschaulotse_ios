//
//  SyncRotatedAnimationStep.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 26.05.17.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation
import UIKit

class SyncRotatedAnimationStep : IconAnimationStep {
    
    override func animate() {
        reminderStateIcon.isTransforming = true
        reminderStateIcon.animSyncFromRotatedLines(animationDelegate: self)
    }
    
    override func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        nextState?.animate()
    }
}
