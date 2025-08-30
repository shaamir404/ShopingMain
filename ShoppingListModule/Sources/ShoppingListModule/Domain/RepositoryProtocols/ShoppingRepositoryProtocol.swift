//
//  ShoppingRepositoryProtocol.swift
//  ShoppingListModule
//
//  Created by شیخ عامر on 2025-08-30.
//

import Foundation
import Combine

public protocol ShoppingRepositoryProtocol {
    func fetchItems(filter: ShoppingListFilter, searchText: String, sortBy: ShoppingListSort) -> AnyPublisher<[ShoppingItem], Error>
    func addItem(_ item: ShoppingItem) -> AnyPublisher<Void, Error>
    func updateItem(_ item: ShoppingItem) -> AnyPublisher<Void, Error>
    func deleteItem(_ item: ShoppingItem) -> AnyPublisher<Void, Error>
    func syncWithRemote() -> AnyPublisher<Void, Error>
}

public enum ShoppingListFilter: String, CaseIterable {
    case all = "All"
    case bought = "Bought"
    case notBought = "Not Bought"
}

public enum ShoppingListSort: String, CaseIterable {
    case createdAtAsc = "Oldest First"
    case createdAtDesc = "Newest First"
    case updatedAtAsc = "Recently Updated"
    case updatedAtDesc = "Least Recently Updated"
}
