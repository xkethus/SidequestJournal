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

    static let swissDefault = EvidenceLayoutTemplate(
        id: "swiss-default",
        name: "Swiss Default",
        blocks: [
            // Hero photo: 6x8 (izquierda) deja aire a la derecha
            EvidenceBlock(kind: .photo, rect: EvidenceGridRect(x: 0, y: 0, w: 6, h: 6)),

            // Texto (auto-fit) en columna derecha
            EvidenceBlock(kind: .text, rect: EvidenceGridRect(x: 6, y: 0, w: 2, h: 6)),

            // Caption / pie de foto: 8x2 abajo
            EvidenceBlock(kind: .caption, rect: EvidenceGridRect(x: 0, y: 6, w: 8, h: 2)),
        ]
    )
}
