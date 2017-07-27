//
//  GDFirstShowTableViewCell.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 20/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import UIKit

class GDFirstShowTableViewCell : UITableViewCell {
    
    var show : GDShow? {
        didSet {
            labelShow.text = show?.name
        }
    }
    
    @IBOutlet weak var labelShow: UILabel!
}
