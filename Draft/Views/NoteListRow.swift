//
//  NoteListRow.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI

struct NoteListRow: View {
    let note: Note

    var body: some View {
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
}
