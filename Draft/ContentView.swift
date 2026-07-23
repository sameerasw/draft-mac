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
                    VStack(alignment: .leading) {
                        Text(note.title.isEmpty ? "Untitled Note" : note.title)
                            .font(.headline)
                        Text(note.body.isEmpty ? "No content" : note.body)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
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
                VStack {
                    TextField("Title", text: Binding(
                        get: { viewModel.selectedNote?.title ?? "" },
                        set: { viewModel.updateSelectedNote(title: $0, body: viewModel.selectedNote?.body ?? "") }
                    ))
                    .font(.title)
                    .textFieldStyle(.plain)
                    .padding([.top, .horizontal])

                    Divider()

                    TextEditor(text: Binding(
                        get: { viewModel.selectedNote?.body ?? "" },
                        set: { viewModel.updateSelectedNote(title: viewModel.selectedNote?.title ?? "", body: $0) }
                    ))
                    .font(.body)
                    .padding()
                }
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
    }
}

#Preview {
    ContentView()
}
