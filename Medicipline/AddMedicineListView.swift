//
//  AddMedicineListView.swift
//  Medicipline
//
//  Created by Putra Ganda Dewata on 03/03/26.
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddMedicineListView: View {
    @Environment(\.modelContext) private var context // Access SwiftData
    @Environment(\.dismiss) private var dismiss // Dismiss the screen after saving
    
    @State private var medicineName = "" // The state to hold the new medicine name
    @State private var medicineFrequenciesTake = 1 // Default frequency is 1
    @State private var addedMedicineDate = Date() // Default to the current date
    @State private var isBeforeAndAfterEat = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medicine Details")) {
                    TextField("Enter medicine name", text: $medicineName)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                    
                    Stepper("Frequency: \(medicineFrequenciesTake) times per day", value: $medicineFrequenciesTake, in: 1...10) // Stepper for frequency
                    
                    DatePicker("Date to Start", selection: $addedMedicineDate, displayedComponents: .date) // Date picker for the start date
                }
                
                Button("Save Medicine") {
                    saveMedicine()
                }
                .disabled(medicineName.isEmpty) // Disable button if name is empty
            }
            .navigationTitle("Add Medicine")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func saveMedicine() {
        let newMedicine = MediciplineItem(
            medicineName: medicineName,
            medicineFrequenciesTake: medicineFrequenciesTake,
            addedMedicineDate: addedMedicineDate,
            isBeforeAndAfterEat: isBeforeAndAfterEat
        )
        context.insert(newMedicine) // Add the new medicine to the database
        
        try? context.save()
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.putragandad.Medicipline")
        sharedDefaults?.set(medicineName, forKey: "medicineName")
        
        WidgetCenter.shared.reloadAllTimelines()
        
        dismiss() // Dismiss the Add screen after saving
    }
}

#Preview {
    AddMedicineListView()
}
