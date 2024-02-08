//
//  PublishableDataSource.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation
import Combine

/// A protocol for data sources that can be synchronized, providing a publisher for updates.
public protocol PublishableDataSource {
    /// Generic representing the return value of a successful fetch
    associatedtype Output
    
    /// - Returns a publisher which can be subscribed to
    var publisher: AnyPublisher<Output, Error> { get }
}
