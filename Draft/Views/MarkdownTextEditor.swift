import SwiftUI
import AppKit
import MarkdownEngine

/// Thin wrapper around the MarkdownEngine `NativeTextViewWrapper`.
/// The title TextField and squiggly underline are embedded as the
/// engine's native scroll-away header so the whole page scrolls together.
struct MarkdownTextEditor: View {
    @Binding var text: String
    @Binding var title: String
    var documentId: String = "draft-note"
    var onTitleChange: ((String) -> Void)? = nil

    var body: some View {
        NativeTextViewWrapper(
            text: $text,
            documentId: documentId,
            header: AnyView(titleHeader),
            headerCollapsedHeight: 0,
            headerExpanded: true
        )
    }

    // Title + squiggly underline hosted inside the editor scroll view
    private var titleHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Untitled", text: $title)
                .font(.system(size: 28, weight: .bold))
                .textFieldStyle(.plain)
                .padding(.top, 24)
                .padding(.trailing, 32)

            SquigglyLine()
                .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
                .frame(height: 6)
                .padding(.trailing, 32)
                .padding(.top, 6)
                .padding(.bottom, 12)
        }
    }
}

// MARK: - Squiggly sine-wave underline

struct SquigglyLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let amplitude: CGFloat = 2.0
        let wavelength: CGFloat = 25
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        var x: CGFloat = rect.minX
        while x <= rect.maxX {
            let y = rect.midY + amplitude * sin((x / wavelength) * .pi * 2)
            path.addLine(to: CGPoint(x: x, y: y))
            x += 1
        }
        return path
    }
}

