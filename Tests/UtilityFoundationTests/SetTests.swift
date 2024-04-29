//
//  SetTests.swift
//  UtilityTests
//
//  Created by Porter McGary on 1/20/24.
//

import XCTest
@testable import UtilityFoundation

final class SetTests: XCTestCase {
    func testAsArray() {
        // Arrange
        let inputSet: Set<Int> = [1, 2, 3, 4, 5]
        
        // Act
        let resultArray = inputSet.asArray
        
        // Assert
        XCTAssertEqual(resultArray.sorted(), [1, 2, 3, 4, 5]) // Ensure the array contains the same elements as the set
    }
}
