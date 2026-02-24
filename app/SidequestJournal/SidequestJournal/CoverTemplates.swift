import Foundation
import SwiftUI

enum CoverTemplate: Int, CaseIterable {
    case a = 0
    case b = 1
    case c = 2
    case d = 3

    var code: String {
        switch self {
        case .a: return "A"
        case .b: return "B"
        case .c: return "C"
        case .d: return "D"
        }
    }

    static func from(code: String?) -> CoverTemplate? {
        switch code?.uppercased() {
        case "A": return .a
        case "B": return .b
        case "C": return .c
        case "D": return .d
        default: return nil
        }
    }
}

enum CoverTemplateCycle {
    /// Selección cíclica determinística por `appDay`.
    ///
    /// Implementación: convierte `appDay` (YYYY-MM-DD) a “días desde 1970-01-01” y hace mod 4.
    /// Esto produce A→B→C→D→A… (a nivel calendario) sin necesidad de persistir estado.
    static func template(forAppDay appDay: String) -> CoverTemplate {
        guard let date = AppDay.parse(appDay) else { return .a }
        let days = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: 0), to: date).day ?? 0
        return CoverTemplate(rawValue: ((days % 4) + 4) % 4) ?? .a
    }
}
