import SwiftUI
import PhotosUI
import UIKit

/// Canvas editorial tipo “página de journal” con grid 8x8.
/// MVP: template fijo (swiss default), sin drag. Bloques editables: foto, texto, caption, audio.
struct EvidenceLayoutCanvas: View {
    let template: EvidenceLayoutTemplate

    @Binding var text: String
    @Binding var caption: String

    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var selectedPhotoData: Data?

    let onTakePhoto: () -> Void

    @ObservedObject var voiceRecorder: VoiceRecorder

    @State private var isTextEditorPresented: Bool = false
    @State private var isCaptionEditorPresented: Bool = false

    var body: some View {
        GeometryReader { geo in
            // “Página”: 4:5 (tipo journal)
            let pageWidth = geo.size.width
            let pageHeight = min(geo.size.height, pageWidth * 1.25)

            VStack {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                        .fill(SJ.Palette.bg)
                        .overlay(
                            RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                                .stroke(SJ.Palette.hairline, lineWidth: 1)
                        )

                    // Content blocks
                    ForEach(template.blocks) { block in
                        blockView(block)
                            .frame(
                                width: cellWidth(in: pageWidth) * CGFloat(block.rect.w),
                                height: cellHeight(in: pageHeight) * CGFloat(block.rect.h)
                            )
                            .offset(
                                x: cellWidth(in: pageWidth) * CGFloat(block.rect.x),
                                y: cellHeight(in: pageHeight) * CGFloat(block.rect.y)
                            )
                            .clipped()
                    }
                }
                .frame(width: pageWidth, height: pageHeight)

                Spacer(minLength: 0)
            }
        }
        .sheet(isPresented: $isTextEditorPresented) {
            SJTextEditSheet(title: "Texto", placeholder: "Escribe…", text: $text)
        }
        .sheet(isPresented: $isCaptionEditorPresented) {
            SJCaptionEditSheet(caption: $caption)
        }
    }

    // MARK: - Block Rendering

    @ViewBuilder
    private func blockView(_ block: EvidenceBlock) -> some View {
        switch block.kind {
        case .photo:
            photoBlock
        case .text:
            textBlock
        case .caption:
            captionBlock
        case .audio:
            audioBlock
        case .spacer:
            Color.clear
        }
    }

    private var photoBlock: some View {
        ZStack {
            if let data = selectedPhotoData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Button(action: onTakePhoto) {
                            Image(systemName: "camera")
                        }
                        .buttonStyle(SJLinkCTAStyle(level: 1))

                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "photo")
                        }
                        .buttonStyle(SJLinkCTAStyle(level: 1))
                    }

                    Text("Añade una foto")
                        .font(.footnote)
                        .foregroundStyle(SJ.Palette.mutedInk)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                .stroke(SJ.Palette.hairline, lineWidth: 1)
        )
    }

    private var textBlock: some View {
        Button {
            isTextEditorPresented = true
        } label: {
            ZStack(alignment: .topLeading) {
                SJAutoFitTextBox(text: text.isEmpty ? " " : text, height: nil)

                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Toca para escribir")
                        .font(.footnote)
                        .foregroundStyle(SJ.Palette.mutedInk)
                        .padding(12)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .buttonStyle(.plain)
    }

    private var captionBlock: some View {
        Button {
            isCaptionEditorPresented = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                if caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Toca para escribir pie de foto")
                        .font(.footnote)
                        .foregroundStyle(SJ.Palette.mutedInk)
                } else {
                    ViewThatFits(in: .vertical) {
                        Text(caption)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(SJ.Palette.ink)
                            .lineSpacing(2)

                        Text(caption)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(SJ.Palette.ink)
                            .lineSpacing(1.5)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .buttonStyle(.plain)
    }

    private var audioBlock: some View {
        HStack(spacing: 12) {
            Button {
                switch voiceRecorder.state {
                case .idle, .recorded:
                    voiceRecorder.startRecording()
                case .recording:
                    voiceRecorder.stopRecording()
                case .playing:
                    voiceRecorder.togglePlayback()
                }
            } label: {
                Image(systemName: voiceRecorder.state == .recording ? "stop.circle.fill" : "mic.circle.fill")
            }
            .buttonStyle(SJLinkCTAStyle(level: 1))

            Button {
                voiceRecorder.togglePlayback()
            } label: {
                Image(systemName: voiceRecorder.state == .playing ? "pause.circle" : "play.circle")
            }
            .buttonStyle(SJLinkCTAStyle(level: 1))
            .disabled(voiceRecorder.state != .recorded && voiceRecorder.state != .playing)

            Text("\(format(voiceRecorder.durationSeconds)) / 0:30")
                .font(.footnote)
                .foregroundStyle(SJ.Palette.mutedInk)

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                .stroke(SJ.Palette.hairline, lineWidth: 1)
        )
    }

    // MARK: - Grid math

    private func cellWidth(in pageWidth: CGFloat) -> CGFloat {
        pageWidth / 8
    }

    private func cellHeight(in pageHeight: CGFloat) -> CGFloat {
        pageHeight / 8
    }

    private func format(_ seconds: Double) -> String {
        let s = max(0, Int(seconds.rounded()))
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - Sheets (Preview limpio → Edit)

private struct SJTextEditSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .font(.system(size: 16))

                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                }
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                        .stroke(SJ.Palette.hairline, lineWidth: 1)
                )

                Spacer(minLength: 0)
            }
            .padding(16)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}

private struct SJCaptionEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var caption: String

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Pie de foto…", text: $caption, axis: .vertical)
                    .lineLimit(2...6)
                    .textFieldStyle(.roundedBorder)

                Spacer(minLength: 0)
            }
            .padding(16)
            .navigationTitle("Pie de foto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}
