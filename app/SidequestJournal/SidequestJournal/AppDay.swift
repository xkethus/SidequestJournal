import Foundation

enum AppDay {
    /// Retorna el appDay (YYYY-MM-DD) para un timestamp dado, usando la hora de reset.
    static func key(for date: Date = .now, resetHour: Int, resetMinute: Int, calendar: Calendar = .current) -> String {
        var cal = calendar
        cal.locale = Locale(identifier: "es_MX")
        cal.timeZone = .current

        // Construimos el "inicio de appDay" del día calendario actual.
        let startOfCalendarDay = cal.startOfDay(for: date)
        guard let resetToday = cal.date(byAdding: DateComponents(hour: resetHour, minute: resetMinute), to: startOfCalendarDay) else {
            return isoDayString(from: date, calendar: cal)
        }

        // Si estamos antes del reset, pertenecemos al appDay de ayer.
        let effectiveDate = (date < resetToday) ? cal.date(byAdding: .day, value: -1, to: date)! : date
        return isoDayString(from: effectiveDate, calendar: cal)
    }

    static func isoDayString(from date: Date, calendar: Calendar = .current) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 1970
        let m = comps.month ?? 1
        let d = comps.day ?? 1
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    static func parse(_ appDay: String) -> Date? {
        let parts = appDay.split(separator: "-").map(String.init)
        guard parts.count == 3,
              let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2])
        else { return nil }
        var cal = Calendar.current
        cal.timeZone = .current
        return cal.date(from: DateComponents(year: y, month: m, day: d))
    }
}
