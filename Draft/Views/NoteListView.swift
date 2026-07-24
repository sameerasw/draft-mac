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
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
            .hidden()

            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.createNote() }) {
                    Image(systemName: "square.and.pencil")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

private func toggleSidebar() {
#if os(macOS)
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#else
    // For iOS / iPadOS
    UIApplication.shared.sendAction(#selector(UISplitViewController.toggleSidebar(_:)), to: nil, from: nil, for: nil)
#endif
}
