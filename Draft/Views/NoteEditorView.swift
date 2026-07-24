//
//  NoteEditorView.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI

struct NoteEditorView: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel

    @State private var title: String
    @State private var bodyText: String

    init(note: Note, viewModel: NotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        _title    = State(initialValue: note.title)
        _bodyText = State(initialValue: note.body)
    }

    var body: some View {
        MarkdownTextEditor(text: $bodyText, title: $title, documentId: note.id)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.leading, 32)
            .onChange(of: title)    { _, newTitle in save(title: newTitle, body: bodyText) }
            .onChange(of: bodyText) { _, newBody  in save(title: title,    body: newBody)  }
    }

    private func save(title: String, body: String) {
        viewModel.updateSelectedNote(title: title, body: body)
    }
}
