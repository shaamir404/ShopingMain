//
//  ContentView.swift
//  ShopingMain
//
//  Created by شیخ عامر on 2025-08-28.
//

import SwiftUI
import ShoppingListModule

struct ContentView: View {
    var body: some View {
        Text("My App")
            .onAppear {
                
                print("ShoppingListModule is available!")
            }
    }
}

#Preview {
    ContentView()
}
