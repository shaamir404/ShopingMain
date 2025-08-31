//
//  ShoppingListViewModel.swift
//  ShoppingListModule
//
//  Created by شیخ عامر on 2025-08-30.
//

import Foundation
import Combine

@MainActor
public final class ShoppingListViewModel: ObservableObject {
    @Published public var items: [ShoppingItem] = []
    @Published public var filter: ShoppingListFilter = .notBought
    @Published public var searchText: String = ""
    @Published public var sortBy: ShoppingListSort = .createdAtDesc
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let repository: ShoppingRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public init(repository: ShoppingRepositoryProtocol) {
        self.repository = repository
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3($filter, $searchText, $sortBy)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] filter, searchText, sortBy in
                self?.loadItems(filter: filter, searchText: searchText, sortBy: sortBy)
            }
            .store(in: &cancellables)
    }
    
    private func loadItems(filter: ShoppingListFilter, searchText: String, sortBy: ShoppingListSort) {
        isLoading = true
        repository.fetchItems(filter: filter, searchText: searchText, sortBy: sortBy)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] items in
                self?.items = items
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
    
    public func addItem(name: String, quantity: Int, note: String?) {
        let newItem = ShoppingItem(name: name, quantity: quantity, note: note)
        repository.addItem(newItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    public func updateItem(_ item: ShoppingItem) {
        repository.updateItem(item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    public func deleteItem(_ item: ShoppingItem) {
        repository.deleteItem(item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    public func toggleBoughtStatus(for item: ShoppingItem) {
        var updatedItem = item
        updatedItem.isBought.toggle()
        updatedItem.updatedAt = Date()
        updateItem(updatedItem)
    }
    
    public func sync() {
        isLoading = true
        repository.syncWithRemote()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                } else {
                    // Reload items after successful sync
                    self?.loadItems(filter: self?.filter ?? .notBought,
                                  searchText: self?.searchText ?? "",
                                  sortBy: self?.sortBy ?? .createdAtDesc)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
