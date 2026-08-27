//
//  DataStore.swift
//  GatewayFoundation
//
//  Created by Porter McGary on 1/20/24.
//

import Combine
import Foundation
import UseCaseFoundation
import UtilityFoundation

/// A ``UseCaseFoundation/Repository`` whose current value can also be read synchronously.
///
/// The gateway layer implements the port the use-case layer declares, which is why this refines
/// `Repository` rather than restating it. It previously declared `data`, `refresh()`,
/// `refresh() async`, `set(_:)` and `clear()` for itself — the same five, with the same doc
/// comment, in two modules — leaving nothing to say which one a type ought to conform to.
///
/// What it adds is the synchronous accessor. A store holds its value, so it can hand it over
/// without awaiting; a repository in general may have to go and fetch it.
public protocol DataStore<Payload>: Repository {
    /// - Returns: the current state value of the data.
    func get() -> DataResult<Payload>
}
