//
//  ReAlignRotatedAnimationStep.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 26.05.17.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation
import UIKit

class ReAlignRotatedAnimationStep : IconAnimationStep {
    
    override func animate() {
        reminderStateIcon.animReAlignFromRotatedLines(animationDelegate: self)
    }
    
    override func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        reminderStateIcon.isTransforming = false
    }
}
