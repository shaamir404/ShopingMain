//
//  ShoppingListView.swift
//  ShoppingListModule
//
//  Created by شیخ عامر on 2025-08-30.
//

import SwiftUI

public struct ShoppingListView: View {
    @StateObject private var viewModel: ShoppingListViewModel
    @State private var showingAddItem = false
    @State private var showingError = false
    
    public init(viewModel: ShoppingListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                // Filter and Sort controls
                HStack {
                    Picker("Filter", selection: $viewModel.filter) {
                        ForEach(ShoppingListFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Sort", selection: $viewModel.sortBy) {
                        ForEach(ShoppingListSort.allCases, id: \.self) { sort in
                            Text(sort.rawValue).tag(sort)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Search bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                // List of items
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.items.isEmpty {
                    Text("No items found")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            ShoppingItemRow(item: item) {
                                viewModel.toggleBoughtStatus(for: item)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.sync()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView { name, quantity, note in
                    viewModel.addItem(name: name, quantity: quantity, note: note)
                }
            }
            .alert("Error", isPresented: $showingError, presenting: viewModel.errorMessage) { _ in
                Button("OK", role: .cancel) { }
            } message: { message in
                Text(message)
            }
            .onChange(of: viewModel.errorMessage) { error in
                showingError = error != nil
            }
        }
    }
}

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isBought ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isBought ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                    .strikethrough(item.isBought, color: .gray)
                
                if let note = item.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .strikethrough(item.isBought, color: .gray)
                }
            }
            
            Spacer()
            
            Text("\(item.quantity)")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String, Int, String?) -> Void
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var note = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    
                    Stepper(value: $quantity, in: 1...100) {
                        Text("Quantity: \(quantity)")
                    }
                    
                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(name, quantity, note.isEmpty ? nil : note)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
