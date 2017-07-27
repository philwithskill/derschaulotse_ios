//
//  GrowAnimationState.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 31/12/2016.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation
import UIKit

class GrowAnimationStep : IconAnimationStep {
    
    override func animate() {
        reminderStateIcon.animGrow(animationDelegate: self)
    }
    
    override func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        reminderStateIcon.isTransforming = false
    }
}
