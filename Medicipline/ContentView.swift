//
//  ContentView.swift
//  Medicipline
//
//  Created by Putra Ganda Dewata on 03/03/26.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    @Query private var medicineList: [MediciplineItem]
    
    @State private var showingAddScreen = false // State to manage showing the Add Medicine screen
    
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(sortedGroupKeys, id: \.self) { key in
                        
                        if let medicines = groupedMedicines[key] {
                            
                            Section {
                                VStack(spacing: 12) {
                                    
                                    let sorted = sortedByTime(medicines)

                                    ForEach(sorted) { medicine in
                                        medicineRow(medicine, allMedicines: sorted)
                                    }
                                    
                                }
                                .padding(.vertical, 8)
                            } header: {
                                Text(key)
                                    .font(.headline)
                            }
                        }
                    }
                }
                .navigationTitle("Medicines")
                
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
                    AddMedicineListView()
                }
            }
        }
        .onAppear {
            requestNotificationPermission()
        }
        .onReceive(timer) { input in
            currentTime = input
        }
    }
    
    private func sortValue(for date: Date) -> (Int, Int) {
        let interval = date.timeIntervalSince(currentTime)
        
        let isPast = interval < 0 ? 1 : 0
        let distance = Int(abs(interval))
        
        return (isPast, distance)
    }
    
    private var sortedGroupKeys: [String] {
        groupedMedicines.keys.sorted { key1, key2 in
            
            guard
                let meds1 = groupedMedicines[key1],
                let meds2 = groupedMedicines[key2],
                let closest1 = meds1.min(by: { sortValue(for: $0.medicineTimes) < sortValue(for: $1.medicineTimes) }),
                let closest2 = meds2.min(by: { sortValue(for: $0.medicineTimes) < sortValue(for: $1.medicineTimes) })
            else {
                return false
            }
            
            return sortValue(for: closest1.medicineTimes)
                 < sortValue(for: closest2.medicineTimes)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private func canBeTaken(
        _ medicine: MediciplineItem,
        allMedicines: [MediciplineItem]
    ) -> Bool {
        
        guard let index = allMedicines.firstIndex(where: { $0.id == medicine.id }) else {
            return false
        }
        
        let timePassed = isTimePassed(medicine)
        
        if index == 0 {
            return timePassed
        } else {
            let previousTaken = allMedicines[index - 1].isTaken
            return previousTaken && timePassed
        }
    }
    
    private func isTimePassed(_ medicine: MediciplineItem) -> Bool {
        let calendar = Calendar.current
        
        let nowHour = calendar.component(.hour, from: currentTime)
        let nowMinute = calendar.component(.minute, from: currentTime)
        
        let medHour = calendar.component(.hour, from: medicine.medicineTimes)
        let medMinute = calendar.component(.minute, from: medicine.medicineTimes)
        
        let nowTotal = nowHour * 60 + nowMinute
        let medTotal = medHour * 60 + medMinute
        
        return nowTotal >= medTotal
    }
    
    private var groupedMedicines: [String: [MediciplineItem]] {
        Dictionary(grouping: medicineList) { medicine in
            medicine.medicineName.joined(separator: ", ")
        }
    }
    
//    private func sortedByTime(_ medicines: [MediciplineItem]) -> [MediciplineItem] {
//        medicines.sorted {
//            $0.medicineTimes < $1.medicineTimes
//        }
//    }
    private func sortedByTime(_ medicines: [MediciplineItem]) -> [MediciplineItem] {
        medicines.sorted { a, b in
            
            // 1️⃣ Not taken comes first
            if a.isTaken != b.isTaken {
                return !a.isTaken && b.isTaken
            }
            
            // 2️⃣ If same state → sort by time
            return a.medicineTimes < b.medicineTimes
        }
    }
    
    @ViewBuilder
    private func medicineRow(
        _ medicine: MediciplineItem,
        allMedicines: [MediciplineItem]
    ) -> some View {
        
        let unlocked = canBeTaken(medicine, allMedicines: allMedicines)
        
        HStack {
            
            VStack(alignment: .leading, spacing: 4) {

                Text(medicine.medicineTimes.formatted(date: .omitted, time: .shortened))
                    .font(.headline)

                Text(medicine.medicineName.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text(medicine.isBeforeAndAfterEat ? "After Meal" : "Before Meal")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button {
                if unlocked {
                    medicine.isTaken.toggle()
                    try? context.save()
                }
            } label: {
                Image(systemName: medicine.isTaken ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(medicine.isTaken ? .green : (unlocked ? .blue : .gray))
                    .font(.title2)
            }
            /*disabled(!unlocked)*/
            .disabled(!unlocked || medicine.isTaken)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .opacity(medicine.isTaken ? 0.4 : (unlocked ? 1.0 : 0.5))
        .strikethrough(medicine.isTaken)
    }
}

//#Preview {
//    ContentView()
//        .modelContainer(for: MediciplineItem.self, inMemory: true)
//}
