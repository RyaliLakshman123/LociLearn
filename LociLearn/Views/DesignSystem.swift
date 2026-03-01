//
//  DesignSystem.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 22/02/26.
//


import SwiftUI

// MARK: - Brand Palette
extension Color {
    static let brand       = Color(red: 0.42, green: 0.36, blue: 1.00)
    static let brandSoft   = Color(red: 0.60, green: 0.54, blue: 1.00)
    static let surface0    = Color(red: 0.05, green: 0.05, blue: 0.09)
    static let surface1    = Color(red: 0.09, green: 0.09, blue: 0.16)
    static let surface2    = Color(red: 0.13, green: 0.13, blue: 0.22)
    static let textSub     = Color(white: 0.55)
    static let textMuted   = Color(white: 0.32)
    static let success     = Color(red: 0.20, green: 0.85, blue: 0.57)
    static let danger      = Color(red: 1.00, green: 0.36, blue: 0.36)
    static let warn        = Color(red: 1.00, green: 0.78, blue: 0.24)
}

// MARK: - Card Modifier
struct CardStyle: ViewModifier {
    var radius: CGFloat = 20
    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.surface1)
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }
}
extension View {
    func cardStyle(radius: CGFloat = 20) -> some View { modifier(CardStyle(radius: radius)) }
}

// MARK: - Row Divider
struct RowDivider: View {
    var body: some View {
        Rectangle().fill(Color.white.opacity(0.05)).frame(height: 1).padding(.horizontal, 18)
    }
}

// MARK: - Brand Button
struct BrandButton: View {
    let title: String; let icon: String?; let isLoading: Bool; let action: () -> Void
    init(_ t: String, icon: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        title = t; self.icon = icon; self.isLoading = isLoading; self.action = action
    }
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading { ProgressView().tint(.white) } else {
                    HStack(spacing: 8) {
                        Text(title).font(.system(size: 16, weight: .semibold, design: .rounded))
                        if let icon { Image(systemName: icon).font(.system(size: 14, weight: .bold)) }
                    }.foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity).frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.brand)
                    .shadow(color: Color.brand.opacity(0.50), radius: 22, x: 0, y: 8)
            )
        }
        .buttonStyle(ScaleButtonStyle()).disabled(isLoading)
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Safe subscript
extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}

// MARK: - Answer State
enum AnswerButtonState: Equatable { case idle, correct, wrong, dimmed }
