//
//  ContentView.swift
//  Medicipline
//
//  Created by Putra Ganda Dewata on 03/03/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    @Query private var medicineList: [MediciplineItem]
    
    @State private var showingAddScreen = false // State to manage showing the Add Medicine screen
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(medicineList) { medicine in
                        VStack(alignment: .leading) {
                            Text(medicine.medicineName)
                                .font(.headline)
                            
                            Text("Frequency: \(medicine.medicineFrequenciesTake) times/day")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Start Date: \(medicine.addedMedicineDate, style: .date)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .navigationTitle("Medicines")
                
                // "Add" button at the bottom
                Button(action: {
                    showingAddScreen = true
                }) {
                    Text("Add New Medicine")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showingAddScreen) {
                    AddMedicineListView() // Show the Add Medicine screen
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//        .modelContainer(for: MediciplineItem.self, inMemory: true)
//}
