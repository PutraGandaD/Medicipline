//
//  MediciplineApp.swift
//  Medicipline
//
//  Created by Putra Ganda Dewata on 03/03/26.
//

import SwiftUI
import SwiftData

@main
struct MediciplineApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MediciplineItem.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier("group.com.putragandad.Medicipline")
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create shared container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
