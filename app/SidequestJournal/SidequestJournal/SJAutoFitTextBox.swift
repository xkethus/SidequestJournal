import SwiftUI

/// Texto en caja (opcionalmente fija) con auto-fit por escalones.
struct SJAutoFitTextBox: View {
    let text: String
    var height: CGFloat? = 140

    var body: some View {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        RoundedRectangle(cornerRadius: SJ.Radius.sm, style: .continuous)
            .fill(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: SJ.Radius.sm, style: .continuous)
                    .stroke(SJ.Palette.hairline, lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                ViewThatFits(in: .vertical) {
                    fittedText(trimmed, size: 18, lineSpacing: 3)
                    fittedText(trimmed, size: 16, lineSpacing: 2.5)
                    fittedText(trimmed, size: 14, lineSpacing: 2)
                    fittedText(trimmed, size: 13, lineSpacing: 1.5)
                }
                .padding(10)
            }
            .frame(height: height)
    }

    private func fittedText(_ t: String, size: CGFloat, lineSpacing: CGFloat) -> some View {
        Text(t)
            .font(.system(size: size, weight: .regular, design: .default))
            .foregroundStyle(SJ.Palette.ink)
            .lineSpacing(lineSpacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
