//
//  TimeIntervalTests.swift
//  UtilityTests
//
//  Created by Porter McGary on 1/20/24.
//

import XCTest

final class TimeIntervalTests: XCTestCase {
    
    func testConstants() {
        XCTAssertEqual(TimeInterval.second, 1)
        XCTAssertEqual(TimeInterval.minute, 60)
        XCTAssertEqual(TimeInterval.hour, 3600)
        XCTAssertEqual(TimeInterval.day, 86400)
        XCTAssertEqual(TimeInterval.week, 604800)
        XCTAssertEqual(TimeInterval.year, 31449600)
        XCTAssertEqual(TimeInterval.infinity, Double.infinity)
    }
    
    func testToSeconds() {
        XCTAssertEqual(TimeInterval.to(seconds: 10), 10)
        XCTAssertEqual(TimeInterval.to(seconds: 30.5), 30.5)
    }
    
    func testToMinutes() {
        XCTAssertEqual(TimeInterval.to(minutes: 5), 300)
        XCTAssertEqual(TimeInterval.to(minutes: 7.5), 450)
    }
    
    func testToHours() {
        XCTAssertEqual(TimeInterval.to(hours: 2), 7200)
        XCTAssertEqual(TimeInterval.to(hours: 3.5), 12600)
    }
    
    func testToDays() {
        XCTAssertEqual(TimeInterval.to(days: 1), 86400)
        XCTAssertEqual(TimeInterval.to(days: 2.5), 216000)
    }
    
    func testToWeeks() {
        XCTAssertEqual(TimeInterval.to(weeks: 1), 604800)
        XCTAssertEqual(TimeInterval.to(weeks: 3.5), 2116800)
    }
}
