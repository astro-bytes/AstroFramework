//
//  TimeInterval+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

/// A set of extensions and constants for manipulating TimeInterval values.
extension TimeInterval {
    /// Represents one second.
    public static let second: TimeInterval = 1
    
    /// Represents one minute, calculated as `second * 60`.
    public static let minute: TimeInterval = second * 60
    
    /// Represents one hour, calculated as `minute * 60`.
    public static let hour: TimeInterval = minute * 60
    
    /// Represents one day, calculated as `hour * 24`.
    public static let day: TimeInterval = hour * 24
    
    /// Represents one week, calculated as `day * 7`.
    public static let week: TimeInterval = day * 7
    
    /// Represents one year, calculated as `week * 52`.
    public static let year: TimeInterval = week * 52
    
    /// Represents positive infinity for TimeInterval.
    public static let infinity: TimeInterval = Double.infinity
    
    /// Converts a given number of seconds to TimeInterval.
    /// - Parameter seconds: The number of seconds.
    /// - Returns: The corresponding TimeInterval.
    public static func to(seconds: TimeInterval) -> TimeInterval {
        seconds
    }
    
    /// Converts a given number of minutes to TimeInterval.
    /// - Parameter minutes: The number of minutes.
    /// - Returns: The corresponding TimeInterval.
    public static func to(minutes: TimeInterval) -> TimeInterval {
        minute * minutes
    }
    
    /// Converts a given number of hours to TimeInterval.
    /// - Parameter hours: The number of hours.
    /// - Returns: The corresponding TimeInterval.
    public static func to(hours: TimeInterval) -> TimeInterval {
        hour * hours
    }
    
    /// Converts a given number of days to TimeInterval.
    /// - Parameter days: The number of days.
    /// - Returns: The corresponding TimeInterval.
    public static func to(days: TimeInterval) -> TimeInterval {
        day * days
    }
    
    /// Converts a given number of weeks to TimeInterval.
    /// - Parameter weeks: The number of weeks.
    /// - Returns: The corresponding TimeInterval.
    public static func to(weeks: TimeInterval) -> TimeInterval {
        week * weeks
    }
}
