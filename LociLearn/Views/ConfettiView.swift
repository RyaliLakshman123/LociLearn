//
//  ConfettiView.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 22/02/26.
//

//
//  ConfettiView.swift
//  LociLearn
//

import SwiftUI

struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(0..<80, id: \.self) { i in
                ConfettiPiece(index: i)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct ConfettiPiece: View {
    let index: Int

    @State private var yOffset: CGFloat  = 0
    @State private var xOffset: CGFloat  = 0
    @State private var opacity: Double   = 1
    @State private var rotation: Double  = 0
    @State private var scale: CGFloat    = 0

    // Fixed properties per piece
    private let color:    Color
    private let size:     CGFloat
    private let startX:   CGFloat
    private let startY:   CGFloat
    private let driftX:   CGFloat
    private let duration: Double
    private let delay:    Double
    private let shape:    Int     // 0=circle, 1=rect, 2=star, 3=diamond

    init(index: Int) {
        self.index = index

        let colors: [Color] = [
            Color(red: 0.42, green: 0.36, blue: 1.00),  // violet
            Color(red: 0.20, green: 0.85, blue: 0.57),  // green
            Color(red: 1.00, green: 0.78, blue: 0.24),  // yellow
            Color(red: 1.00, green: 0.36, blue: 0.36),  // red
            Color(red: 0.60, green: 0.54, blue: 1.00),  // soft violet
            Color(red: 0.30, green: 0.85, blue: 1.00),  // cyan
            Color(red: 1.00, green: 0.50, blue: 0.80),  // pink
            .white,
        ]

        self.color    = colors[index % colors.count]
        self.size     = CGFloat.random(in: 7...16)
        self.startX   = CGFloat.random(in: -200...200)
        self.startY   = CGFloat.random(in: -80...80)   // burst from slightly different heights
        self.driftX   = CGFloat.random(in: -80...80)
        self.duration = Double.random(in: 2.2...4.0)
        self.delay    = Double.random(in: 0...1.0)
        self.shape    = index % 4
    }

    var body: some View {
        pieceShape
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .offset(x: startX + xOffset, y: startY + yOffset)
            .opacity(opacity)
            .onAppear {
                // Pop in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(delay)) {
                    scale = 1
                }
                // Fall down
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeIn(duration: duration)) {
                        yOffset = 950
                        xOffset = driftX
                    }
                    // Fade out in last 30% of animation
                    withAnimation(.easeIn(duration: duration * 0.3)
                        .delay(duration * 0.7)) {
                        opacity = 0
                    }
                    // Spin continuously
                    withAnimation(.linear(duration: duration * 0.6)
                        .repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            }
    }

    @ViewBuilder
    private var pieceShape: some View {
        switch shape {
        case 0:
            // Circle
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        case 1:
            // Rectangle
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(color)
                .frame(width: size * 0.6, height: size * 1.6)
        case 2:
            // Diamond
            Rectangle()
                .fill(color)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(45))
        default:
            // Star-ish (small circle cluster)
            Circle()
                .fill(color.opacity(0.9))
                .frame(width: size * 1.2, height: size * 0.5)
        }
    }
}

#Preview {
    ZStack {
        Color.surface0.ignoresSafeArea()
        ConfettiView()
    }
}

