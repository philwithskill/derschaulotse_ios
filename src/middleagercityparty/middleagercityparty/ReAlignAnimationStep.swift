//
//  ReAlignAnimationStep.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 02/01/2017.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation
import UIKit

class ReAlignAnimationStep : IconAnimationStep {
    
    override func animate() {
        reminderStateIcon.animReAlign(animationDelegate: self)
    }
    
    override func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        reminderStateIcon.isTransforming = false
    }
}
