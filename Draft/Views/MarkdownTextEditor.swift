import SwiftUI
import MarkdownEngine

/// Thin wrapper around the MarkdownEngine `NativeTextViewWrapper`.
/// Drop-in replacement for the old custom editor — all live markdown
/// styling (bold, italic, headings, lists, code, blockquotes, etc.)
/// is handled by the library's TextKit 2 engine at zero cost.
struct MarkdownTextEditor: View {
    @Binding var text: String
    var documentId: String = "draft-note"

    var body: some View {
        NativeTextViewWrapper(text: $text, documentId: documentId)
    }
}
