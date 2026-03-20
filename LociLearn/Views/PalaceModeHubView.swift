//
//  PalaceModeHubView.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 24/02/26.
//


import SwiftUI

struct PalaceModeHubView: View {

    @State private var appeared = false

    var body: some View {
        ZStack {
            AppBackgroundView()
            StarFieldBackground()

            VStack(spacing: 0) {
                // ── Hero ──
                VStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color.brand.opacity(0.15)).frame(width: 76, height: 76)
                        Circle().strokeBorder(Color.brand.opacity(0.28), lineWidth: 1).frame(width: 76, height: 76)
                        Image(systemName: "arkit")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(Color.brand)
                    }
                    Text("AR Palace")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Choose your learning world")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSub)
                }
                .padding(.top, 60)
                .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : -16)
                .animation(.spring(response: 0.65, dampingFraction: 0.80).delay(0.05), value: appeared)

                Spacer()

                // ── Cards ──
                VStack(spacing: 12) {
                    NavigationLink {
                        PlanetSelectionView(viewModel: QuestionViewModel())
                    } label: {
                        PalaceCard(title: "Solar System", subtitle: "Explore all 8 planets in AR",
                                   icon: "globe.europe.africa.fill", color: Color.brand)
                    }
                    .buttonStyle(.plain)  // 👈 changed from ScaleButtonStyle
                    .opacity(appeared ? 1 : 0).offset(x: appeared ? 0 : 24)
                    .animation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.22), value: appeared)

                    NavigationLink {
                        SubjectLearnView(subject: .biology)
                    } label: {
                        PalaceCard(title: "Biology", subtitle: "Animal Cell · 15 questions",
                                   icon: "allergens", color: Color(red: 0.18, green: 0.78, blue: 0.45))
                    }
                    .buttonStyle(.plain)  // 👈 changed
                    .opacity(appeared ? 1 : 0).offset(x: appeared ? 0 : 24)
                    .animation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.31), value: appeared)

                    NavigationLink {
                        SubjectLearnView(subject: .computerScience)
                    } label: {
                        PalaceCard(title: "Computer Science", subtitle: "Motherboard · 15 questions",
                                   icon: "cpu.fill", color: Color(red: 0.18, green: 0.60, blue: 0.96))
                    }
                    .buttonStyle(.plain)  // 👈 changed
                    .opacity(appeared ? 1 : 0).offset(x: appeared ? 0 : 24)
                    .animation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.40), value: appeared)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onAppear {
            appeared = true
            NotificationCenter.default.post(name: .reinjectEmoji, object: nil)  // 👈 add
        }
    }
}

// MARK: - Palace Card
struct PalaceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(color.opacity(0.18)).frame(width: 56, height: 56)
                Circle().strokeBorder(color.opacity(0.40), lineWidth: 1).frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSub)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.textSub)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.surface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(color.opacity(0.20), lineWidth: 1)
                )
        )
    }
}

#Preview {
    PalaceModeHubView()
}
