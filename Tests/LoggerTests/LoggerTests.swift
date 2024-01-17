//
//  LoggerTests.swift
//  LoggerTests
//
//  Created by Porter McGary on 1/18/24.
//

import XCTest
import Combine
@testable import Logger

final class LoggerTests: XCTestCase {
    
    var cancelBucket = Set<AnyCancellable>()
    
    override func setUp() {
        Logger.shared = .init()
    }
    
    func testApplyInterceptor() {
        let mock = MockInterceptor()
        
        Logger.apply(interceptor: mock)
        
        XCTAssertEqual(Logger.shared.interceptors.count, 2)
        XCTAssertNotNil(Logger.shared.interceptors.first(where: { $0 is MockInterceptor }))
        XCTAssertEqual(Logger.shared.interceptors.filter({ $0 is MockInterceptor }).count, 1)
    }
    
    func testApplyMultipleInterceptor() {
        let mock = MockInterceptor()
        
        Logger.apply(interceptors: [mock, mock])
        
        XCTAssertEqual(Logger.shared.interceptors.count, 3)
        XCTAssertNotNil(Logger.shared.interceptors.first(where: { $0 is MockInterceptor }))
        XCTAssertEqual(Logger.shared.interceptors.filter({ $0 is MockInterceptor }).count, 2)
    }
    
    func testCreatingLogCallsIntercepts() {
        let mock = MockInterceptor()
        let level = Logger.Level.info
        let domain = "The Domain"
        let date = Date.now
        let msg = "Test"
        let file = "File Name"
        let line = 1
        let method = "Crazy Horse"
        
        Logger.apply(interceptor: mock)
        
        let methodCallExpectation = XCTestExpectation()
        mock.$interceptIsCalled.sink { isCalled in
            if isCalled {
                XCTAssertEqual(mock.level, level)
                XCTAssertEqual(mock.message, msg)
                XCTAssertEqual(mock.domain, domain)
                XCTAssertEqual(mock.date, date)
                XCTAssertEqual(mock.file, file)
                XCTAssertEqual(mock.line, line)
                XCTAssertEqual(mock.method, method)
                methodCallExpectation.fulfill()
            }
        }.store(in: &cancelBucket)
        
        Logger.logBase(level, msg: msg, domain: domain, date: date, file: file, line: line, method: method)
        wait(for: [methodCallExpectation], timeout: 1)
        
        XCTAssertTrue(mock.interceptIsCalled)
    }
}
