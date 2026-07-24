//
//  NoteListView.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI

struct NoteListView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Binding var showSetupSheet: Bool

    var body: some View {
        List(viewModel.notes, selection: $viewModel.selectedNote) { note in
            NavigationLink(value: note) {
                NoteListRow(note: note)
            }
            .contextMenu {
                Button("Delete Note", role: .destructive) {
                    viewModel.deleteNote(note)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.createNote() }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
}
