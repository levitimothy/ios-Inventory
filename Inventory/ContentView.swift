//
//  ContentView.swift
//  Inventory
//
//

import SwiftUI
import SQLite3

struct DismissView: View{
    @Environment(\.dismiss) var dismiss
    
    var body: some View{
        Button("Cancel"){
            dismiss()
        }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var arr: MyStuff
    
    var body: some View {
        HStack{
            NavigationView{
                VStack{
                    let temp = $arr.items.isEmpty
                    if temp == true {
                        List{
                            
                        }
                        .toolbar{
                            ToolbarItem{
                                NavigationLink("Add"){
                                    NewItem(arr: self.$arr.items).navigationBarBackButtonHidden(true)
                                }
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Inventory")
                        .padding()
                    } else if temp == false {
                        List{
                            ForEach(arr.items) {
                                item in
                                    VStack{
                                        let index = arr.items.firstIndex(of: Item(shortDescription: item.shortDescription, longDescription: item.longDescription))
                                        NavigationLink(destination: EditItem(arr: self.$arr.items, index: index ?? 0, tempShort: item.shortDescription, tempLong: item.longDescription).navigationBarBackButtonHidden(true)){
                                            
                                            Text(item.shortDescription).font(.title3)
                                            Text(item.longDescription).font(.subheadline)
                                        }
                                    }
                                
                            }
                            .onDelete(perform: {
                                indexSet in arr.items.remove(atOffsets: indexSet)
                            })
                        }
                        .toolbar{
                            ToolbarItem{
                                NavigationLink("Add"){
                                    NewItem(arr: self.$arr.items).navigationBarBackButtonHidden(true)
                                }
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Inventory")
                        .padding()
                    }
                    
                }
            }
        }.onChange(of: scenePhase) {
            newPhase in
            if newPhase == .active{
                readDatabase(items: &arr.items)
            } else if newPhase == .inactive{
                writeDatabase(items: &arr.items)
            }
        }
    }
}

struct EditItem: View{
    @Environment(\.dismiss) var dismiss
    @Binding var arr: [Item]
    @State var index: Int
    @State var tempShort: String
    @State var tempLong: String
    
    var body: some View{
        VStack{
            HStack{
                Text("Short: ")
                TextField(arr[index].shortDescription, text: $tempShort)
                    .accessibilityLabel("editShortDescription")
                    .accessibilityValue(tempShort)
            }.padding()
            HStack{
                Text("Long: ")
                TextField(arr[index].longDescription, text: $tempLong)
                    .accessibilityLabel("editLongDescription")
                    .accessibilityValue(tempLong)
            }.padding()
            Spacer()
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                DismissView()
            }
            ToolbarItem(placement: .navigationBarTrailing){
                Button("Save"){
                    arr[index + 1] = (Item(shortDescription: tempShort, longDescription: tempLong))
                    dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Edit Item")
        .padding()
    }
}

struct NewItem: View{
    @Environment(\.dismiss) var dismiss
    @Binding var arr: [Item]
    @State var temp1: String = ""
    @State var temp2: String = ""
    
    var body: some View{
        VStack{
            HStack{
                Text("Short: ")
                TextField("", text: $temp1).accessibilityLabel("addShortDescription")
            }.padding()
            HStack{
                Text("Long: ")
                TextField("", text: $temp2).accessibilityLabel("addLongDescription")
            }.padding()
            Spacer()
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                DismissView()
            }
            ToolbarItem(placement: .navigationBarTrailing){
                
                    Button("Save"){
                        arr.append(Item(shortDescription: temp1, longDescription: temp2))
                        dismiss()
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Add New Item")
        .padding()
    }
}

func readDatabase(items: inout [Item]){
    items.removeAll()
    
    var db: OpaquePointer?
    
    let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Inventory.sqlite")
    
    if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
        print("Error")
    }
    
    let createTableQuery = "CREATE TABLE IF NOT EXISTS Inventory (id INTEGER PRIMARY KEY AUTOINCREMENT, shortDesc VARCHAR, longDesc VARCHAR)"
    
    if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
        print("Error")
    }
    
    let selectQuery = "SELECT * FROM Inventory"
    
    var stmt: OpaquePointer?
    
    if sqlite3_prepare(db, selectQuery, -1, &stmt, nil) != SQLITE_OK{
        print("Error")
        return
    }
    
    while(sqlite3_step(stmt) == SQLITE_ROW){
        let sDesc = String(cString: sqlite3_column_text(stmt, 1))
        let lDesc = String(cString: sqlite3_column_text(stmt, 2))

        items.append(Item( shortDescription: String(sDesc), longDescription: String(lDesc)))
    }
    
}

func writeDatabase(items: inout [Item]){
    var db: OpaquePointer?
    
    let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Inventory.sqlite")
    
    if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
        print("Error")
    }
    let deleteQuery = "Delete FROM Inventory"
    
    if sqlite3_exec(db, deleteQuery, nil, nil, nil) != SQLITE_OK{
        print("Error")
    }
    
    let selectQuery = "INSERT INTO Inventory (shortDesc, LongDesc) VALUES (?,?)"
    
    var stmt: OpaquePointer?
    
    for item in items{
        if sqlite3_prepare(db, selectQuery, -1, &stmt, nil) != SQLITE_OK{
            print("Error1")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, (item.shortDescription as NSString).utf8String, -1, nil) != SQLITE_OK{
            print("Error2")
        }
        
        if sqlite3_bind_text(stmt, 2, (item.longDescription as NSString).utf8String, -1, nil) != SQLITE_OK{
            print("Error3")
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Error5")
        }
    }
    sqlite3_close(db)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
