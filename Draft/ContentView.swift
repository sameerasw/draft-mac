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
            NoteListView(viewModel: viewModel, showSetupSheet: $showSetupSheet)
        } detail: {
            if let selectedNote = viewModel.selectedNote {
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
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
            viewModel.onAppFocusLost()
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                    Button(action: { viewModel.syncNow() }) {
                        if viewModel.isSyncing {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.icloud")
                        }
                    }
                    .keyboardShortcut("s", modifiers: .command)

                    Button(action: { showSetupSheet = true }) {
                        Image(systemName: "gear")
                    }
                    .keyboardShortcut(",", modifiers: .command)
                }
        }
        .background(VisualEffectBlur(material: .fullScreenUI, blendingMode: .behindWindow).ignoresSafeArea())
        .toolbarBackground(.hidden, for: .windowToolbar)
        .navigationTitle(Text(""))
    }
}

#Preview {
    ContentView()
}
