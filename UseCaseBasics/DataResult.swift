//
//  DataResult.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation
import Utility

/// Represents the result of an asynchronous data operation.
public enum DataResult<Payload> {
    /// Indicated the result has not been processed at least once
    case uninitialized
    
    /// - Parameter cachedData: The cached data, if available, that can be used until loaded, this cachedData is most likely expired. Use at your own risk.
    case loading(cachedData: Payload?)
    
    /// Indicates a successful data operation with the associated payload.
    /// - Parameter data: The payload associated with the success case.
    case success(data: Payload)
    
    /// Indicates a failure in the data operation with an optional cached data and an error.
    /// - Parameters:
    ///   - cachedData: The cached data, if available, that can be used as a fallback, this cachedData maybe expired. Use at your own risk.
    ///   - error: The error that occurred during the data operation.
    case failure(cachedData: Payload?, error: Error)
    
    /// - Returns the payload if there is one. Use at your own risk this payload is potentially expired
    public var payload: Payload? {
        switch self {
        case .uninitialized:
            return nil
        case .loading(let cachedData):
            return cachedData
        case .success(let data):
            return data
        case .failure(let cachedData, _):
            return cachedData
        }
    }
    
    /// - Returns the error if there is one
    public var error: Error? {
        switch self {
        case .failure(_, let error):
            return error
        default: return nil
        }
    }
    
    /// - Returns a flag indicating that the result is in a loading state
    public var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }
}

extension DataResult: Equatable where Payload: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .uninitialized:
            guard case .uninitialized = rhs else { return false }
        case .loading(let cachedData):
            guard case .loading(let rhsCachedData) = rhs,
                    rhsCachedData == cachedData
            else { return false }
        case .success(let data):
            guard case .success(let rhsData) = rhs,
                    rhsData == data
            else { return false }
        case .failure(let cachedData, let error):
            guard case .failure(let rhsCachedData, let rhsError) = rhs,
                  rhsCachedData == cachedData,
                  rhsError.toEquatableError() == error.toEquatableError()
            else { return false }
        }
        return true
    }
}
