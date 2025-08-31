// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import SwiftData

@available(iOS 17, *)
public struct ShoppingListModule {
    @MainActor public static func createShoppingListView(modelContext: ModelContext) -> some View {
        let syncService = MockSyncService()
        let repository = ShoppingRepository(modelContext: modelContext, syncService: syncService)
        let viewModel = ShoppingListViewModel(repository: repository)
        return ShoppingListView(viewModel: viewModel)
    }
}
