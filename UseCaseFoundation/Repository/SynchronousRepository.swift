//
//  SynchronousRepository.swift
//  UseCaseFoundation
//
//  Created by Porter McGary on 8/27/26.
//

import Foundation

/// A ``Repository`` that already holds its value, and so can answer without awaiting.
///
/// A repository in general may have to go and fetch — over a network, off a disk — which is why
/// ``Repository/get(within:)`` is asynchronous. One backed by a cache in memory does not, and
/// making its callers `await` a value it is already holding would be a lie the type system tells.
///
/// ```swift
/// // Draw immediately with whatever is on hand, and let `data` update the view when it changes.
/// let current = repository.get()
/// ```
///
/// ## Why this is a capability, not a layer
///
/// This was `GatewayFoundation.DataStore`, a protocol in another module that refined `Repository`
/// and added this one method. The name described a *place* — somewhere data is stored — while the
/// protocol described an *ability*, and living in the gateway module implied an architectural
/// significance it did not have. A consumer reasonably asked when to conform to `DataStore`
/// instead of `Repository`, and the only honest answer was "when you happen to be able to answer
/// synchronously."
///
/// The mechanism layer it appeared to name is already ``GatewayFoundation/DataSource`` and its
/// family: those describe where bytes come from. `Repository` describes freshness policy. Nothing
/// sat between them.
public protocol SynchronousRepository<Payload>: Repository {
    /// - Returns: The current state of the data, as it stands right now.
    func get() -> DataResult<Payload>
}

/// A ``SynchronousRepository`` of elements keyed by their identifier.
public protocol SynchronousKeyedRepository<Element>: SynchronousRepository, KeyedRepository
where Payload == [Element.ID: Element] {
    /// Retrieves one element as it stands right now.
    /// - Parameter id: The identifier of the element to retrieve.
    /// - Returns: The element, or a failure if this repository is not holding it.
    func get(by id: Element.ID) -> DataResult<Element>
}
