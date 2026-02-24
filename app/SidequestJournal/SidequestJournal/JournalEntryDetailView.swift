import SwiftUI
import SwiftData

struct JournalEntryDetailView: View {
    let entry: JournalEntry

    @Query private var evidence: [Evidence]

    init(entry: JournalEntry) {
        self.entry = entry
        let id = entry.id
        _evidence = Query(
            filter: #Predicate<Evidence> { ev in
                ev.entryId == id
            },
            sort: \Evidence.createdAt
        )
    }

    var body: some View {
        Form {
            Section("Reto") {
                Text(entry.challengeId)
                Text("Visibilidad: \(entry.visibilityRaw)")
                    .foregroundStyle(.secondary)
            }

            if let note = entry.note {
                Section("Nota") {
                    Text(note)
                }
            }

            Section("Evidencia") {
                ForEach(evidence, id: \Evidence.id) { ev in
                    if ev.type == .text {
                        Text(ev.text ?? "")
                    } else {
                        Text("\(ev.typeRaw) (Sprint 2)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(entry.appDay)
    }
}
