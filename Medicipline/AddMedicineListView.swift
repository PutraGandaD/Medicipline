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
    
    @State private var medicineNames: [String] = [""]
    @State private var medicineFrequenciesTake = 1 // Default frequency is 1
    @State private var addedMedicineDate = Date() // Default to the current date
    @State private var isBeforeAndAfterEat = false
    
    @State private var medicineTimes: [Date] = [Date()]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medicine Details")) {
                    Section(header: Text("Medicine Names")) {
                        
                        ForEach(medicineNames.indices, id: \.self) { index in
                            HStack {
                                TextField("Enter medicine name",
                                          text: $medicineNames[index])
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.words)
                                
                                if medicineNames.count > 1 {
                                    Button(role: .destructive) {
                                        medicineNames.remove(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                    }
                                }
                            }
                        }
                        
                        Button {
                            medicineNames.append("")
                        } label: {
                            Label("Add Another Medicine", systemImage: "plus.circle.fill")
                        }
                    }
                    
                    Stepper(
                        "Frequency: \(medicineFrequenciesTake) times per day",
                        value: $medicineFrequenciesTake,
                        in: 1...10
                    )
                    .onChange(of: medicineFrequenciesTake) { oldValue, newValue in
                        
                        if newValue > medicineTimes.count {
                            // Add new time(s)
                            medicineTimes.append(contentsOf: Array(
                                repeating: Date(),
                                count: newValue - medicineTimes.count
                            ))
                        } else if newValue < medicineTimes.count {
                            // Remove extra time(s)
                            medicineTimes.removeLast(medicineTimes.count - newValue)
                        }
                    }
                    
                    Toggle("Take After Eat", isOn: $isBeforeAndAfterEat)
                    
                    DatePicker("Date to Start", selection: $addedMedicineDate, displayedComponents: .date) // Date picker for the start date
                    
                    Section(header: Text("Medicine Times")) {
                        ForEach(medicineTimes.indices, id: \.self) { index in
                            DatePicker(
                                "Time \(index + 1)",
                                selection: $medicineTimes[index],
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                        }
                    }
                }
                
                Button("Save Medicine") {
                    saveMedicine()
                }
                .disabled(medicineNames.isEmpty) // Disable button if name is empty
            }
            .navigationTitle("Add Medicine")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func saveMedicine() {
        
        let filteredNames = medicineNames
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !filteredNames.isEmpty else { return }
        
        for index in medicineTimes.indices {
            
            let newMedicine = MediciplineItem(
                medicineName: filteredNames, // 🔥 whole array
                medicineFrequenciesTake: medicineFrequenciesTake,
                addedMedicineDate: addedMedicineDate,
                isBeforeAndAfterEat: isBeforeAndAfterEat,
                medicineTimes: medicineTimes[index] // index-based
            )
            
            context.insert(newMedicine)
            
            scheduleNotification(
                for: medicineTimes[index],
                medicineNames: filteredNames,
                isAfterEat: isBeforeAndAfterEat
            )
        }
        
        try? context.save()
        
        WidgetCenter.shared.reloadAllTimelines()
        
        dismiss()
    }
    
    private func scheduleNotification(
        for time: Date,
        medicineNames: [String],
        isAfterEat: Bool
    ) {
        let content = UNMutableNotificationContent()
        
        let joinedNames = medicineNames.joined(separator: ", ")
        let eatText = isBeforeAndAfterEat ? "After Eat" : "Before Eat"
        
        content.title = "💊 Time to take your medication!"
            content.body = """
            \(eatText)
            \(joinedNames)
            """
        
        // Extract hour & minute
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // Repeat daily
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let identifier = UUID().uuidString
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    AddMedicineListView()
}
