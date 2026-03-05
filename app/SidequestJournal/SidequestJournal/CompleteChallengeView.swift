import SwiftUI
import SwiftData
import PhotosUI
import UIKit

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

    // Media (Sprint 2): foto desde librería (PhotosPicker) o desde cámara.
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    @State private var isCameraSheetPresented: Bool = false

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
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Foto")
                                    .font(SJ.Typography.headline())

                                HStack(spacing: 10) {
                                    Button {
                                        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                                            errorMessage = "Esta device no tiene cámara disponible (o estás en el simulador)."
                                            return
                                        }
                                        errorMessage = nil
                                        isCameraSheetPresented = true
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "camera")
                                            Text("Tomar foto")
                                        }
                                    }
                                    .buttonStyle(SJLinkCTAStyle(level: 1))

                                    PhotosPicker(
                                        selection: $selectedPhotoItem,
                                        matching: .images,
                                        photoLibrary: .shared()
                                    ) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "photo")
                                            Text(selectedPhotoData == nil ? "Elegir foto" : "Cambiar foto")
                                        }
                                    }
                                    .buttonStyle(SJLinkCTAStyle(level: 1))

                                    Spacer(minLength: 0)
                                }

                                if let selectedPhotoData,
                                   let uiImage = UIImage(data: selectedPhotoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                                                .stroke(SJ.Palette.hairline, lineWidth: 1)
                                        )
                                } else {
                                    Text("Selecciona una foto para guardarla como evidencia local.")
                                        .font(.footnote)
                                        .foregroundStyle(SJ.Palette.mutedInk)
                                }

                                // Nota: permitimos texto opcional también.
                                TextField("Texto opcional…", text: $textEvidence, axis: .vertical)
                                    .lineLimit(2...6)
                                    .textFieldStyle(.roundedBorder)
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

        let trimmed = textEvidence.trimmingCharacters(in: .whitespacesAndNewlines)
        let evidenceText: String? = trimmed.isEmpty ? nil : trimmed

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
            errorMessage = "La evidencia por voz todavía no está lista. Usa Texto o Media por ahora."
            return
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

            let unlock = BadgeUnlock(badgeId: challenge.badgeId, challengeId: challenge.id)
            modelContext.insert(unlock)

            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = String(describing: error)
        }
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
