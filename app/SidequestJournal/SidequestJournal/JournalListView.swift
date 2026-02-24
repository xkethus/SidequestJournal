import SwiftUI
import SwiftData

struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var catalogStore: CatalogStore
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries, id: \JournalEntry.id) { entry in
                    NavigationLink {
                        JournalEntryDetailView(entry: entry)
                    } label: {
                        JournalRow(entry: entry)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Journal")
            .task { catalogStore.loadIfNeeded() }
        }
    }

    private func delete(_ offsets: IndexSet) {
        for i in offsets {
            modelContext.delete(entries[i])
        }
        try? modelContext.save()
    }

    @ViewBuilder
    private func JournalRow(entry: JournalEntry) -> some View {
        let globalLevel = globalLevel(forCompletedCount: entries.count)
        let title = catalogStore.challengeTitle(for: entry.challengeId)

        VStack(alignment: .leading, spacing: SJ.Spacing.xs) {
            Text(title)
                .font(SJ.Typography.headline())
                .foregroundStyle(SJ.Palette.ink)

            HStack(spacing: SJ.Spacing.sm) {
                Text(entry.appDay)
                    .font(.footnote)
                    .foregroundStyle(SJ.Palette.mutedInk)

                SJChip(text: entry.visibility == .public ? "Pública" : "Privada", level: globalLevel)
            }
        }
        .padding(.vertical, 4)
    }

    private func globalLevel(forCompletedCount n: Int) -> Int {
        if n >= 30 { return 3 }
        if n >= 15 { return 2 }
        if n >= 5 { return 1 }
        return 0
    }
}
