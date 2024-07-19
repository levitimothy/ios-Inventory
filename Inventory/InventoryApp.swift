//
//  InventoryApp.swift
//  Inventory
//
//  Created by Joanne Timothy on 6/24/24.
//

import SwiftUI

@main
struct InventoryApp: App {
    @StateObject private var arr = MyStuff()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(arr)
        }
    }
}
