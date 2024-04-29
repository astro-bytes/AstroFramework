//
//  AnyPublisher+Extension.swift
//  Utility
//
//  Created by Porter McGary on 2/9/24.
//

import Foundation
import Combine

extension AnyPublisher {
    public func first(timeoutAfter time: TimeInterval = .to(seconds: 5),
                      scheduler: DispatchQueue = DispatchQueue.main,
                      where predicate: @escaping (Output) -> Bool = { _ in true }) async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var found = false
            cancellable = timeout(.seconds(time), scheduler: scheduler)
                .last(where: predicate)
                .sink { completion in
                    switch completion {
                    case .finished:
                        if !found {
                            continuation.resume(throwing: CoreError.timeout)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    found = true
                    continuation.resume(returning: value)
                }
        }
    }
}
