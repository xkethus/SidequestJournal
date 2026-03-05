import Foundation

/// Grid editorial 8x8 (coordenadas en celdas).
struct EvidenceGridRect: Equatable, Codable {
    var x: Int
    var y: Int
    var w: Int
    var h: Int
}

enum EvidenceBlockKind: String, Codable, CaseIterable {
    case photo
    case audio
    case text
    case caption
    case spacer
}

struct EvidenceBlock: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var kind: EvidenceBlockKind
    var rect: EvidenceGridRect
}

/// Template editorial: conjunto de bloques dentro del grid 8x8.
struct EvidenceLayoutTemplate: Identifiable, Equatable, Codable {
    var id: String
    var name: String
    var blocks: [EvidenceBlock]

    /// Template Swiss Default (Sprint): FOTO + PIE. Nada más.
    static let swissDefault = EvidenceLayoutTemplate(
        id: "swiss-default",
        name: "Swiss Default",
        blocks: [
            // Foto hero ocupando casi toda la página
            EvidenceBlock(kind: .photo, rect: EvidenceGridRect(x: 0, y: 0, w: 8, h: 6)),
            // Pie editorial abajo (2 filas)
            EvidenceBlock(kind: .caption, rect: EvidenceGridRect(x: 0, y: 6, w: 8, h: 2)),
        ]
    )

    /// Template Texto grande: TEXTO grande. Sin pie.
    static let swissTextOnly = EvidenceLayoutTemplate(
        id: "swiss-text-only",
        name: "Swiss Text",
        blocks: [
            EvidenceBlock(kind: .text, rect: EvidenceGridRect(x: 0, y: 0, w: 8, h: 8)),
        ]
    )

    /// Template Voz+Texto: TEXTO grande + AUDIO minimal. Sin pie.
    static let swissVoiceText = EvidenceLayoutTemplate(
        id: "swiss-voice-text",
        name: "Swiss Voice+Text",
        blocks: [
            EvidenceBlock(kind: .text, rect: EvidenceGridRect(x: 0, y: 0, w: 8, h: 6)),
            EvidenceBlock(kind: .audio, rect: EvidenceGridRect(x: 0, y: 6, w: 8, h: 2)),
        ]
    )

    static let all: [EvidenceLayoutTemplate] = [
        .swissDefault,
        .swissTextOnly,
        .swissVoiceText,
    ]
}
