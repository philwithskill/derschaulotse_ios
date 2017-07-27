//
//  GDShowTableViewCell.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 13/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import UIKit

class GDShowTableViewCell : UITableViewCell {
    
    var show : GDShow? {
        didSet {
            labelShow.text = show?.name
            labelPlace.text = show?.stage?.name
            
            let name = PlaceUtil.iconNameFor(place: show?.stage)
            iconPlace.image = UIImage(named: name)
        }
    }
    
    @IBOutlet weak var labelPlace: UILabel!
    @IBOutlet weak var iconPlace: UIImageView!
    @IBOutlet weak var labelShow: UILabel!
    @IBOutlet weak var reminderStateIcon: GDReminderStateIcon!
    @IBOutlet weak var reminderButton: UIButton!
    
    var reminderButtonTapped : ((_ wantsToEnable: Bool) -> ())?
    
    @IBAction func reminderButtonTapped(_ sender: Any) {
        if reminderStateIcon.isTransforming {
            return
        }
        
        reminderButton.isSelected = !reminderButton.isSelected
        reminderStateIcon.isSelected = reminderButton.isSelected
        
        if reminderButton.isSelected {
            reminderStateIcon.transformToCheckmark()
        } else {
            reminderStateIcon.transformToPlus()
        }
        
        //important: set selection state correct before calling this method
        reminderButtonTapped?(reminderButton.isSelected)
    }
    
    func selectReminderButton() {
        reminderButton.isSelected = true
        reminderStateIcon.isSelected = true
        reminderStateIcon.transformToCheckmark()
    }
    
    func deselectReminderButton() {
        reminderButton.isSelected = false
        reminderStateIcon.isSelected = false
        reminderStateIcon.transformToPlus()
    }
    
    func reuseWithReminder() {
        let oldState = reminderButton.isSelected
        
        reminderButton.isSelected = true
        reminderStateIcon.isSelected = true
        
        if (oldState != reminderButton.isSelected) {
            reminderStateIcon.setNeedsDisplay()
        }
    }
    
    func reuseWithoutReminder() {
        let oldState = reminderButton.isSelected
        
        reminderButton.isSelected = false
        reminderStateIcon.isSelected = false
        
        if (oldState != reminderButton.isSelected) {
            reminderStateIcon.setNeedsDisplay()
        }
    }
}
