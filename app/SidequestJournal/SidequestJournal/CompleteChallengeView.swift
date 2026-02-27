import SwiftUI
import SwiftData

struct CompleteChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let challenge: ChallengeCatalog.Challenge
    let assignment: DailyAssignment?

    // Nota: por ahora el campo visibility de JournalEntry se conserva (legacy),
    // pero ya no lo exponemos en UI. La salida (share/export) es una acción.
    @State private var textEvidence: String = ""
    @State private var note: String = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SJ.Spacing.lg) {
                header

                SJCard(level: 0) {
                    VStack(alignment: .leading, spacing: SJ.Spacing.sm) {
                        Text("TU HUELLA")
                            .font(SJ.Typography.caption())
                            .tracking(2)
                            .foregroundStyle(SJ.Palette.mutedInk)

                        Text("Deja una nota, una foto o un audio. Es para ti.\nSi algún día quieres, puedes compartir tu journey.")
                            .font(.footnote)
                            .foregroundStyle(SJ.Palette.mutedInk)

                        Text("Texto")
                            .font(SJ.Typography.headline())

                        TextEditor(text: $textEvidence)
                            .frame(minHeight: 140)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: SJ.Radius.sm, style: .continuous)
                                    .stroke(SJ.Palette.hairline, lineWidth: 1)
                            )

                        Text("Adjuntos (próximo): foto / audio / video.")
                            .font(.footnote)
                            .foregroundStyle(SJ.Palette.mutedInk)
                    }
                }

                // VISIBILIDAD (MVP legacy)
                // Se conserva en modelo por compatibilidad, pero la UX ahora es:
                // evidencia = local por defecto; compartir/exportar es una acción explícita.

                SJCard(level: 0) {
                    VStack(alignment: .leading, spacing: SJ.Spacing.sm) {
                        Text("NOTA")
                            .font(SJ.Typography.caption())
                            .tracking(2)
                            .foregroundStyle(SJ.Palette.mutedInk)

                        TextField("¿Cómo te fue?", text: $note, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
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
            Text("COMPLETE")
                .font(SJ.Typography.caption())
                .tracking(2.2)
                .foregroundStyle(SJ.Palette.mutedInk)

            // Jerarquía: prompt manda (bold); title queda sutil como subtítulo.
            Text(challenge.title)
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundStyle(SJ.Palette.mutedInk)

            Text(challenge.prompt)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundStyle(SJ.Palette.ink)

            Rectangle().fill(SJ.Palette.hairline).frame(height: 1)
        }
    }

    private func save() {
        let trimmed = textEvidence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Deja aunque sea una línea para recordar tu día."
            return
        }

        do {
            let appDay = assignment?.appDay ?? AppDay.isoDayString(from: .now)

            // Por ahora seguimos requiriendo texto hasta que el UI de adjuntos esté activo.
            // (El modelo ya está listo para múltiples adjuntos en EvidenceAttachment.)
            let entry = JournalEntry(appDay: appDay, challengeId: challenge.id, visibility: .private, note: note.isEmpty ? nil : note)
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
