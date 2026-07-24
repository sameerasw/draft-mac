//
//  SlashCommandMenu.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI
import MarkdownEngine

struct SlashCommandItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let markdownPrefix: String
}

enum SlashCommandProvider {
    static let items: [SlashCommandItem] = [
        SlashCommandItem(title: "Heading 1", description: "Large section heading", icon: "textformat.size.larger", markdownPrefix: "# "),
        SlashCommandItem(title: "Heading 2", description: "Medium section heading", icon: "textformat.size", markdownPrefix: "## "),
        SlashCommandItem(title: "Heading 3", description: "Small section heading", icon: "textformat.size.smaller", markdownPrefix: "### "),
        SlashCommandItem(title: "Bullet List", description: "Create a simple bulleted list", icon: "list.bullet", markdownPrefix: "- "),
        SlashCommandItem(title: "Numbered List", description: "Create an ordered list", icon: "list.number", markdownPrefix: "1. "),
        SlashCommandItem(title: "Task List", description: "Track tasks with a checkbox", icon: "checkmark.square", markdownPrefix: "- [ ] "),
        SlashCommandItem(title: "Blockquote", description: "Capture a quote or highlight text", icon: "text.quote", markdownPrefix: "> "),
        SlashCommandItem(title: "Code Block", description: "Insert a fenced code block", icon: "curlybraces", markdownPrefix: "```\n\n```"),
        SlashCommandItem(title: "Divider", description: "Insert a horizontal rule", icon: "minus", markdownPrefix: "---\n"),
        SlashCommandItem(title: "Bold Text", description: "Emphasize text with bold styling", icon: "bold", markdownPrefix: "**Bold**"),
        SlashCommandItem(title: "Italic Text", description: "Italicize text for emphasis", icon: "italic", markdownPrefix: "*Italic*"),
        SlashCommandItem(title: "Strikethrough", description: "Cross out text", icon: "strikethrough", markdownPrefix: "~~Strikethrough~~"),
        SlashCommandItem(title: "Highlight", description: "Highlight text", icon: "highlighter", markdownPrefix: "==Highlight==")
    ]
}

struct SlashCommandMenuView: View {
    let filterText: String
    @Binding var selectedIndex: Int
    let onSelect: (SlashCommandItem) -> Void

    var filteredItems: [SlashCommandItem] {
        if filterText.isEmpty {
            return SlashCommandProvider.items
        }
        return SlashCommandProvider.items.filter { item in
            item.title.localizedCaseInsensitiveContains(filterText) ||
            item.description.localizedCaseInsensitiveContains(filterText)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Insert")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 4)

            if filteredItems.isEmpty {
                Text("No matching formatting options")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(12)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 2) {
                            ForEach(Array(filteredItems.enumerated()), id: \.element.id) {
 index,
 item in
                                Button(action: { onSelect(item) }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: item.icon)
                                            .font(.system(size: 14))
                                            .frame(width: 24, height: 24)
                                            .background(
                                                (
                                                    index == selectedIndex
                                                ) ? Color.accentColor : Color.primary
                                                    .opacity(0.06)
                                            )
                                            .cornerRadius(6)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.title)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.primary)

                                            if index == selectedIndex {
                                                Text(item.description)
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.secondary)
                                            }
                                        }

                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
//                                    .background(index == selectedIndex ? Color.accentColor.opacity(0.5) : Color.clear, .rect(cornerRadius: 16))
//                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                                .if(index == selectedIndex) { view in
                                    view
                                        .glassEffect(
                                            in: .rect(cornerRadius: 16)
                                        )
                                        .foregroundStyle(.primary)
                                }
                                .id(index)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
                    }
                    .frame(maxHeight: 240)
                    .onChange(of: selectedIndex) { _, newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(width: 280)
        .glassEffect(in: .rect(cornerRadius: 16))
//        .background(VisualEffectBlur(material: .menu, blendingMode: .behindWindow))
//        .cornerRadius(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
//        )
//        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
