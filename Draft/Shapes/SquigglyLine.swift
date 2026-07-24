//
//  SquigglyLine.swift
//  Draft
//
//  Created by Sameera Sandakelum on 2026-07-23.
//

import SwiftUI

/// A sine-wave underline Shape, used as the title divider in the editor.
struct SquigglyLine: Shape {
    var amplitude: CGFloat = 2.0
    var wavelength: CGFloat = 25

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        var x: CGFloat = rect.minX
        while x <= rect.maxX {
            let y = rect.midY + amplitude * sin((x / wavelength) * .pi * 2)
            path.addLine(to: CGPoint(x: x, y: y))
            x += 1
        }
        return path
    }
}
