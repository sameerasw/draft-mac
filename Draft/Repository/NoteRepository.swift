//
//  NoteRepository.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import Foundation

final class NoteRepository {
    let gitSyncManager = GitSyncManager.shared

    func loadNotes() -> [Note] {
        guard FileManager.default.fileExists(atPath: gitSyncManager.repoDir.path) else { return [] }

        let files = (try? FileManager.default.contentsOfDirectory(at: gitSyncManager.repoDir, includingPropertiesForKeys: nil)) ?? []
        let notes = files.filter { $0.pathExtension == "md" }.compactMap { Note.parse(from: $0) }
        return notes.sorted { $0.updatedAt > $1.updatedAt }
    }

    func createNote() -> Note {
        let id = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970
        let title = "Untitled Note"
        let fileName = "Note-\(Int(timestamp)).md"
        let fileURL = gitSyncManager.repoDir.appendingPathComponent(fileName)

        let content = """
        ---
        id: "\(id)"
        title: "\(title)"
        updated_at: \(Int(timestamp))
        ---


        """

        try? content.write(to: fileURL, atomically: true, encoding: .utf8)
        return Note(id: id, title: title, body: "", updatedAt: Date(timeIntervalSince1970: timestamp), fileURL: fileURL)
    }

    func saveNote(_ note: Note) {
        let timestamp = Date().timeIntervalSince1970
        let content = """
        ---
        id: "\(note.id)"
        title: "\(note.title)"
        updated_at: \(Int(timestamp))
        ---
        \(note.body)
        """
        try? content.write(to: note.fileURL, atomically: true, encoding: .utf8)
    }

    func deleteNote(_ note: Note) {
        try? FileManager.default.removeItem(at: note.fileURL)
    }
}
