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

enum EvidenceType: String, Codable, CaseIterable {
    case text
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

@Model
final class Evidence {
    var id: UUID
    var entryId: UUID
    var typeRaw: String
    var text: String?
    var filePath: String?
    var createdAt: Date

    init(entryId: UUID, type: EvidenceType, text: String? = nil, filePath: String? = nil, createdAt: Date = .now) {
        self.id = UUID()
        self.entryId = entryId
        self.typeRaw = type.rawValue
        self.text = text
        self.filePath = filePath
        self.createdAt = createdAt
    }

    var type: EvidenceType {
        get { EvidenceType(rawValue: typeRaw) ?? .text }
        set { typeRaw = newValue.rawValue }
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
