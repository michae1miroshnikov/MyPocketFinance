//
//  testBApp.swift
//  testB
//
//  Created by Michael Miroshnikov on 21/03/2025.
//

import SwiftUI

@main
struct testBApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
