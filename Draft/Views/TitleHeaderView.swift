//
//  TitleHeaderView.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI

struct TitleHeaderView: View {
    @Binding var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Untitled", text: $title)
                .font(.system(size: 48, weight: .semibold))
                .textFieldStyle(.plain)
                .padding(.top, 64)
                .padding(.trailing, 32)

            SquigglyLine()
                .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
                .frame(height: 6)
                .padding(.trailing, 32)
                .padding(.top, 6)
                .padding(.bottom, 24)
        }
    }
}
