//
//  Items.swift
//  Inventory
//
//

import Foundation
import SwiftUI

struct Item: Identifiable, Hashable{
    var id = UUID()
    var shortDescription: String
    var longDescription: String
}

class MyStuff: ObservableObject {
    
    @Published var items = [Item]()
}
