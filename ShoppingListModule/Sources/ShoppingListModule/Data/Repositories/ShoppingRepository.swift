//
//  ShoppingRepository.swift
//  ShoppingListModule
//
//  Created by شیخ عامر on 2025-08-30.
//

import Foundation
import Combine
import SwiftData

public final class ShoppingRepository: ShoppingRepositoryProtocol {
    private let modelContext: ModelContext
    private let syncService: SyncServiceProtocol
    
    public init(modelContext: ModelContext, syncService: SyncServiceProtocol) {
        self.modelContext = modelContext
        self.syncService = syncService
    }
    
    public func fetchItems(filter: ShoppingListFilter, searchText: String, sortBy: ShoppingListSort) -> AnyPublisher<[ShoppingItem], Error> {
        Future<[ShoppingItem], Error> { [weak self] promise in
            guard let self = self else { return }
            
            let descriptor = self.buildFetchDescriptor(filter: filter, searchText: searchText, sortBy: sortBy)
            
            do {
                let persistentItems = try self.modelContext.fetch(descriptor)
                let items = persistentItems.map { $0.toDomain() }
                promise(.success(items))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func addItem(_ item: ShoppingItem) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            
            let persistentItem = PersistentShoppingItem(from: item, syncStatus: .pendingCreate)
            self.modelContext.insert(persistentItem)
            
            do {
                try self.modelContext.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func updateItem(_ item: ShoppingItem) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            
            let descriptor = FetchDescriptor<PersistentShoppingItem>(
                predicate: #Predicate { $0.id == item.id }
            )
            
            do {
                if let existingItem = try self.modelContext.fetch(descriptor).first {
                    existingItem.name = item.name
                    existingItem.quantity = item.quantity
                    existingItem.note = item.note
                    existingItem.isBought = item.isBought
                    existingItem.updatedAt = Date()
                    existingItem.syncStatus = .pendingUpdate
                    
                    try self.modelContext.save()
                    promise(.success(()))
                } else {
                    promise(.failure(NSError(domain: "ShoppingRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"])))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func deleteItem(_ item: ShoppingItem) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            
            let descriptor = FetchDescriptor<PersistentShoppingItem>(
                predicate: #Predicate { $0.id == item.id }
            )
            
            do {
                if let existingItem = try self.modelContext.fetch(descriptor).first {
                    // For offline-first, mark for deletion instead of immediate removal
                    existingItem.syncStatus = .pendingDelete
                    try self.modelContext.save()
                    promise(.success(()))
                } else {
                    promise(.failure(NSError(domain: "ShoppingRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"])))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func syncWithRemote() -> AnyPublisher<Void, Error> {
        syncService.sync(modelContext: modelContext)
    }
    
    private func buildFetchDescriptor(filter: ShoppingListFilter, searchText: String, sortBy: ShoppingListSort) -> FetchDescriptor<PersistentShoppingItem> {
        // Build predicate based on filter and search text
        var predicate: Predicate<PersistentShoppingItem>?
        
        if !searchText.isEmpty {
            predicate = #Predicate { item in
                item.name.localizedStandardContains(searchText) ||
                (item.note != nil && item.note!.localizedStandardContains(searchText))
            }
        }
        
        if filter != .all {
            let isBoughtFilter = filter == .bought
            if let existingPredicate = predicate {
                predicate = #Predicate { item in
                    existingPredicate.evaluate(item) && item.isBought == isBoughtFilter
                }
            } else {
                predicate = #Predicate { item in
                    item.isBought == isBoughtFilter
                }
            }
        }
        
        // Exclude items marked for deletion
        if let existingPredicate = predicate {
            predicate = #Predicate { item in
                existingPredicate.evaluate(item) && item.syncStatus != .pendingDelete
            }
        } else {
            predicate = #Predicate { item in
                item.syncStatus != .pendingDelete
            }
        }
        
        // Build sort descriptors
        var sortDescriptors: [SortDescriptor<PersistentShoppingItem>] = []
        switch sortBy {
        case .createdAtAsc:
            sortDescriptors = [SortDescriptor(\.createdAt, order: .forward)]
        case .createdAtDesc:
            sortDescriptors = [SortDescriptor(\.createdAt, order: .reverse)]
        case .updatedAtAsc:
            sortDescriptors = [SortDescriptor(\.updatedAt, order: .forward)]
        case .updatedAtDesc:
            sortDescriptors = [SortDescriptor(\.updatedAt, order: .reverse)]
        }
        
        return FetchDescriptor<PersistentShoppingItem>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
    }
}
