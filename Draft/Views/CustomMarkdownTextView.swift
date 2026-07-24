//
//  CustomMarkdownTextView.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import AppKit
import SwiftUI
import MarkdownEngine
import Combine

struct CustomMarkdownTextView: View {
    @Binding var text: String
    @Binding var title: String
    var documentId: String = "draft-note"
    var isSlashMenuOpen: Bool
    var onKeyCommand: ((InlinePreviewKey) -> Bool)?

    @StateObject private var monitorHolder = EventMonitorHolder()

    var body: some View {
        NativeTextViewWrapper(
            text: $text,
            isWikiLinkActive: .constant(isSlashMenuOpen),
            documentId: documentId,
            header: AnyView(TitleHeaderView(title: $title)),
            headerCollapsedHeight: 0,
            headerExpanded: true
        )
        .onAppear {
            monitorHolder.start(isSlashMenuOpen: isSlashMenuOpen, onKeyCommand: onKeyCommand)
        }
        .onChange(of: isSlashMenuOpen) { _, newValue in
            monitorHolder.isSlashMenuOpen = newValue
        }
        .onChange(of: onKeyCommand != nil) { _, _ in
            monitorHolder.onKeyCommand = onKeyCommand
        }
    }
}

private class EventMonitorHolder: ObservableObject {
    var isSlashMenuOpen: Bool = false
    var onKeyCommand: ((InlinePreviewKey) -> Bool)?
    private var monitor: Any?

    func start(isSlashMenuOpen: Bool, onKeyCommand: ((InlinePreviewKey) -> Bool)?) {
        self.isSlashMenuOpen = isSlashMenuOpen
        self.onKeyCommand = onKeyCommand
        guard monitor == nil else { return }

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, self.isSlashMenuOpen, let onKeyCommand = self.onKeyCommand else {
                return event
            }

            switch event.keyCode {
            case 126: // Up
                if onKeyCommand(.moveUp) { return nil }
            case 125: // Down
                if onKeyCommand(.moveDown) { return nil }
            case 36, 76: // Return / Enter
                if onKeyCommand(.confirm) { return nil }
            case 53: // Escape
                if onKeyCommand(.cancel) { return nil }
            default:
                break
            }
            return event
        }
    }

    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
