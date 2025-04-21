//
//  SavedStock.swift
//  testB
//
//  Created by Michael Miroshnikov on 08/04/2025.
//

// SavedStock.swift
import Foundation

struct SavedStock: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    var customName: String
}
