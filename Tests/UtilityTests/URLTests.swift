//
//  URLTests.swift
//  UtilityTests
//
//  Created by Porter McGary on 1/20/24.
//

import XCTest

final class URLTests: XCTestCase {
    
    // Assuming you have a directory named "TestDirectory" in your project
    let validDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent("TestDirectory")
    
    // Assuming you have a file named "TestFile.txt" in the "TestDirectory"
    let validFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("TestDirectory").appendingPathComponent("TestFile.txt")
    
    // An invalid URL that doesn't exist
    let invalidURL = FileManager.default.temporaryDirectory.appendingPathComponent("NonExistentDirectory")
    
    // Use the validDirectoryURL, validFileURL, and invalidURL in your tests
    
    override func setUpWithError() throws {
        try FileManager.default.createDirectory(at: validDirectoryURL, withIntermediateDirectories: true)
        try "Special Something".write(to: validFileURL, atomically: false, encoding: .utf8)
    }
    
    func testIsDirectory() {
        XCTAssertTrue(validDirectoryURL.isDirectory)
        XCTAssertFalse(validFileURL.isDirectory)
        XCTAssertFalse(invalidURL.isDirectory)
    }
    
    func testIsFile() {
        XCTAssertFalse(validDirectoryURL.isFile)
        XCTAssertTrue(validFileURL.isFile)
        XCTAssertFalse(invalidURL.isFile)
    }
    
}
