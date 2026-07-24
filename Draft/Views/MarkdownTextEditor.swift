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

    var body: some View {
        NativeTextViewWrapper(
            text: $text,
            documentId: documentId,
            header: AnyView(TitleHeaderView(title: $title)),
            headerCollapsedHeight: 0,
            headerExpanded: true
        )
    }
}
