import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRows: [AppSettings]

    @State private var hour: Int = 7
    @State private var minute: Int = 0
    @State private var savedMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Hora del Sidequest") {
                    DatePicker(
                        "Hora",
                        selection: Binding(
                            get: { makeDate(hour: hour, minute: minute) },
                            set: { d in
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: d)
                                hour = comps.hour ?? 7
                                minute = comps.minute ?? 0
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )

                    Button("Guardar") { save() }

                    if let savedMessage {
                        Text(savedMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Nota") {
                    Text("El reto del día se asigna a esta hora incluso si no abres la app. En MVP se consolida al abrir.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ajustes")
            .task { load() }
        }
    }

    private func makeDate(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: hour, minute: minute)) ?? .now
    }

    private func load() {
        if let s = settingsRows.first {
            hour = s.dailyResetHour
            minute = s.dailyResetMinute
        }
    }

    private func save() {
        do {
            let s = settingsRows.first ?? {
                let new = AppSettings()
                modelContext.insert(new)
                return new
            }()

            s.dailyResetHour = hour
            s.dailyResetMinute = minute
            try modelContext.save()
            savedMessage = "Guardado: \(String(format: "%02d:%02d", hour, minute))"
        } catch {
            savedMessage = "Error: \(error)"
        }
    }
}
