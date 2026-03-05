import SwiftUI
import SwiftData
import PhotosUI
import UIKit
import AVFoundation

struct CompleteChallengeView: View {
    enum EvidenceInputMode: String, CaseIterable {
        case text = "Texto"
        case voice = "Voz"
        case media = "Media"
    }

    private static let maxVoiceSeconds: Double = 30

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let challenge: ChallengeCatalog.Challenge
    let assignment: DailyAssignment?

    // Nota: por ahora el campo visibility de JournalEntry se conserva (legacy),
    // pero ya no lo exponemos en UI. La salida (share/export) es una acción.
    @State private var mode: EvidenceInputMode = .text

    // Grid editorial: texto (columna derecha) + caption (pie).
    @State private var layoutText: String = ""
    @State private var layoutCaption: String = ""

    @StateObject private var voiceRecorder = VoiceRecorder(maxDurationSeconds: Self.maxVoiceSeconds)

    // Media (Sprint 2): foto desde librería (PhotosPicker) o desde cámara.
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    @State private var isCameraSheetPresented: Bool = false

    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SJ.Spacing.lg) {
                header

                // “Página” editorial (grid 8x8). Pills flotan encima.
                ZStack(alignment: .bottomLeading) {
                    EvidenceLayoutCanvas(
                        template: templateForMode,
                        text: $layoutText,
                        caption: $layoutCaption,
                        selectedPhotoItem: $selectedPhotoItem,
                        selectedPhotoData: $selectedPhotoData,
                        onTakePhoto: {
                            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                                errorMessage = "Esta device no tiene cámara disponible (o estás en el simulador)."
                                return
                            }
                            errorMessage = nil
                            isCameraSheetPresented = true
                        },
                        voiceRecorder: voiceRecorder
                    )

                    // Pills flotantes (no debajo del grid)
                    HStack(spacing: 8) {
                        pill("Texto", isSelected: mode == .text) { mode = .text }
                        pill("Voz", isSelected: mode == .voice) { mode = .voice }
                        pill("Media", isSelected: mode == .media) { mode = .media }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(SJ.Palette.bg.opacity(0.92))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(SJ.Palette.hairline, lineWidth: 1)
                            )
                    )
                    .padding(12)
                }
                .frame(minHeight: 620)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, SJ.Spacing.md)
            .padding(.top, SJ.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
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
            }
            .padding(.horizontal, SJ.Spacing.md)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(SJ.Palette.bg.opacity(0.98))
            .overlay(alignment: .top) {
                Rectangle().fill(SJ.Palette.hairline).frame(height: 1)
            }
        }
        .background(SJ.Palette.bg)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isCameraSheetPresented) {
            CameraPicker {
                // Convertimos a JPEG (calidad 0.9). En el futuro: downscale + compresión.
                if let data = $0.jpegData(compressionQuality: 0.9) {
                    selectedPhotoData = data
                    selectedPhotoItem = nil
                } else {
                    errorMessage = "No se pudo procesar la foto."
                }
                isCameraSheetPresented = false
            } onCancel: {
                isCameraSheetPresented = false
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue else {
                // Nota: no limpiamos selectedPhotoData aquí porque puede venir de la cámara.
                return
            }
            Task {
                // Nota: Data puede ser pesado; en el futuro conviene downscale/compresión.
                selectedPhotoData = try? await newValue.loadTransferable(type: Data.self)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SJ.Spacing.sm) {
            Text(challenge.prompt)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundStyle(SJ.Palette.ink)

            Rectangle().fill(SJ.Palette.hairline).frame(height: 1)
        }
    }




    private var templateForMode: EvidenceLayoutTemplate {
        switch mode {
        case .media:
            return .swissDefault
        case .voice:
            return .swissVoiceText
        case .text:
            return .swissTextOnly
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
        errorMessage = nil

        // En este MVP el grid tiene texto (columna derecha) + caption (pie).
        // Consolidamos ambos a Evidence.text (Markdown simple) por ahora.
        let t = layoutText.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = layoutCaption.trimmingCharacters(in: .whitespacesAndNewlines)
        let combined = [t.isEmpty ? nil : t, c.isEmpty ? nil : "—\n\(c)"].compactMap { $0 }.joined(separator: "\n\n")
        let evidenceText: String? = combined.isEmpty ? nil : combined

        // Validación mínima por modo
        switch mode {
        case .text:
            guard evidenceText != nil else {
                errorMessage = "Deja aunque sea una línea para recordar tu día."
                return
            }
        case .media:
            guard selectedPhotoData != nil || evidenceText != nil else {
                errorMessage = "Agrega una foto o escribe una línea (con eso basta)."
                return
            }
        case .voice:
            guard voiceRecorder.recordedTempURL != nil || evidenceText != nil else {
                errorMessage = "Graba una nota de voz (hasta 30s) o escribe una línea."
                return
            }
        }

        do {
            let appDay = assignment?.appDay ?? AppDay.isoDayString(from: .now)

            let entry = JournalEntry(appDay: appDay, challengeId: challenge.id, visibility: .private, note: nil)
            modelContext.insert(entry)

            let ev = Evidence(entryId: entry.id, text: evidenceText)
            modelContext.insert(ev)

            if mode == .media, let data = selectedPhotoData {
                // Guardamos archivo local y persistimos solo metadata.
                let relativePath = try EvidenceMediaStore.savePhotoData(data, evidenceId: ev.id, preferredExtension: "jpg")
                let attachment = EvidenceAttachment(evidenceId: ev.id, kind: .photo, relativePath: relativePath)
                modelContext.insert(attachment)
            }

            if mode == .voice, let audioURL = voiceRecorder.recordedTempURL {
                let relativePath = try EvidenceMediaStore.saveFile(from: audioURL, evidenceId: ev.id, preferredExtension: "m4a")
                let attachment = EvidenceAttachment(
                    evidenceId: ev.id,
                    kind: .audio,
                    relativePath: relativePath,
                    duration: voiceRecorder.durationSeconds
                )
                modelContext.insert(attachment)
            }

            let unlock = BadgeUnlock(badgeId: challenge.badgeId, challengeId: challenge.id)
            modelContext.insert(unlock)

            try modelContext.save()
            if mode == .voice {
                voiceRecorder.reset()
            }
            dismiss()
        } catch {
            errorMessage = String(describing: error)
        }
    }
}

// MARK: - Evidence Preview (Editorial)

private struct SJEvidenceTextPreview: View {
    let text: String

    var body: some View {
        SJCard(level: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("PREVIEW")
                    .font(SJ.Typography.caption())
                    .tracking(1.2)
                    .foregroundStyle(SJ.Palette.mutedInk)

                SJAutoFitText(text: text)
            }
        }
    }
}

private struct SJEvidenceVoicePreview: View {
    let durationSeconds: Double
    let isPlaying: Bool
    let maxSeconds: Double

    var body: some View {
        SJCard(level: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("PREVIEW")
                    .font(SJ.Typography.caption())
                    .tracking(1.2)
                    .foregroundStyle(SJ.Palette.mutedInk)

                HStack(spacing: 10) {
                    Image(systemName: isPlaying ? "speaker.wave.2" : "waveform")
                        .foregroundStyle(SJ.Palette.ink)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nota de voz")
                            .font(SJ.Typography.body())
                            .foregroundStyle(SJ.Palette.ink)
                        Text("\(format(durationSeconds)) / \(Int(maxSeconds))s")
                            .font(.footnote)
                            .foregroundStyle(SJ.Palette.mutedInk)
                    }

                    Spacer(minLength: 0)

                    Rectangle()
                        .fill(SJ.Palette.hairline)
                        .frame(width: 1)

                    Text("AUDIO")
                        .font(SJ.Typography.caption())
                        .tracking(1.2)
                        .foregroundStyle(SJ.Palette.mutedInk)
                }
            }
        }
    }

    private func format(_ seconds: Double) -> String {
        let s = max(0, Int(seconds.rounded()))
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

private struct SJEvidenceImagePreview: View {
    let image: UIImage

    var body: some View {
        SJCard(level: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("PREVIEW")
                    .font(SJ.Typography.caption())
                    .tracking(1.2)
                    .foregroundStyle(SJ.Palette.mutedInk)

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                            .stroke(SJ.Palette.hairline, lineWidth: 1)
                    )
            }
        }
    }
}

/// Texto en caja fija, con auto-fit por escalones (estilo editorial).
private struct SJAutoFitText: View {
    let text: String

    var body: some View {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        RoundedRectangle(cornerRadius: SJ.Radius.sm, style: .continuous)
            .fill(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: SJ.Radius.sm, style: .continuous)
                    .stroke(SJ.Palette.hairline, lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                ViewThatFits(in: .vertical) {
                    fittedText(trimmed, size: 18, lineSpacing: 3)
                    fittedText(trimmed, size: 16, lineSpacing: 2.5)
                    fittedText(trimmed, size: 14, lineSpacing: 2)
                    fittedText(trimmed, size: 13, lineSpacing: 1.5)
                }
                .padding(12)
            }
            .frame(height: 140)
    }

    private func fittedText(_ t: String, size: CGFloat, lineSpacing: CGFloat) -> some View {
        Text(t)
            .font(.system(size: size, weight: .regular, design: .default))
            .foregroundStyle(SJ.Palette.ink)
            .lineSpacing(lineSpacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Camera Picker (SwiftUI wrapper)

/// SwiftUI wrapper alrededor de UIImagePickerController para usar la cámara.
/// MVP: solo foto (no video). Retorna UIImage.
struct CameraPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController

    let onImage: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // no-op
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onImage: onImage, onCancel: onCancel)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let onImage: (UIImage) -> Void
        private let onCancel: () -> Void

        init(onImage: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onImage = onImage
            self.onCancel = onCancel
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onImage(image)
            } else {
                onCancel()
            }
        }
    }
}
