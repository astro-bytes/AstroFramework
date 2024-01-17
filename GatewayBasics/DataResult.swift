//
//  DataResult.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

// TODO: Comment
public enum DataResult<Payload> {
    // TODO: Comment
    case loading
    // TODO: Comment
    case success(data: Payload)
    // TODO: Comment
    case failure(cachedData: Payload?, error: Error)
}
