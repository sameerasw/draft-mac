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
        .background(VisualEffectBlur(material: .fullScreenUI, blendingMode: .behindWindow).ignoresSafeArea())
        .toolbarBackground(.hidden, for: .windowToolbar)
    }
}

#Preview {
    ContentView()
}
