//
//  Item.swift
//  Medicipline
//
//  Created by Putra Ganda Dewata on 03/03/26.
//

import Foundation
import SwiftData

@Model
final class MediciplineItem {
    var id: UUID
    var medicineName: [String]
    var medicineFrequenciesTake: Int
    var addedMedicineDate: Date
    var isBeforeAndAfterEat: Bool
    var medicineTimes: Date
    var isTaken: Bool = false
    // last modified
    
    init(
        id: UUID = UUID(),
        medicineName: [String],
        medicineFrequenciesTake: Int,
        addedMedicineDate: Date,
        isBeforeAndAfterEat: Bool,
        medicineTimes: Date,
        isTaken: Bool = false
    ) {
        self.id = id
        self.medicineName = medicineName
        self.medicineFrequenciesTake = medicineFrequenciesTake
        self.addedMedicineDate = addedMedicineDate
        self.isBeforeAndAfterEat = isBeforeAndAfterEat
        self.medicineTimes = medicineTimes
        self.isTaken = isTaken
    }
}
