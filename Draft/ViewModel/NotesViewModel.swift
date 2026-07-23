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
    @Published var selectedNote: Note?
    @Published var isConfigured: Bool = false
    @Published var isSyncing: Bool = false
    @Published var cloneError: String?

    private let repo = NoteRepository()
    private var saveWorkItem: DispatchWorkItem?

    init() {
        self.isConfigured = GitSyncManager.shared.isConfigured
        if isConfigured {
            loadNotes()
            syncNow()
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
        selectedNote = note

        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes[idx] = note
        }

        saveWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.repo.saveNote(note)
            DispatchQueue.main.async {
                self.loadNotes()
                self.syncNow()
            }
        }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: item)
    }

    func syncNow() {
        guard isConfigured else { return }
        isSyncing = true

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
        syncNow()
    }
}
