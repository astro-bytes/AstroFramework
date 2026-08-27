//
//  Entity.swift
//  EntityFoundation
//
//  Created by Porter McGary on 1/20/24.
//

import Foundation

/// A protocol representing an entity, conforming to Identifiable, Equatable, Hashable and Sendable.
///
/// `Sendable` because an entity is domain data that moves between concurrency domains as a matter
/// of course — out of a repository on a background task, into a view on the main actor. Conforming
/// types are value types holding value types, so the requirement is usually satisfied for free.
public protocol Entity: Identifiable, Equatable, Hashable, Sendable where ID: Sendable {}
