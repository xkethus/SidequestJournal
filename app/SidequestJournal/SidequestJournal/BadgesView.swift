import SwiftUI
import SwiftData

struct BadgesView: View {
    @EnvironmentObject private var catalogStore: CatalogStore
    @Query private var unlocks: [BadgeUnlock]
    @Query private var entries: [JournalEntry]

    var body: some View {
        NavigationStack {
            Group {
                if let err = catalogStore.errorMessage {
                    ContentUnavailableView("Catálogo no disponible", systemImage: "exclamationmark.triangle.fill", description: Text(err))
                } else if catalogStore.catalog == nil {
                    ProgressView("Cargando catálogo…")
                } else {
                    badgesList
                }
            }
            .navigationTitle("Medallas")
            .task { catalogStore.loadIfNeeded() }
        }
    }

    private var badgesList: some View {
        let catalog = catalogStore.catalog!
        let unlocked = Set(unlocks.map { $0.badgeId })
        let level = globalLevel(forCompletedCount: entries.count)

        let categories = catalog.categories.sorted { $0.order < $1.order }

        return List {
            Section {
                SJCard(level: level) {
                    VStack(alignment: .leading, spacing: SJ.Spacing.sm) {
                        Text("PROGRESO")
                            .font(SJ.Typography.caption())
                            .tracking(1.2)
                            .foregroundStyle(SJ.Palette.mutedInk)

                        Text("Nivel \(level)")
                            .font(SJ.Typography.title())

                        Text("Completados: \(entries.count) · Umbrales: 5 → Nivel 1, 15 → Nivel 2, 30 → Nivel 3")
                            .font(.footnote)
                            .foregroundStyle(SJ.Palette.mutedInk)
                    }
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                .listRowBackground(Color.clear)
            }

            ForEach(categories) { cat in
                let badges = catalog.badges.filter { $0.categoryId == cat.id }

                Section {
                    ForEach(badges) { b in
                        let isUnlocked = unlocked.contains(b.id)

                        HStack(spacing: 12) {
                            Image(systemName: b.icon)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(isUnlocked ? SJ.Palette.accent(for: level) : Color.gray)
                                .font(.title3)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(b.name)
                                    .font(SJ.Typography.headline())
                                Text(isUnlocked ? "Desbloqueada" : "Bloqueada")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                                .foregroundStyle(isUnlocked ? SJ.Palette.accent(for: level) : .secondary)
                        }
                        .opacity(isUnlocked ? 1.0 : 0.55)
                    }
                } header: {
                    HStack {
                        Text(cat.name)
                        Spacer()
                        Text("Nivel global \(level)")
                            .font(.footnote)
                            .foregroundStyle(SJ.Palette.accent(for: level))
                    }
                }
            }
        }
    }

    private func globalLevel(forCompletedCount n: Int) -> Int {
        if n >= 30 { return 3 }
        if n >= 15 { return 2 }
        if n >= 5 { return 1 }
        return 0
    }
}
