//
//  ShoppingItem+Domain.swift.swift
//  ShoppingListModule
//
//  Created by شیخ عامر on 2025-08-28.
//

import Foundation

public struct ShoppingItem: Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var quantity: Int
    public var note: String?
    public var isBought: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(id: UUID = UUID(), name: String, quantity: Int, note: String? = nil, isBought: Bool = false, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.note = note
        self.isBought = isBought
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
