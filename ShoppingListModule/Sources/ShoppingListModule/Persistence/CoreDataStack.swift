//
//  CoreDataStack.swift
//  ShoppingListModule
//
//  Created by شیخ عامر on 2025-08-28.
//

import CoreData
import Foundation

public final class CoreDataStack {
    public static let shared = CoreDataStack()

    public let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ShoppingList")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { desc, error in
            if let e = error { fatalError("CoreData load error: \(e)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }
}
