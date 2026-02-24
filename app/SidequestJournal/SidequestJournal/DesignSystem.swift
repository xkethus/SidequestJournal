import SwiftUI

// MARK: - Design System (B/N editorial + acento ultra sutil por nivel)

enum SJ {
    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
        static let xl: CGFloat = 30
    }

    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 18
        static let lg: CGFloat = 26
    }

    enum Typography {
        static func title() -> Font { .system(size: 28, weight: .semibold, design: .serif) }
        static func headline() -> Font { .system(size: 17, weight: .semibold, design: .default) }
        static func body() -> Font { .system(size: 16, weight: .regular, design: .default) }
        static func caption() -> Font { .system(size: 12, weight: .medium, design: .default) }
    }

    enum Palette {
        static let bg = Color(.systemBackground)
        static let surface = Color(.secondarySystemBackground)
        static let ink = Color.primary
        static let mutedInk = Color.secondary
        static let hairline = Color.black.opacity(0.10)

        // Ultra-sutil: un "warm gray" que no grita color.
        static func accent(for level: Int) -> Color {
            // Level 0 = casi gris. Level 3 = un poquito más cálido/oscuro.
            switch level {
            case 3: return Color(red: 0.36, green: 0.33, blue: 0.30) // graphite warm
            case 2: return Color(red: 0.48, green: 0.45, blue: 0.41)
            case 1: return Color(red: 0.62, green: 0.59, blue: 0.55)
            default: return Color.black.opacity(0.20)
            }
        }

        static func accentGradient(for level: Int) -> LinearGradient {
            let a = accent(for: level)
            return LinearGradient(
                colors: [a.opacity(0.10), a.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    enum Shadow {
        static func card() -> (Color, CGFloat, CGFloat, CGFloat) {
            (Color.black.opacity(0.06), 18, 0, 8)
        }
    }
}

// MARK: - Common UI

struct SJCard<Content: View>: View {
    let level: Int
    @ViewBuilder var content: Content

    init(level: Int = 0, @ViewBuilder content: () -> Content) {
        self.level = level
        self.content = content()
    }

    var body: some View {
        content
            .padding(SJ.Spacing.md)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                        .fill(SJ.Palette.surface)

                    RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                        .fill(SJ.Palette.accentGradient(for: level))
                        .blendMode(.overlay)

                    RoundedRectangle(cornerRadius: SJ.Radius.md, style: .continuous)
                        .stroke(SJ.Palette.hairline, lineWidth: 1)
                }
            )
            .shadow(color: SJ.Shadow.card().0, radius: SJ.Shadow.card().1, x: SJ.Shadow.card().2, y: SJ.Shadow.card().3)
    }
}

struct SJPrimaryButtonStyle: ButtonStyle {
    let level: Int

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold, design: .default))
            .tracking(1.4)
            .textCase(.uppercase)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: SJ.Radius.sm, style: .continuous)
                    .fill(SJ.Palette.accent(for: level))
            )
            .opacity(configuration.isPressed ? 0.82 : 1.0)
    }
}

/// CTA minimal editorial: texto + icono, sin caja. Ideal para "Completar".
struct SJLinkCTAStyle: ButtonStyle {
    let level: Int

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold, design: .default))
            .tracking(1.8)
            .textCase(.uppercase)
            .foregroundStyle(SJ.Palette.accent(for: level))
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.55 : 1.0)
    }
}

struct SJChip: View {
    let text: String
    let level: Int

    var body: some View {
        Text(text.uppercased())
            .font(SJ.Typography.caption())
            .tracking(0.8)
            .foregroundStyle(SJ.Palette.accent(for: max(level, 1)))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(SJ.Palette.accentGradient(for: level))
            )
            .overlay(
                Capsule().stroke(SJ.Palette.hairline, lineWidth: 1)
            )
    }
}
