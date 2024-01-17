//
//  TimeInterval+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

extension TimeInterval {
    // TODO: Comment
    public static let second: TimeInterval = 1
    
    // TODO: Comment
    public static let minute: TimeInterval = second * 60
    
    // TODO: Comment
    public static let hour: TimeInterval = minute * 60
    
    // TODO: Comment
    public static let day: TimeInterval = hour * 24
    
    // TODO: Comment
    public static let week: TimeInterval = day * 7
    
    // TODO: Comment
    public static let year: TimeInterval = week * 52
    
    // TODO: Comment
    public static let infinity: TimeInterval = Double.infinity
    
    // TODO: Comment
    public static func to(seconds: TimeInterval) -> TimeInterval {
        seconds
    }
    
    // TODO: Comment
    public static func to(minutes: TimeInterval) -> TimeInterval {
        minute * minutes
    }
    
    // TODO: Comment
    public static func to(hours: TimeInterval) -> TimeInterval {
        hour * hours
    }
    
    // TODO: Comment
    public static func to(days: TimeInterval) -> TimeInterval {
        day * days
    }
    
    // TODO: Comment
    public static func to(weeks: TimeInterval) -> TimeInterval {
        week * weeks
    }
}
