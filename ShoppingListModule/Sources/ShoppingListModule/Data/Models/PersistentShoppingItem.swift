//
//  PersistentShoppingItem.swift
//  ShoppingListModule
//
//  Created by شیخ عامر on 2025-08-30.
//

import Foundation
import SwiftData

@Model
final class PersistentShoppingItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: Int
    var note: String?
    var isBought: Bool
    var createdAt: Date
    var updatedAt: Date
    var syncStatus: SyncStatus
    
    enum SyncStatus: Int, Codable {
        case synced, pendingCreate, pendingUpdate, pendingDelete
    }
    
    init(id: UUID = UUID(),
         name: String,
         quantity: Int,
         note: String? = nil,
         isBought: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         syncStatus: SyncStatus = .pendingCreate) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.note = note
        self.isBought = isBought
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
    }
    
    convenience init(from item: ShoppingItem, syncStatus: SyncStatus = .pendingCreate) {
        self.init(
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            note: item.note,
            isBought: item.isBought,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
            syncStatus: syncStatus
        )
    }
    
    func toDomain() -> ShoppingItem {
        ShoppingItem(
            id: id,
            name: name,
            quantity: quantity,
            note: note,
            isBought: isBought,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
