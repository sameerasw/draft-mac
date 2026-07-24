//
//  MarkdownTextEditor.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI
import AppKit
import MarkdownEngine

struct MarkdownTextEditor: View {
    @Binding var text: String
    @Binding var title: String
    var documentId: String = "draft-note"
    var isSlashMenuOpen: Bool = false
    var onInlinePreviewKey: ((InlinePreviewKey) -> Bool)? = nil

    var body: some View {
        CustomMarkdownTextView(
            text: $text,
            title: $title,
            documentId: documentId,
            isSlashMenuOpen: isSlashMenuOpen,
            onKeyCommand: onInlinePreviewKey
        )
    }
}
