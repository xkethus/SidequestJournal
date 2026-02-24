import Foundation
import SwiftData

final class DailyAssignmentService {
    /// Obtiene o crea el reto asignado al appDay actual.
    func getOrCreateAssignment(catalog: ChallengeCatalog, modelContext: ModelContext, settings: AppSettings, now: Date = .now) throws -> DailyAssignment {
        let appDay = AppDay.key(for: now, resetHour: settings.dailyResetHour, resetMinute: settings.dailyResetMinute)

        let existing = try fetchAssignment(appDay: appDay, modelContext: modelContext)
        if let existing { return existing }

        let chosen = try chooseChallenge(catalog: catalog, modelContext: modelContext, appDay: appDay)
        let assignment = DailyAssignment(appDay: appDay, challengeId: chosen.id, assignedAt: now)
        modelContext.insert(assignment)
        try modelContext.save()
        return assignment
    }

    private func fetchAssignment(appDay: String, modelContext: ModelContext) throws -> DailyAssignment? {
        let descriptor = FetchDescriptor<DailyAssignment>(predicate: #Predicate { $0.appDay == appDay })
        return try modelContext.fetch(descriptor).first
    }

    private func chooseChallenge(catalog: ChallengeCatalog, modelContext: ModelContext, appDay: String) throws -> ChallengeCatalog.Challenge {
        let active = catalog.challenges.filter { $0.isActive }
        if active.isEmpty {
            throw NSError(domain: "DailyAssignmentService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No hay retos activos en el catálogo."])
        }

        // Traemos assignments recientes (últimos ~40 días) para anti-repetición 30 días.
        // Simplificación MVP: tomamos todos y filtramos por appDay string (YYYY-MM-DD) lexicográfico.
        let allAssignments = try modelContext.fetch(FetchDescriptor<DailyAssignment>())

        let recentChallengeIds = Set(allAssignments
            .filter { isWithinLastNDays(appDay: $0.appDay, referenceAppDay: appDay, n: 30) }
            .map { $0.challengeId })

        var candidates = active.filter { !recentChallengeIds.contains($0.id) }
        if candidates.isEmpty {
            // Fallback: si el pool se agotó, permitir cualquiera activa.
            candidates = active
        }

        return candidates.randomElement()!
    }

    private func isWithinLastNDays(appDay: String, referenceAppDay: String, n: Int) -> Bool {
        // MVP: parse YYYY-MM-DD a Date con Calendar.
        func parse(_ s: String) -> Date? {
            let parts = s.split(separator: "-").map(String.init)
            guard parts.count == 3,
                  let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2])
            else { return nil }
            var cal = Calendar.current
            cal.timeZone = .current
            return cal.date(from: DateComponents(year: y, month: m, day: d))
        }

        guard let a = parse(appDay), let r = parse(referenceAppDay) else { return false }
        let days = Calendar.current.dateComponents([.day], from: a, to: r).day ?? 9999
        return days >= 0 && days < n
    }
}
