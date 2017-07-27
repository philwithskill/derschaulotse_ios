//
//  GDNavigationItemCell.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 05/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import UIKit

class GDNavigationItemCell : UICollectionViewCell {
    
    enum Position {
        case left
        case right
        case top
    }
    
    private let durationAnimation = 0.150
    
    private let offsetFactor = CGFloat(0.1444444444444444)
    
    @IBOutlet weak var text: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    var position : Position = .right
    
    var navigationItem : GDNavigationItem? {
        didSet {
            text.text = navigationItem?.text
            
            icon.image = UIImage(named: navigationItem!.iconName!)
        }
    }
    
    // MARK: Position state
    
    func select(completion: ((Bool) -> ())?) {
        position = .top
        animateSelection(withDuration: durationAnimation, completion: completion)
    }
    
    func moveToLeft(completion: ((Bool) -> ())?) {
        position = .left
        animateMoveToLeft(withDuration: durationAnimation, completion: completion)
    }
    
    func moveToRight(completion: ((Bool) -> ())?) {
        position = .right
        animateMoveToRight(withDuration: durationAnimation, completion: completion)
    }
    
    func hideToLeft(completion: ((Bool) -> ())?) {
        position = .left
        animateHidingToLeft(withDuration: durationAnimation, completion: completion)
    }
    
    func hideToRight(completion: ((Bool) -> ())?) {
        position = .right
        animateHidingToRight(withDuration: durationAnimation, completion: completion)
    }
    
    // MARK: Change position animations
    
    private func animateSelection(withDuration: Double, completion: ((Bool) -> ())?) {
        let topPadding = CGFloat(7)
        let toY = frame.origin.y + topPadding
        let toX = (bounds.size.width / CGFloat(2)) - (icon.bounds.size.width / CGFloat(2))
        
        UIView.animate(withDuration: durationAnimation,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () in self.text.alpha = CGFloat(1.0) },
                       completion: nil)
        
        UIView.animate(withDuration: durationAnimation,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { self.icon.frame.origin.x = toX; self.icon.frame.origin.y = toY},
                       completion: completion)
    }
    
    private func animateMoveToRight(withDuration: Double, completion: ((Bool) -> ())?) {
        let width = bounds.size.width
        let offset = width * offsetFactor
        animateMove(withOffset: offset, duration: durationAnimation, completion: completion)
    }
    
    private func animateMoveToLeft(withDuration: Double, completion: ((Bool) -> ())?) {
        let width = bounds.size.width
        let offset = width * CGFloat(-1) * offsetFactor
        animateMove(withOffset: offset, duration: durationAnimation, completion: completion)
    }

    private func animateMove(withOffset: CGFloat, duration: Double, completion: ((Bool) -> ())?) {
        let toX = (bounds.size.width / CGFloat(2)) - (icon.bounds.width / 2) + withOffset
        
        UIView.animate(withDuration: duration,
                       animations: { () in self.icon.frame.origin.x = toX },
                       completion: completion)
    }
    
    private func animateHidingToLeft(withDuration: Double, completion: ((Bool) -> ())?) {
        let width = bounds.size.width
        let offset = width * CGFloat(-1) * offsetFactor
        animateHide(withOffset: offset, duration: durationAnimation, completion: completion)
    }
    
    private func animateHidingToRight(withDuration: Double, completion: ((Bool) -> ())?) {
        let width = bounds.size.width
        let offset = width * offsetFactor
        animateHide(withOffset: offset, duration: withDuration, completion: completion)
    }
    
    private func animateHide(withOffset: CGFloat, duration: Double, completion: ((Bool) -> ())?) {
        let toY = (bounds.size.height / CGFloat(2)) - (icon.bounds.height / 2)
        let toX = (bounds.size.width / CGFloat(2)) - (icon.bounds.width / 2) + withOffset
        
        
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () in self.text.alpha = CGFloat(0) },
                       completion: nil)
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { self.icon.frame.origin.x = toX; self.icon.frame.origin.y = toY },
                       completion: completion)
    }
}
