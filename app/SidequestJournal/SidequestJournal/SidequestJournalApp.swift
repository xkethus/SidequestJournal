//
//  SidequestJournalApp.swift
//  SidequestJournal
//
//  Created by Enrique Hernandez Barrera on 22/02/26.
//

import SwiftUI
import SwiftData

@main
struct SidequestJournalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AppSettings.self,
            DailyAssignment.self,
            JournalEntry.self,
            Evidence.self,
            BadgeUnlock.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
