import SwiftUI

/// Editorial cover for Today tab.
///
/// Notes:
/// - Title is intentionally omitted from layout (kept as metadata in catalog, not shown here).
/// - Evidence is a core mechanic; we don't repeat it in the cover UI.
struct TodayCoverView: View {
    let level: Int
    let template: CoverTemplate
    let appDay: String
    let categoryName: String           // shortName preferred
    let durationMinutes: Int
    let imageName: String              // asset name, e.g. "CoverA"
    let prompt: String
    let onComplete: () -> Void

    var body: some View {
        GeometryReader { geo in
            let screenH = geo.size.height

            ScrollView {
                VStack(alignment: .leading, spacing: SJ.Spacing.lg) {
                    header

                    switch template {
                    case .a: coverA(screenH: screenH)
                    case .b: coverB(screenH: screenH)
                    case .c: coverC(screenH: screenH)
                    case .d: coverD(screenH: screenH)
                    }

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, SJ.Spacing.md)
                .padding(.top, SJ.Spacing.md)
                .padding(.bottom, 16)
            }
            .background(SJ.Palette.bg)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: SJ.Spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text("SIDEQUEST")
                    .font(SJ.Typography.caption())
                    .tracking(2.0)
                    .foregroundStyle(SJ.Palette.mutedInk)

                Spacer()

                Text(appDay)
                    .font(SJ.Typography.caption())
                    .tracking(1.2)
                    .foregroundStyle(SJ.Palette.mutedInk)
            }

            Rectangle()
                .fill(SJ.Palette.hairline)
                .frame(height: 1)

            HStack {
                Text("Nivel \(level)")
                    .font(.footnote)
                    .foregroundStyle(SJ.Palette.accent(for: level))
                Spacer()
            }
        }
    }

    // MARK: - Common pieces

    private var categoryDuration: some View {
        HStack(spacing: 10) {
            CategoryLabel(text: categoryName, level: level)
            NoteLabel(text: "\(durationMinutes) min")
        }
    }

    private var completeRow: some View {
        HStack(spacing: 14) {
            Button("COMPLETAR") { onComplete() }
                .buttonStyle(SJLinkCTAStyle(level: level))

            EditorialRuleArrow()
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Templates

    /// A: Typography first, then CTA, then image block.
    private func coverA(screenH: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: SJ.Spacing.lg) {
            HStack {
                Text("SIDEQUEST")
                    .font(SJ.Typography.caption())
                    .tracking(2)
                    .foregroundStyle(SJ.Palette.mutedInk)
                Spacer()
                categoryDuration
            }

            Text(prompt)
                .font(.system(size: 42, weight: .bold, design: .default))
                .foregroundStyle(SJ.Palette.ink)
                .lineSpacing(-5)
                .fixedSize(horizontal: false, vertical: true)

            completeRow

            let h = max(260, min(360, screenH * 0.34))
            CoverImageBlock(imageName: imageName, level: level)
                .frame(height: h)
                .clipShape(RoundedRectangle(cornerRadius: SJ.Radius.lg, style: .continuous))
        }
    }

    /// B: Sidebar + tall cover (~3/4 height), prompt bottom-right on gradient.
    private func coverB(screenH: CGFloat) -> some View {
        HStack(alignment: .top, spacing: SJ.Spacing.lg) {
            VStack(alignment: .leading, spacing: SJ.Spacing.sm) {
                Text("INDEX")
                    .font(SJ.Typography.caption())
                    .tracking(2)
                    .foregroundStyle(SJ.Palette.mutedInk)

                Rectangle().fill(SJ.Palette.hairline).frame(height: 1)

                VStack(alignment: .leading, spacing: 6) {
                    Text("ID.")
                        .font(SJ.Typography.caption())
                        .tracking(1.8)
                        .foregroundStyle(SJ.Palette.mutedInk)
                    Text(String(appDay.suffix(2)))
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                }

                CategoryLabel(text: categoryName, level: level)
                NoteLabel(text: "\(durationMinutes) min")

                Text("Nivel \(level)")
                    .font(.footnote)
                    .foregroundStyle(SJ.Palette.accent(for: level))

                Spacer(minLength: 0)

                Button("COMPLETAR") { onComplete() }
                    .buttonStyle(SJLinkCTAStyle(level: level))

                EditorialRuleArrow()
                    .frame(height: 1)
                    .padding(.top, 10)
            }
            .frame(width: 120)

            let radius: CGFloat = 34
            let h = max(520, min(700, screenH * 0.70))

            GeometryReader { proxy in
                let safeW = proxy.size.width                 // width remaining after sidebar
                let bleed = safeW * 0.10                     // ~10% extra bleed
                let textW = safeW * 0.90                     // ~90% text box for fewer hard wraps

                ZStack(alignment: .bottomTrailing) {
                    // IMAGE: bleed a bit to the right for a Swiss/editorial feel.
                    CoverImageBlock(imageName: imageName, level: level)
                        .frame(height: h)
                        .frame(width: safeW + bleed)
                        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // TEXT: constrained to the safe column (no bleed).
                    Text(prompt)
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundStyle(SJ.Palette.ink)
                        .lineSpacing(-1)
                        .multilineTextAlignment(.trailing)
                        // Safety rails for very long prompts:
                        // - Prefer keeping the bottom anchor.
                        // - Allow a little automatic downscaling before truncating.
                        .lineLimit(12)
                        .minimumScaleFactor(0.82)
                        .frame(width: textW, alignment: .trailing)
                        .padding(.trailing, 30)
                        .padding(.bottom, 30)
                        .padding(.leading, 20)
                        .frame(width: safeW, height: h, alignment: .bottomTrailing)
                }
                .frame(width: safeW, height: h, alignment: .leading)
                // Cancel the ScrollView's right padding and add the bleed.
                .padding(.trailing, -(SJ.Spacing.md + bleed))
            }
            .frame(height: h)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 4)
    }

    /// C: Metadata top; vertical inset card; CTA pinned near bottom.
    private func coverC(screenH: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: SJ.Spacing.lg) {
            HStack {
                Text("SIDEQUEST")
                    .font(SJ.Typography.caption())
                    .tracking(2)
                    .foregroundStyle(SJ.Palette.mutedInk)
                Spacer()
                HStack(spacing: 10) {
                    NoteLabel(text: "ID. \(appDay)")
                    categoryDuration
                }
            }

            let radius: CGFloat = 30
            let h = max(520, min(660, screenH * 0.66))

            ZStack(alignment: .bottomLeading) {
                // Background image behaves like a true card background (fixed frame, center-crop).
                CoverImageBlock(imageName: imageName, level: level)
                    .frame(height: h)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))

                // Bottom text area (not full height). Keep generous inset to avoid edge clipping.
                Text(prompt)
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .foregroundStyle(SJ.Palette.ink)
                    .lineSpacing(-1)
                    .frame(maxWidth: 320, alignment: .leading)
                    .padding(.leading, 28)
                    .padding(.trailing, 28)
                    .padding(.bottom, 30)
            }
            // Force the inset card to occupy the available width so wide photos can't "shrink" the card.
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 14) // inset card

            completeRow
                .padding(.horizontal, 14)
        }
    }

    /// D: Full-bleed poster.
    ///
    /// Layout goals (matches mockups):
    /// - Image fills the whole block.
    /// - Low-opacity photo.
    /// - Stronger bottom gradient for readability.
    /// - Bottom overlay with category + duration + big prompt + completar + rule/arrow.
    private func coverD(screenH: CGFloat) -> some View {
        GeometryReader { geo in
            let size = geo.size

            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .opacity(0.55)

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.92),
                        Color.white.opacity(0.55),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        CategoryLabel(text: categoryName, level: level)
                        NoteLabel(text: "\(durationMinutes) min")
                    }

                    Text(prompt)
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundStyle(SJ.Palette.ink)
                        .lineSpacing(-4)
                        .fixedSize(horizontal: false, vertical: true)

                    completeRow
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 22)
            }
        }
        .frame(height: max(560, min(820, screenH * 0.88)))
        .padding(.horizontal, -SJ.Spacing.md) // neutralize scroll padding for full-bleed
    }
}

// MARK: - Small components

private struct CategoryLabel: View {
    let text: String
    let level: Int

    var body: some View {
        Text(text.lowercased())
            .font(.system(size: 13, weight: .heavy, design: .default))
            .italic()
            .foregroundStyle(SJ.Palette.accent(for: max(level, 1)).opacity(0.78))
    }
}

private struct NoteLabel: View {
    let text: String
    var body: some View {
        Text(text.lowercased())
            .font(.system(size: 13, weight: .regular, design: .default))
            .italic()
            .foregroundStyle(Color.black.opacity(0.46))
    }
}

private struct EditorialRuleArrow: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            Rectangle()
                .fill(Color.black.opacity(0.14))
                .frame(height: 1)

            Image(systemName: "arrow.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.22))
                .padding(.leading, 10)
                .background(Color.clear)
        }
    }
}

private struct CoverImageBlock: View {
    let imageName: String
    let level: Int

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    // Make the crop deterministic: fill exactly the container rect.
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                // subtle readability layer
                LinearGradient(
                    colors: [Color.white.opacity(0.90), Color.white.opacity(0.58), Color.white.opacity(0.0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .blendMode(.normal)
            }
        }
    }
}
