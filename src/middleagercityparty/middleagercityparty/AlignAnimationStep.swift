//
//  AlignAnimationState.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 31/12/2016.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation
import UIKit

class AlignAnimationStep : IconAnimationStep {
    
    override func animate() {
        reminderStateIcon.animAlign(animationDelegate: self)
    }
    
    override func animationDidStart(_ anim: CAAnimation) {
        nextState?.animate()
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
     
    }
    
}


