//
//  Result+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/22/24.
//

import Foundation

/// An extension on Result providing computed properties to extract the value or error.
extension Result {
    /// Gets the success value if the result is a success, or nil if it's a failure.
    public var value: Success? {
        switch self {
        case .success(let success):
            return success
        case .failure:
            return nil
        }
    }
    
    /// Gets the failure value if the result is a failure, or nil if it's a success.
    public var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let failure):
            return failure
        }
    }
}
