//
//  MockInterceptor.swift
//  LoggerTests
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation
import LoggerFoundation

class MockInterceptor: Interceptor {
    
    @Published var interceptIsCalled = false
    
    var level: Logger.Level?
    var message: String?
    var data: [String: String]?
    var error: Error?
    var domain: String?
    var date: Date?
    var file: String?
    var line: Int?
    var method: String?
    
    func intercept(level: LoggerFoundation.Logger.Level, message: String, error: (any Error)?, data: [String : String]?, domain: String, date: Date, file: String, line: Int, method: String) {
        self.level = level
        self.message = message
        self.error = error
        self.data = data
        self.domain = domain
        self.date = date
        self.file = file
        self.line = line
        self.method = method
        
        interceptIsCalled = true
    }
}
