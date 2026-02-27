import SwiftUI
import SwiftData

struct CompleteChallengeView: View {
    enum EvidenceInputMode: String, CaseIterable {
        case text = "Texto"
        case voice = "Voz"
        case media = "Media"
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let challenge: ChallengeCatalog.Challenge
    let assignment: DailyAssignment?

    // Nota: por ahora el campo visibility de JournalEntry se conserva (legacy),
    // pero ya no lo exponemos en UI. La salida (share/export) es una acción.
    @State private var mode: EvidenceInputMode = .text
    @State private var textEvidence: String = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SJ.Spacing.lg) {
                header

                SJCard(level: 0) {
                    VStack(alignment: .leading, spacing: SJ.Spacing.sm) {
                        // Pills (switch de tipo de huella)
                        HStack(spacing: 8) {
                            pill("Texto", isSelected: mode == .text) { mode = .text }
                            pill("Voz", isSelected: mode == .voice) { mode = .voice }
                            pill("Media", isSelected: mode == .media) { mode = .media }
                            Spacer(minLength: 0)
                        }

                        switch mode {
                        case .text:
                            TextEditor(text: $textEvidence)
                                .frame(minHeight: 170)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: SJ.Radius.sm, style: .continuous)
                                        .stroke(SJ.Palette.hairline, lineWidth: 1)
                                )

                        case .voice:
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Nota de voz")
                                    .font(SJ.Typography.headline())
                                Text("Próximo: grabar y guardar audio en tu journal (local en el iPhone).")
                                    .font(.footnote)
                                    .foregroundStyle(SJ.Palette.mutedInk)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                        case .media:
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Imagen o video")
                                    .font(SJ.Typography.headline())
                                Text("Próximo: seleccionar (o capturar) imagen/video y guardarlo local.")
                                    .font(.footnote)
                                    .foregroundStyle(SJ.Palette.mutedInk)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button {
                    save()
                } label: {
                    HStack(spacing: 8) {
                        Text("Guardar")
                        Image(systemName: "checkmark")
                    }
                }
                .buttonStyle(SJLinkCTAStyle(level: 2))

                Spacer(minLength: 24)
            }
            .padding(.horizontal, SJ.Spacing.md)
            .padding(.top, SJ.Spacing.md)
        }
        .background(SJ.Palette.bg)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SJ.Spacing.sm) {
            Text(challenge.prompt)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundStyle(SJ.Palette.ink)

            Rectangle().fill(SJ.Palette.hairline).frame(height: 1)
        }
    }

    private func pill(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(SJ.Typography.caption())
                .tracking(1.2)
                .foregroundStyle(isSelected ? SJ.Palette.ink : SJ.Palette.mutedInk)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? SJ.Palette.accentGradient(for: 2) : SJ.Palette.accentGradient(for: 0))
                )
                .overlay(
                    Capsule().stroke(SJ.Palette.hairline, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func save() {
        // Por ahora: solo texto es funcional.
        let trimmed = textEvidence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Deja aunque sea una línea para recordar tu día."
            return
        }

        do {
            let appDay = assignment?.appDay ?? AppDay.isoDayString(from: .now)

            let entry = JournalEntry(appDay: appDay, challengeId: challenge.id, visibility: .private, note: nil)
            modelContext.insert(entry)

            let ev = Evidence(entryId: entry.id, text: trimmed)
            modelContext.insert(ev)

            let unlock = BadgeUnlock(badgeId: challenge.badgeId, challengeId: challenge.id)
            modelContext.insert(unlock)

            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = String(describing: error)
        }
    }
}
