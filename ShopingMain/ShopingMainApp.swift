//
//  ShopingMainApp.swift
//  ShopingMain
//
//  Created by شیخ عامر on 2025-08-28.
//

import SwiftUI
import SwiftData
import ShoppingListModule

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            
            SimpleShoppingListView()
        }
    }
}

struct SimpleShoppingListView: View {
    @State private var items: [ShoppingItem] = []
    @State private var newItemName = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    Text(item.name)
                }
                
                HStack {
                    TextField("New item", text: $newItemName)
                    Button("Add") {
                        let newItem = ShoppingItem(name: newItemName, quantity: 1, note: "I am note")
                        
                        items.append(newItem)
                        newItemName = ""
                    }
                }
            }
            .navigationTitle("Shopping List")
        }
    }
}
