//
//  ContentView.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showSetupSheet = false

    var body: some View {
        NavigationSplitView {
            List(viewModel.notes, selection: $viewModel.selectedNote) { note in
                NavigationLink(value: note) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(note.title.isEmpty ? "Untitled Note" : note.title)
                                .font(.headline)
                            Text(note.body.isEmpty ? "No content" : note.body)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        Spacer()
                        if note.isUnsynced {
                            Image(systemName: "icloud.slash")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                .contextMenu {
                    Button("Delete Note", role: .destructive) {
                        viewModel.deleteNote(note)
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewModel.createNote() }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        } detail: {
            if let selectedNote = viewModel.selectedNote {
                // Isolated editor view — its re-renders don't bubble up to the list
                NoteEditorView(note: selectedNote, viewModel: viewModel)
                    .id(selectedNote.id)
                    .ignoresSafeArea(edges: .top)
            } else {
                Text("Select or create a note to begin")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showSetupSheet) {
            SetupView(viewModel: viewModel)
        }
        .onAppear {
            if !viewModel.isConfigured {
                showSetupSheet = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willHideNotification)) { _ in
            viewModel.syncNow()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { viewModel.syncNow() }) {
                    Image(systemName: viewModel.isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button(action: { showSetupSheet = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .toolbarBackground(.hidden, for: .windowToolbar)
    }
}

// MARK: - NoteEditorView
// Isolated so that keystrokes only re-render this subtree, not the whole ContentView.
// Title and body are held in local @State — the ViewModel is only called after a
// short debounce, preventing @Published from firing on every character.

struct NoteEditorView: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel

    @State private var title: String
    @State private var bodyText: String
    private let saveDebounce = 0.8

    init(note: Note, viewModel: NotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        _title    = State(initialValue: note.title)
        _bodyText = State(initialValue: note.body)
    }

    var body: some View {
        MarkdownTextEditor(text: $bodyText, title: $title, documentId: note.id)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: title) { _, newTitle in
                scheduleBodySave(title: newTitle, body: bodyText)
            }
            .onChange(of: bodyText) { _, newBody in
                scheduleBodySave(title: title, body: newBody)
            }
        .padding(.leading, 32)
    }

    private func scheduleBodySave(title: String, body: String) {
        viewModel.updateSelectedNote(title: title, body: body)
    }
}

#Preview {
    ContentView()
}
