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
    var medicineName: String
    var medicineFrequenciesTake: Int
    var addedMedicineDate: Date
    var isBeforeAndAfterEat: Bool
    
    init(
        medicineName: String,
        medicineFrequenciesTake: Int,
        addedMedicineDate: Date,
        isBeforeAndAfterEat: Bool
    ) {
        self.medicineName = medicineName
        self.medicineFrequenciesTake = medicineFrequenciesTake
        self.addedMedicineDate = addedMedicineDate
        self.isBeforeAndAfterEat = isBeforeAndAfterEat
    }
}
