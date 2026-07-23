//
//  Note.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import Foundation

struct Note: Identifiable, Hashable {
    var id: String { fileURL.path }
    let noteId: String
    var title: String
    var body: String
    var updatedAt: Date
    var fileURL: URL
    var isUnsynced: Bool = false

    static func parse(from fileURL: URL) -> Note? {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { return nil }

        let pattern = "^---\\s*\\n(.*?)\\n---\\s*\\n?(.*)$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]),
           let match = regex.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count)) {
            
            let headerRange = Range(match.range(at: 1), in: content)!
            let bodyRange = Range(match.range(at: 2), in: content)!

            let header = String(content[headerRange])
            let body = String(content[bodyRange])

            var id = UUID().uuidString
            var title = fileURL.deletingPathExtension().lastPathComponent
            var updatedAt = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()

            for line in header.components(separatedBy: .newlines) {
                let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                if parts.count == 2 {
                    let key = parts[0]
                    let val = parts[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                    if key == "id" { id = val }
                    if key == "title" { title = val }
                    if key == "updated_at", let timestamp = Double(val) {
                        updatedAt = Date(timeIntervalSince1970: timestamp)
                    }
                }
            }

            let isUnsynced = GitSyncManager.shared.isFileUnsynced(fileURL)
            return Note(noteId: id, title: title, body: body, updatedAt: updatedAt, fileURL: fileURL, isUnsynced: isUnsynced)
        } else {
            let title = fileURL.deletingPathExtension().lastPathComponent
            let updatedAt = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
            let isUnsynced = GitSyncManager.shared.isFileUnsynced(fileURL)
            return Note(noteId: UUID().uuidString, title: title, body: content, updatedAt: updatedAt, fileURL: fileURL, isUnsynced: isUnsynced)
        }
    }
}
