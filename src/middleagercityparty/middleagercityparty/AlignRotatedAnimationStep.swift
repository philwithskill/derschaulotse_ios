//
//  AlignRotatedAnimationStep.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 26.05.17.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import Foundation
import UIKit

class AlignRotatedAnimationStep : IconAnimationStep {
    
    override func animate() {
        reminderStateIcon.animAlignFromRotatedLines(animationDelegate: self)
    }
    
    override func animationDidStart(_ anim: CAAnimation) {
        nextState?.animate()
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }
    
}
