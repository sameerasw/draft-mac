//
//  GitSyncManager.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import Foundation
import Security

final class GitSyncManager {
    static let shared = GitSyncManager()

    var repoDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("draft-notes")
    }

    var isConfigured: Bool {
        return getPAT() != nil && getRepoURL() != nil && FileManager.default.fileExists(atPath: repoDir.appendingPathComponent(".git").path)
    }

    func saveConfig(repoURL: String, pat: String, authorName: String, authorEmail: String) {
        UserDefaults.standard.set(repoURL, forKey: "draft_repo_url")
        UserDefaults.standard.set(authorName, forKey: "draft_author_name")
        UserDefaults.standard.set(authorEmail, forKey: "draft_author_email")
        savePAT(pat)
    }

    func getRepoURL() -> String? { UserDefaults.standard.string(forKey: "draft_repo_url") }
    func getAuthorName() -> String { UserDefaults.standard.string(forKey: "draft_author_name") ?? "Draft User" }
    func getAuthorEmail() -> String { UserDefaults.standard.string(forKey: "draft_author_email") ?? "draft@local" }

    private func savePAT(_ pat: String) {
        let tag = "com.sameerasw.draft.pat".data(using: .utf8)!
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag,
            kSecValueData as String: pat.data(using: .utf8)!
        ]
        SecItemDelete(addQuery as CFDictionary)
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    func getPAT() -> String? {
        let tag = "com.sameerasw.draft.pat".data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func cloneRepo(repoURL: String, pat: String, authorName: String, authorEmail: String) -> Bool {
        saveConfig(repoURL: repoURL, pat: pat, authorName: authorName, authorEmail: authorEmail)

        if FileManager.default.fileExists(atPath: repoDir.path) {
            try? FileManager.default.removeItem(at: repoDir)
        }
        try? FileManager.default.createDirectory(at: repoDir, withIntermediateDirectories: true)

        let authenticatedURL = repoURL.replacingOccurrences(of: "https://", with: "https://token:\(pat)@")
        let res = GitRunner.run("git clone '\(authenticatedURL)' '\(repoDir.path)'", in: repoDir.deletingLastPathComponent())
        return res.exitCode == 0
    }

    func sync() -> (success: Bool, message: String) {
        guard isConfigured else { return (false, "Not configured") }

        let name = getAuthorName()
        let email = getAuthorEmail()

        _ = GitRunner.run("git config user.name '\(name)'", in: repoDir)
        _ = GitRunner.run("git config user.email '\(email)'", in: repoDir)

        // 1. Stage all changes
        _ = GitRunner.run("git add -A", in: repoDir)

        // 2. Commit local changes if any
        let statusRes = GitRunner.run("git status --porcelain", in: repoDir)
        if !statusRes.output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            _ = GitRunner.run("git commit -m 'auto: update notes from macOS'", in: repoDir)
        }

        // 3. Pull rebase to integrate remote changes first
        let pullRes = GitRunner.run("git pull --rebase origin main", in: repoDir)
        if pullRes.exitCode != 0 {
            _ = GitRunner.run("git rebase --abort", in: repoDir)
        }

        // 4. Push local commits to remote; fallback to fetch & hard reset if rejected
        let pushRes = GitRunner.run("git push origin main", in: repoDir)
        if pushRes.exitCode != 0 {
            _ = GitRunner.run("git fetch origin", in: repoDir)
            _ = GitRunner.run("git reset --hard origin/main", in: repoDir)
        }

        return (true, "Synced")
    }

    func isFileUnsynced(_ fileURL: URL) -> Bool {
        guard isConfigured else { return true }

        let fileName = fileURL.lastPathComponent

        let statusRes = GitRunner.run("git status --porcelain", in: repoDir)
        let lines = statusRes.output.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty && line.contains(fileName) {
                return true
            }
        }
        return false
    }
}
