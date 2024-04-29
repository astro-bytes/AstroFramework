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
    var domain: String?
    var date: Date?
    var file: String?
    var line: Int?
    var method: String?
    
    func intercept(level: Logger.Level, message: String, domain: String, date: Date, file: String, line: Int, method: String) {
        self.level = level
        self.message = message
        self.domain = domain
        self.date = date
        self.file = file
        self.line = line
        self.method = method
        
        interceptIsCalled = true
    }
}
