import Foundation
import SwiftData

@Model
final class AppSettings {
    /// Hora/minuto en los que empieza el “día de la app” (default sugerido 07:00)
    var dailyResetHour: Int
    var dailyResetMinute: Int

    init(dailyResetHour: Int = 7, dailyResetMinute: Int = 0) {
        self.dailyResetHour = dailyResetHour
        self.dailyResetMinute = dailyResetMinute
    }
}

@Model
final class DailyAssignment {
    /// Clave del “día de la app” en formato YYYY-MM-DD
    var appDay: String
    var challengeId: String
    var assignedAt: Date

    init(appDay: String, challengeId: String, assignedAt: Date = .now) {
        self.appDay = appDay
        self.challengeId = challengeId
        self.assignedAt = assignedAt
    }
}

enum EntryVisibility: String, Codable, CaseIterable {
    case `private`
    case `public`
}

enum EvidenceAttachmentKind: String, Codable, CaseIterable {
    case photo
    case video
    case audio
}

@Model
final class JournalEntry {
    var id: UUID
    var appDay: String
    var challengeId: String
    var createdAt: Date

    /// MVP legacy (por ahora se conserva, pero ya no se expone en UI).
    var visibilityRaw: String

    var note: String?

    init(appDay: String, challengeId: String, createdAt: Date = .now, visibility: EntryVisibility = .private, note: String? = nil) {
        self.id = UUID()
        self.appDay = appDay
        self.challengeId = challengeId
        self.createdAt = createdAt
        self.visibilityRaw = visibility.rawValue
        self.note = note
    }

    var visibility: EntryVisibility {
        get { EntryVisibility(rawValue: visibilityRaw) ?? .private }
        set { visibilityRaw = newValue.rawValue }
    }
}

/// Evidencia = contenedor (texto opcional) + adjuntos (0..n) guardados como archivos locales.
/// Nota: guardamos solo metadata en SwiftData; los binarios viven en Application Support.
@Model
final class Evidence {
    var id: UUID
    var entryId: UUID
    var text: String?
    var createdAt: Date

    init(entryId: UUID, text: String? = nil, createdAt: Date = .now) {
        self.id = UUID()
        self.entryId = entryId
        self.text = text
        self.createdAt = createdAt
    }
}

/// Un adjunto de evidencia (foto / video / audio). El contenido vive como archivo local.
@Model
final class EvidenceAttachment {
    var id: UUID
    var evidenceId: UUID

    var kindRaw: String

    /// Path relativo dentro del sandbox (resolver contra Application Support/EvidenceMedia).
    var relativePath: String

    var createdAt: Date

    /// Duración para audio/video (segundos).
    var duration: Double?

    /// Thumbnail opcional para video (path relativo).
    var thumbnailRelativePath: String?

    init(
        evidenceId: UUID,
        kind: EvidenceAttachmentKind,
        relativePath: String,
        createdAt: Date = .now,
        duration: Double? = nil,
        thumbnailRelativePath: String? = nil
    ) {
        self.id = UUID()
        self.evidenceId = evidenceId
        self.kindRaw = kind.rawValue
        self.relativePath = relativePath
        self.createdAt = createdAt
        self.duration = duration
        self.thumbnailRelativePath = thumbnailRelativePath
    }

    var kind: EvidenceAttachmentKind {
        get { EvidenceAttachmentKind(rawValue: kindRaw) ?? .photo }
        set { kindRaw = newValue.rawValue }
    }
}

@Model
final class BadgeUnlock {
    var badgeId: String
    var challengeId: String
    var unlockedAt: Date

    init(badgeId: String, challengeId: String, unlockedAt: Date = .now) {
        self.badgeId = badgeId
        self.challengeId = challengeId
        self.unlockedAt = unlockedAt
    }
}
