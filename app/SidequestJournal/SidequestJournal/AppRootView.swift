import SwiftUI

struct AppRootView: View {
    @StateObject private var catalogStore = CatalogStore()

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Hoy", systemImage: "sparkles") }

            JournalListView()
                .tabItem { Label("Journal", systemImage: "book.closed") }

            BadgesView()
                .tabItem { Label("Medallas", systemImage: "seal") }

            SettingsView()
                .tabItem { Label("Ajustes", systemImage: "gearshape") }
        }
        .environmentObject(catalogStore)
        .task { catalogStore.loadIfNeeded() }
    }
}
