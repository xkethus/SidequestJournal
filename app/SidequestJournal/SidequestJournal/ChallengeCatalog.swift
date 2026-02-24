import Foundation

struct ChallengeCatalog: Codable {
    struct Category: Codable, Identifiable {
        let id: String
        let name: String
        let shortName: String?
        let order: Int
    }

    struct CoverSpec: Codable {
        let template: String?
        let imageName: String?
    }

    struct Badge: Codable, Identifiable {
        let id: String
        let name: String
        let categoryId: String
        let icon: String
    }

    struct Challenge: Codable, Identifiable {
        let id: String
        let title: String
        let prompt: String
        let categoryId: String
        let badgeId: String
        let isActive: Bool

        let durationMinutes: Int?
        let cover: CoverSpec?
    }

    let version: Int
    let defaultDailyResetTime: String
    let categories: [Category]
    let badges: [Badge]
    let challenges: [Challenge]

    static func loadFromBundle() throws -> ChallengeCatalog {
        guard let url = Bundle.main.url(forResource: "challenges", withExtension: "json") else {
            throw NSError(domain: "ChallengeCatalog", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se encontró challenges.json en el bundle.\n\nEn Xcode: arrastra SidequestJournal/Resources/challenges.json al proyecto y marca ‘Copy items if needed’. Asegúrate que esté en Target Membership."])
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ChallengeCatalog.self, from: data)
    }
}
