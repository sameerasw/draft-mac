//
//  NotesViewModel.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import Foundation
import Combine

@MainActor
final class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var selectedNote: Note? {
        didSet {
            if oldValue?.id != selectedNote?.id {
                onNoteSwitched()
            }
        }
    }
    @Published var isConfigured: Bool = false
    @Published var isSyncing: Bool = false
    @Published var cloneError: String?

    private let repo = NoteRepository()
    private var saveWorkItem: DispatchWorkItem?
    private var lastSyncTime: Date = .distantPast

    init() {
        self.isConfigured = GitSyncManager.shared.isConfigured
        if isConfigured {
            loadNotes()
            syncNow(force: true)
        }
    }

    func loadNotes() {
        self.notes = repo.loadNotes()
        if selectedNote == nil, let first = notes.first {
            selectedNote = first
        }
    }

    func cloneRepo(repoURL: String, pat: String, authorName: String, authorEmail: String) {
        self.isSyncing = true
        self.cloneError = nil

        DispatchQueue.global(qos: .userInitiated).async {
            let success = GitSyncManager.shared.cloneRepo(repoURL: repoURL, pat: pat, authorName: authorName, authorEmail: authorEmail)
            DispatchQueue.main.async {
                self.isSyncing = false
                if success {
                    self.isConfigured = true
                    self.loadNotes()
                } else {
                    self.cloneError = "Failed to clone repository"
                }
            }
        }
    }

    func createNote() {
        var newNote = repo.createNote()
        newNote.isUnsynced = true
        loadNotes()
        if let idx = notes.firstIndex(where: { $0.id == newNote.id }) {
            notes[idx].isUnsynced = true
        }
        selectedNote = newNote
    }

    func updateSelectedNote(title: String, body: String) {
        guard var note = selectedNote else { return }
        if note.title == title && note.body == body { return }
        note.title = title
        note.body = body
        note.isUnsynced = true

        saveWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.repo.saveNote(note)
            DispatchQueue.main.async {
                // Save locally and update state without triggering git push/pull every second
                self.selectedNote = note
                if let idx = self.notes.firstIndex(where: { $0.id == note.id }) {
                    self.notes[idx] = note
                }
            }
        }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: item)
    }

    func onNoteSwitched() {
        // Automatically sync when switching notes
        syncNow(force: true)
    }

    func onAppFocusLost() {
        // Only sync on app focus loss if at least 1 minute has passed since last sync
        let now = Date()
        if now.timeIntervalSince(lastSyncTime) >= 60.0 {
            syncNow(force: true)
        }
    }

    func syncNow(force: Bool = false) {
        guard isConfigured else { return }
        isSyncing = true
        lastSyncTime = Date()

        DispatchQueue.global(qos: .userInitiated).async {
            let res = GitSyncManager.shared.sync()
            DispatchQueue.main.async {
                self.isSyncing = false
                if res.success {
                    self.loadNotes()
                }
            }
        }
    }

    func deleteNote(_ note: Note) {
        repo.deleteNote(note)
        if selectedNote?.id == note.id {
            selectedNote = nil
        }
        loadNotes()
        syncNow(force: true)
    }
}
