import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var catalogStore: CatalogStore
    @Query private var settingsRows: [AppSettings]
    @Query private var entries: [JournalEntry]

    @State private var loadError: String?
    @State private var assignment: DailyAssignment?
    @State private var challenge: ChallengeCatalog.Challenge?

    private let service = DailyAssignmentService()

    var body: some View {
        NavigationStack {
            Group {
                if let loadError {
                    ContentUnavailableView("No se pudo cargar", systemImage: "exclamationmark.triangle.fill", description: Text(loadError))
                } else if let challenge, let assignment {
                    let level = globalLevel(forCompletedCount: entries.count)
                    // Dev override: permite previsualizar otros retos.
                    let effectiveChallenge = devChallengeOverrideId.flatMap { catalogStore.challenge(for: $0) } ?? challenge

                    let template = devTemplateOverride
                        ?? CoverTemplate.from(code: effectiveChallenge.cover?.template)
                        ?? CoverTemplateCycle.template(forAppDay: assignment.appDay)

                    let categoryShort = catalogStore.category(for: effectiveChallenge.categoryId)?.shortName
                        ?? catalogStore.category(for: effectiveChallenge.categoryId)?.name
                        ?? effectiveChallenge.categoryId

                    let durationMinutes = effectiveChallenge.durationMinutes ?? 15
                    let imageName = effectiveChallenge.cover?.imageName ?? "Cover\(template.code)"

                    TodayCoverView(
                        level: level,
                        template: template,
                        appDay: assignment.appDay,
                        categoryName: categoryShort,
                        durationMinutes: durationMinutes,
                        imageName: imageName,
                        prompt: effectiveChallenge.prompt,
                        onComplete: {
                            goToComplete = true
                        }
                    )
#if DEBUG
                    .safeAreaInset(edge: .bottom) {
                        VStack(spacing: 8) {
                            HStack {
                                Spacer()
                                Button(devPanelShown ? "Ocultar DEV" : "DEV") {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        devPanelShown.toggle()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }

                            if devPanelShown {
                                devControls()
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
#endif
                    .navigationDestination(isPresented: $goToComplete) {
                        CompleteChallengeView(challenge: challenge, assignment: assignment)
                    }

                } else {
                    ProgressView("Preparando reto…")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task { await load() }
        }
    }

    @State private var goToComplete: Bool = false
    @State private var devChallengeOverrideId: String? = nil
    @State private var devTemplateOverride: CoverTemplate? = nil
#if DEBUG
    @State private var devPanelShown: Bool = false
#endif

    private func ensureSettings() throws -> AppSettings {
        if let first = settingsRows.first { return first }
        let settings = AppSettings(dailyResetHour: 7, dailyResetMinute: 0)
        modelContext.insert(settings)
        try modelContext.save()
        return settings
    }

    @MainActor
    private func load() async {
        catalogStore.loadIfNeeded()
        guard let catalog = catalogStore.catalog else {
            loadError = catalogStore.errorMessage ?? "Catálogo no disponible"
            return
        }

        do {
            let settings = try ensureSettings()
            let assignment = try service.getOrCreateAssignment(catalog: catalog, modelContext: modelContext, settings: settings)
            self.assignment = assignment
            self.challenge = catalog.challenges.first(where: { $0.id == assignment.challengeId })
        } catch {
            self.loadError = String(describing: error)
        }
    }

    private func globalLevel(forCompletedCount n: Int) -> Int {
        if n >= 30 { return 3 }
        if n >= 15 { return 2 }
        if n >= 5 { return 1 }
        return 0
    }

#if DEBUG
    @ViewBuilder
    private func devControls() -> some View {
        // Controles de dev: previsualiza estilos (templates) y retos, sin afectar persistencia.
        VStack(spacing: 10) {
            Rectangle().fill(SJ.Palette.hairline).frame(height: 1)

            HStack(spacing: 10) {
                Text("DEV")
                    .font(SJ.Typography.caption())
                    .tracking(2)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Auto") {
                    devChallengeOverrideId = nil
                    devTemplateOverride = nil
                }
                .buttonStyle(.bordered)

                Button("Random Reto") {
                    guard let catalog = catalogStore.catalog else { return }
                    let pool = catalog.challenges.filter { $0.isActive }
                    devChallengeOverrideId = pool.randomElement()?.id
                }
                .buttonStyle(.bordered)

            }

            HStack(spacing: 8) {
                Text("Estilo")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(CoverTemplate.allCases, id: \.self) { t in
                    Button(t.code) { devTemplateOverride = t }
                        .buttonStyle(.bordered)
                        .tint(devTemplateOverride == t ? .primary : .gray)
                }

                Spacer()
            }

            if let id = devChallengeOverrideId {
                Text("Challenge: \(id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.thinMaterial)
    }
#endif
}
