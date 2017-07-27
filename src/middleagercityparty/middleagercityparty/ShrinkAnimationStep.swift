//
//  ShrinkAnimationStep.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 02/01/2017.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation
import UIKit

class ShrinkAnimationStep : IconAnimationStep {
    override func animate() {
        reminderStateIcon.hideCheckmarkCornerLayer()
        reminderStateIcon.animShrink(animationDelegate: self)
    }
    
    override func animationDidStart(_ anim: CAAnimation) {
        nextState?.animate()
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }
}
