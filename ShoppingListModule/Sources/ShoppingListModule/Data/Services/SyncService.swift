//
//  SyncService.swift
//  ShoppingListModule
//
//  Created by شیخ عامر on 2025-08-30.
//

import Foundation
import Combine
import SwiftData

protocol SyncServiceProtocol {
    func sync(modelContext: ModelContext) -> AnyPublisher<Void, Error>
}

public class MockSyncService: SyncServiceProtocol {
    private let networkDelay: TimeInterval
    private let failureRate: Double
    
    init(networkDelay: TimeInterval = 1.0, failureRate: Double = 0.2) {
        self.networkDelay = networkDelay
        self.failureRate = failureRate
    }
    
    func sync(modelContext: ModelContext) -> AnyPublisher<Void, Error> {
        Deferred {
            Future<Void, Error> { promise in
                // Simulate network delay
                DispatchQueue.global().asyncAfter(deadline: .now() + self.networkDelay) {
                    // Simulate occasional failure
                    if Double.random(in: 0...1) < self.failureRate {
                        promise(.failure(NSError(domain: "SyncService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Network error"])))
                        return
                    }
                    
                    do {
                        // Process pending changes with last-write-wins strategy
                        try self.processPendingChanges(modelContext: modelContext)
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .retryWithExponentialBackoff()
        .eraseToAnyPublisher()
    }
    
    private func processPendingChanges(modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<PersistentShoppingItem>()
        let allItems = try modelContext.fetch(descriptor)
        
        for item in allItems {
            // Use the helper method to get the enum value
            switch item.getSyncStatus() {
            case .pendingCreate:
                // Simulate API call to create item
                print("Syncing create for item: \(item.name)")
                item.setSyncStatus(.synced)
                
            case .pendingUpdate:
                // Simulate API call to update item
                print("Syncing update for item: \(item.name)")
                item.setSyncStatus(.synced)
                
            case .pendingDelete:
                // Simulate API call to delete item, then remove locally
                print("Syncing delete for item: \(item.name)")
                modelContext.delete(item)
                
            case .synced:
                // Already synced, no action needed
                break
            }
        }
        
        try modelContext.save()
    }
}

extension Publisher {
    func retryWithExponentialBackoff(maxRetries: Int = 3, initialDelay: TimeInterval = 1.0) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            var retries = 0
            func attempt() -> AnyPublisher<Output, Failure> {
                return Future<Output, Failure> { promise in
                    let delay = initialDelay * pow(2.0, Double(retries))
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        promise(.failure(error))
                    }
                }
                .flatMap { _ in self }
                .catch { error -> AnyPublisher<Output, Failure> in
                    retries += 1
                    if retries < maxRetries {
                        return attempt()
                    } else {
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
            }
            return attempt()
        }
        .eraseToAnyPublisher()
    }
}
