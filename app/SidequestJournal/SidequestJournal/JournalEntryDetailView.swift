import SwiftUI
import SwiftData

struct JournalEntryDetailView: View {
    @Environment(\.modelContext) private var modelContext

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
                Text("Evidencia: local (compartir es acción manual)")
                    .foregroundStyle(.secondary)
            }

            if let note = entry.note {
                Section("Nota") {
                    Text(note)
                }
            }

            Section("Evidencia") {
                if let ev = evidence.last {
                    if let text = ev.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(text)
                    } else {
                        Text("(Sin texto)")
                            .foregroundStyle(.secondary)
                    }

                    let atts = fetchAttachments(evidenceId: ev.id)
                    if !atts.isEmpty {
                        Divider()
                        ForEach(atts, id: \EvidenceAttachment.id) { att in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(att.kindRaw.uppercased())
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                Text(att.relativePath)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Text("Adjuntos: ninguno")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("(Aún no hay evidencia)")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(entry.appDay)
    }

    private func fetchAttachments(evidenceId: UUID) -> [EvidenceAttachment] {
        let descriptor = FetchDescriptor<EvidenceAttachment>(
            predicate: #Predicate { $0.evidenceId == evidenceId },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }
}
