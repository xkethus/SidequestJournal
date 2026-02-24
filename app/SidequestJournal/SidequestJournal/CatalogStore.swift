import Foundation
import SwiftUI
import Combine
@MainActor
final class CatalogStore: ObservableObject {
    @Published private(set) var catalog: ChallengeCatalog?
    @Published private(set) var errorMessage: String?

    func loadIfNeeded() {
        if catalog != nil || errorMessage != nil { return }
        do {
            catalog = try ChallengeCatalog.loadFromBundle()
        } catch {
            errorMessage = String(describing: error)
        }
    }

    func challengeTitle(for id: String) -> String {
        catalog?.challenges.first(where: { $0.id == id })?.title ?? id
    }

    func challenge(for id: String) -> ChallengeCatalog.Challenge? {
        catalog?.challenges.first(where: { $0.id == id })
    }

    func badge(for id: String) -> ChallengeCatalog.Badge? {
        catalog?.badges.first(where: { $0.id == id })
    }

    func category(for id: String) -> ChallengeCatalog.Category? {
        catalog?.categories.first(where: { $0.id == id })
    }
}
