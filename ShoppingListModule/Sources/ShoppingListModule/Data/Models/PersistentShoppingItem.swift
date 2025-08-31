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
    var syncStatus: Int  // Store as Int
    
    enum SyncStatus: Int, Codable {
        case synced = 0, pendingCreate = 1, pendingUpdate = 2, pendingDelete = 3
    }
    
    init(id: UUID = UUID(),
         name: String,
         quantity: Int,
         note: String? = nil,
         isBought: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         syncStatus: SyncStatus = .pendingCreate) {
        
        // Initialize ALL stored properties
        self.id = id
        self.name = name
        self.quantity = quantity
        self.note = note
        self.isBought = isBought
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus.rawValue  // Don't forget this line!
    }
    
    // Helper to get enum from raw value
    func getSyncStatus() -> SyncStatus {
        return SyncStatus(rawValue: syncStatus) ?? .pendingCreate
    }
    
    // Helper to set enum from raw value
    func setSyncStatus(_ status: SyncStatus) {
        syncStatus = status.rawValue
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
            syncStatus: syncStatus  // This will be converted to rawValue in the main init
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
