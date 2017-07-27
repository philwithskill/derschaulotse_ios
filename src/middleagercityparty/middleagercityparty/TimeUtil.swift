//
//  TimeUtil.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 17/11/16.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import Foundation

class TimeUtil {
    
    static func isNewDay(first: Date, second: Date) -> Bool {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let flags = Set<Calendar.Component>([.day])
        let firstComponents = calendar.dateComponents(flags, from: first)
        let secondComponents = calendar.dateComponents(flags, from: second)
        
        let firstDay = firstComponents.day
        let secondDay = secondComponents.day

        return firstDay != secondDay
    }
    
    //TODO docu sorted list needed
    static func findTimeBefore(time: GDTime, collection: [GDTime]) -> GDTime {
        
        let index = collection.index { (t) -> Bool in
            return t === time
        }
        
        if index == 0 || index == nil {
            return time
        } else {
            return collection[index! - 1]
        }
    }
    
    //TODO docu sorted list needed
    static func containsCurrentTime(_ times: [GDTime]) -> GDTime? {
        let curr = Date().timeIntervalSince1970
        
        for var i in 0 ..< (times.count - 1) {
            let first = times[i]
            let second = times[i + 1]
            
            if first.date == nil || second.date == nil {
                break
            }
            
            let start = first.date!.timeIntervalSince1970
            let end = second.date!.timeIntervalSince1970
            
            if curr >= start && curr < end {
                return first
            }
        }
        
        return nil
    }
    
    static func itsFestivalTime(_ times: [GDTime]) -> Bool {
        return containsCurrentTime(times) != nil
    }
}
