//
//  NoteEditorView.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI
import MarkdownEngine

struct NoteEditorView: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel

    @State private var title: String
    @State private var bodyText: String
    @State private var showSlashMenu: Bool = false
    @State private var slashQuery: String = ""
    @State private var targetLineIndex: Int = -1
    @State private var selectedIndex: Int = 0

    init(note: Note, viewModel: NotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        _title    = State(initialValue: note.title)
        _bodyText = State(initialValue: note.body)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            MarkdownTextEditor(
                text: $bodyText,
                title: $title,
                documentId: note.id,
                isSlashMenuOpen: showSlashMenu,
                onInlinePreviewKey: handleKeyNavigation
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.leading, 32)
            .onChange(of: title)    { _, newTitle in save(title: newTitle, body: bodyText) }
            .onChange(of: bodyText) { _, newBody  in
                checkSlashCommand(newBodyText: newBody)
                save(title: title, body: newBody)
            }

            if showSlashMenu {
                SlashCommandMenuView(filterText: slashQuery, selectedIndex: $selectedIndex) { selectedItem in
                    applySlashCommand(selectedItem)
                }
                .padding(.top, max(140, CGFloat(140 + (targetLineIndex >= 0 ? targetLineIndex : 0) * 22)))
                .padding(.leading, 48)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    private func handleKeyNavigation(key: InlinePreviewKey) -> Bool {
        guard showSlashMenu else { return false }

        let filteredItems = SlashCommandProvider.items.filter { item in
            slashQuery.isEmpty ||
            item.title.localizedCaseInsensitiveContains(slashQuery) ||
            item.description.localizedCaseInsensitiveContains(slashQuery)
        }
        guard !filteredItems.isEmpty else { return false }

        switch key {
        case .moveUp:
            selectedIndex = max(0, selectedIndex - 1)
            return true
        case .moveDown:
            selectedIndex = min(filteredItems.count - 1, selectedIndex + 1)
            return true
        case .confirm, .confirmAndOpen:
            if selectedIndex >= 0 && selectedIndex < filteredItems.count {
                applySlashCommand(filteredItems[selectedIndex])
            }
            return true
        case .cancel:
            showSlashMenu = false
            return true
        @unknown default:
            return false
        }
    }

    private func checkSlashCommand(newBodyText: String) {
        let lines = newBodyText.components(separatedBy: .newlines)

        if let index = lines.lastIndex(where: { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("/")
        }) {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            slashQuery = String(trimmed.dropFirst())
            targetLineIndex = index
            selectedIndex = 0
            withAnimation(.easeOut(duration: 0.12)) {
                showSlashMenu = true
            }
        } else {
            if showSlashMenu {
                withAnimation(.easeIn(duration: 0.1)) {
                    showSlashMenu = false
                }
            }
        }
    }

    private func applySlashCommand(_ item: SlashCommandItem) {
        var lines = bodyText.components(separatedBy: .newlines)
        let indexToReplace = (targetLineIndex >= 0 && targetLineIndex < lines.count) ? targetLineIndex : (lines.count - 1)

        if indexToReplace >= 0 && indexToReplace < lines.count {
            lines[indexToReplace] = item.markdownPrefix
        }

        let updatedText = lines.joined(separator: "\n")
        bodyText = updatedText
        showSlashMenu = false
        save(title: title, body: updatedText)
    }

    private func save(title: String, body: String) {
        viewModel.updateSelectedNote(title: title, body: body)
    }
}
