//
//  ProfileSetupView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 28/02/26.
//


import SwiftUI

struct ProfileSetupView: View {

    @AppStorage("username") var username: String = ""
    @AppStorage("hasCompletedSetup") var hasCompletedSetup: Bool = false
    @AppStorage("selectedAvatar") var savedAvatar: Int = 0   // ← synced to MainTabView

    @State private var inputName       = ""
    @State private var selectedAvatar  = 0
    @State private var appeared        = false
    @State private var avatarBounce    = false
    @State private var isKeyboardUp    = false
    @FocusState private var nameFocused: Bool

    private let avatars = ["🚀", "🌌", "⭐", "🪐", "🔭", "🧠"]
    private let gradientColors: [Color] = [
        Color(red: 0.45, green: 0.18, blue: 0.95),
        Color(red: 0.28, green: 0.10, blue: 0.72)
    ]

    var displayName: String {
        let trimmed = inputName.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Explorer" : trimmed
    }

    var body: some View {
        ZStack {
            // Background — matches OnboardingView exactly
            Color(red: 0.05, green: 0.05, blue: 0.15)
                .ignoresSafeArea()

            StarfieldView()
                .ignoresSafeArea()

            // Ambient glows on top of stars
            ZStack {
                RadialGradient(
                    colors: [Color(red: 0.22, green: 0.06, blue: 0.55).opacity(0.45), .clear],
                    center: UnitPoint(x: 0.2, y: 0.2), startRadius: 0, endRadius: 380
                )
                RadialGradient(
                    colors: [Color(red: 0.04, green: 0.14, blue: 0.50).opacity(0.35), .clear],
                    center: UnitPoint(x: 0.85, y: 0.75), startRadius: 0, endRadius: 300
                )
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Top badge ──
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(Color(red: 0.72, green: 0.55, blue: 1.0))
                            Text("LOCILEARN · EXPLORER SETUP")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundStyle(Color(red: 0.72, green: 0.55, blue: 1.0))
                                .kerning(2)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.45, green: 0.20, blue: 0.95).opacity(0.18))
                                .overlay(Capsule().strokeBorder(
                                    Color(red: 0.55, green: 0.30, blue: 1.0).opacity(0.35), lineWidth: 0.8))
                        )
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1), value: appeared)
                    .padding(.top, 60)
                    .padding(.bottom, 32)

                    // ── Avatar picker ──
                    VStack(spacing: 20) {
                        // Selected avatar big display
                        ZStack {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [
                                        gradientColors[0].opacity(0.35),
                                        gradientColors[1].opacity(0.15),
                                        Color.clear
                                    ],
                                    center: .center, startRadius: 0, endRadius: 80
                                ))
                                .frame(width: 160, height: 160)

                            Circle()
                                .trim(from: 0.0, to: 0.6)
                                .stroke(
                                    AngularGradient(colors: [
                                        Color(red: 0.55, green: 0.30, blue: 1.0).opacity(0.0),
                                        Color(red: 0.55, green: 0.30, blue: 1.0).opacity(0.6),
                                        Color(red: 0.55, green: 0.30, blue: 1.0).opacity(0.0),
                                    ], center: .center),
                                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                                )
                                .frame(width: 130, height: 130)
                                .rotationEffect(.degrees(avatarBounce ? 360 : 0))
                                .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: avatarBounce)

                            Text(avatars[selectedAvatar])
                                .font(.system(size: 64))
                                .scaleEffect(avatarBounce ? 1.05 : 0.95)
                                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: avatarBounce)
                        }

                        // Avatar grid
                        HStack(spacing: 10) {
                            ForEach(Array(avatars.enumerated()), id: \.offset) { i, emoji in
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                        selectedAvatar = i
                                    }
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 22))
                                        .frame(width: 46, height: 46)
                                        .background(
                                            Circle()
                                                .fill(selectedAvatar == i
                                                      ? gradientColors[0].opacity(0.30)
                                                      : Color.white.opacity(0.06))
                                                .overlay(Circle().strokeBorder(
                                                    selectedAvatar == i
                                                    ? gradientColors[0].opacity(0.7)
                                                    : Color.white.opacity(0.10),
                                                    lineWidth: selectedAvatar == i ? 2 : 1))
                                        )
                                        .scaleEffect(selectedAvatar == i ? 1.12 : 1.0)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.85)
                    .animation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.2), value: appeared)

                    // ── Name input ──
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            // Live preview
                            Text("Hi, \(displayName)!")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.white, Color(red: 0.88, green: 0.78, blue: 1.0)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .animation(.spring(response: 0.3), value: displayName)

                            Text("Your name, your journey.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.35))
                        }
                        .padding(.top, 28)

                        // Text field
                        HStack(spacing: 12) {
                            Image(systemName: "pencil.line")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color(red: 0.72, green: 0.55, blue: 1.0))

                            TextField("", text: $inputName, prompt:
                                Text("Enter your name (optional)")
                                    .foregroundStyle(Color.white.opacity(0.25))
                            )
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .focused($nameFocused)
                            .submitLabel(.done)
                            .onSubmit { nameFocused = false }

                            if !inputName.isEmpty {
                                Button {
                                    withAnimation { inputName = "" }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.white.opacity(0.35))
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(
                                            nameFocused
                                            ? gradientColors[0].opacity(0.7)
                                            : Color.white.opacity(0.10),
                                            lineWidth: nameFocused ? 1.5 : 1
                                        )
                                )
                        )
                        .padding(.horizontal, 24)
                        .animation(.easeInOut(duration: 0.2), value: nameFocused)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.spring(response: 0.65, dampingFraction: 0.75).delay(0.30), value: appeared)

                    // ── Stats preview ──
                    HStack(spacing: 10) {
                        SetupStatPill(value: "0",   label: "XP",       icon: "bolt.fill",       color: Color(red: 1.0, green: 0.75, blue: 0.2))
                        SetupStatPill(value: "0",   label: "Streak",   icon: "flame.fill",      color: Color(red: 1.0, green: 0.45, blue: 0.2))
                        SetupStatPill(value: "---", label: "Explorer", icon: "person.fill",     color: Color(red: 0.55, green: 0.30, blue: 1.0))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.65, dampingFraction: 0.75).delay(0.38), value: appeared)

                    // ── CTA Button ──
                    Button {
                        nameFocused = false
                        let trimmed = inputName.trimmingCharacters(in: .whitespaces)
                        username = trimmed.isEmpty ? "Explorer" : trimmed
                        savedAvatar = selectedAvatar          // ← persist for tab bar
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            hasCompletedSetup = true
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Text(avatars[selectedAvatar])
                                .font(.system(size: 22))
                            Text("Begin Exploring")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                            Spacer()
                            ZStack {
                                Circle().fill(Color.white.opacity(0.15)).frame(width: 34, height: 34)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .black))
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                        )
                        .shadow(color: gradientColors[0].opacity(0.6), radius: 24, y: 10)
                    }
                    .buttonStyle(SetupButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 60)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.92)
                    .animation(.spring(response: 0.65, dampingFraction: 0.72).delay(0.45), value: appeared)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { nameFocused = false }
        }
        .onAppear {
            withAnimation { appeared = true }
            avatarBounce = true
        }
    }
}

// MARK: - Stat Pill
struct SetupStatPill: View {
    let value: String
    let label: String
    let icon:  String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(color.opacity(0.20), lineWidth: 0.8))
        )
    }
}

// MARK: - Button Style
struct SetupButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.68), value: configuration.isPressed)
    }
}

#Preview {
    ProfileSetupView()
}
