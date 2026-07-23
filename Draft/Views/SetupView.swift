//
//  SetupView.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var repoURL: String = GitSyncManager.shared.getRepoURL() ?? "https://github.com/username/draft-notes.git"
    @State private var pat: String = GitSyncManager.shared.getPAT() ?? ""
    @State private var authorName: String = GitSyncManager.shared.getAuthorName()
    @State private var authorEmail: String = GitSyncManager.shared.getAuthorEmail()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Repository Setup")
                .font(.title)

            VStack(alignment: .leading) {
                Text("GitHub Clone URL")
                TextField("https://github.com/user/draft-notes.git", text: $repoURL)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading) {
                Text("Personal Access Token (PAT)")
                SecureField("ghp_...", text: $pat)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading) {
                Text("Git Author Name")
                TextField("Name", text: $authorName)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading) {
                Text("Git Author Email")
                TextField("email@example.com", text: $authorEmail)
                    .textFieldStyle(.roundedBorder)
            }

            if let error = viewModel.cloneError {
                Text(error)
                    .foregroundColor(.red)
            }

            HStack {
                Spacer()
                if viewModel.isSyncing {
                    ProgressView()
                } else {
                    Button("Save & Clone") {
                        viewModel.cloneRepo(repoURL: repoURL, pat: pat, authorName: authorName, authorEmail: authorEmail)
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(repoURL.isEmpty || pat.isEmpty)
                }
            }
        }
        .padding()
        .frame(width: 450)
        .onChange(of: viewModel.isConfigured) { isConfigured in
            if isConfigured {
                dismiss()
            }
        }
    }
}
