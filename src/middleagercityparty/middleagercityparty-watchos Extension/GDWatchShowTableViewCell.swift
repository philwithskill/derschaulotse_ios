//
//  GDWatchShowTableViewCell.swift
//  middleagercityparty
//
//  Created by Christian Trümper on 28.07.17.
//  Copyright © 2017 Philipp Faßheber. All rights reserved.
//

import WatchKit

@available(iOS 8.2, *)
class GDWatchShowTableViewCell: NSObject
{
    @IBOutlet var headerLabel: WKInterfaceLabel?
    @IBOutlet var locationLabel: WKInterfaceLabel?
    @IBOutlet var dateLabel: WKInterfaceLabel?
}
