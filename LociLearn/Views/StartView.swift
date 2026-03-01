//
//  StartView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 22/02/26.
//


import SwiftUI

// MARK: - Difficulty Model

struct DifficultyOption: Identifiable {
    let id:    String
    let label: String
    let icon:  String
    let color: Color
}

let difficultyOptions: [DifficultyOption] = [
    DifficultyOption(id: "easy",   label: "Easy",   icon: "tortoise.fill", color: Color.success),
    DifficultyOption(id: "medium", label: "Medium", icon: "hare.fill",     color: Color.warn),
    DifficultyOption(id: "hard",   label: "Hard",   icon: "flame.fill",    color: Color.danger),
]

// MARK: - StartView

struct StartView: View {
    @ObservedObject var startVM: StartViewModel
    @ObservedObject var quizVM:  QuestionViewModel
    @State private var navigate  = false
    @State private var appeared  = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                StarFieldBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        heroSection
                        subjectSection
                        difficultyAndCountRow
                        modeSection
                        dailyChallengeRow
                        startButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                    .redacted(reason: startVM.isLoading ? .placeholder : [])
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigate) {
                destinationView
            }
            .onAppear {
                appeared = true
                NotificationCenter.default.post(name: .reinjectEmoji, object: nil)
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 12) {
            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.brand.opacity(0.30), Color.brand.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(Color.white)
            }
            .shadow(color: Color.brand.opacity(0.35), radius: 20, y: 8)
            .padding(.top, 56)
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.05), value: appeared)

            // Title + tagline
            VStack(spacing: 5) {
                Text("LociLearn")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(-0.8)

                Text("Spatial memory, made simple.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.textSub)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)
            .animation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.14), value: appeared)

            // Pill row
            HStack(spacing: 8) {
                TagPill(icon: "sparkles",         label: "AI-Powered")
                TagPill(icon: "arkit",            label: "AR Mode")
                TagPill(icon: "building.columns", label: "Memory Palace")
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.22), value: appeared)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    // MARK: - Subject

    private var subjectSection: some View {
        SectionCard(
            label: "SUBJECT",
            icon: "book.closed.fill",
            iconColor: Color(red: 0.4, green: 0.6, blue: 1.0)
        ) {
            HStack(spacing: 0) {
                ForEach(Subject.allCases) { subject in
                    SubjectSegment(
                        subject: subject,
                        isSelected: startVM.selectedSubject == subject
                    ) {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                            startVM.selectedSubject = subject
                        }
                    }
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .staggerAppear(appeared: appeared, delay: 0.18)
    }

    // MARK: - Difficulty + Count side by side

    private var difficultyAndCountRow: some View {
        HStack(spacing: 12) {
            // Difficulty card
            SectionCard(label: "DIFFICULTY", icon: "dial.medium.fill", iconColor: Color.warn) {
                VStack(spacing: 6) {
                    ForEach(difficultyOptions) { opt in
                        DifficultyRow(option: opt, isSelected: startVM.selectedDifficulty == opt.id) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.72)) {
                                startVM.selectedDifficulty = opt.id
                            }
                        }
                    }
                }
            }
            .staggerAppear(appeared: appeared, delay: 0.24)
            .frame(minWidth: 0, maxWidth: .infinity)

            // Count card
            SectionCard(label: "QUESTION", icon: "list.number", iconColor: Color.success) {
                VStack(spacing: 16) {
                    Text("\(startVM.questionCount)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentTransition(.numericText())

                    HStack(spacing: 8) {
                        // Minus
                        CircleStepBtn(icon: "minus", enabled: startVM.questionCount > 5) {
                            if startVM.questionCount > 5 {
                                withAnimation(.spring(response: 0.2)) { startVM.questionCount -= 1 }
                            }
                        }
                        // Plus
                        CircleStepBtn(icon: "plus", enabled: startVM.questionCount < 20) {
                            if startVM.questionCount < 20 {
                                withAnimation(.spring(response: 0.2)) { startVM.questionCount += 1 }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .staggerAppear(appeared: appeared, delay: 0.28)
            .frame(width: 120)
        }
    }

    // MARK: - Mode
    private var modeSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("LEARNING MODE")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(Color.textMuted)
                    .kerning(1.1)
                Spacer()
            }

            ForEach(Array(QuizMode.allCases.enumerated()), id: \.element) { i, mode in
                ModeTile(
                    mode: mode,
                    isSelected: startVM.selectedMode == mode
                ) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                        startVM.selectedMode = mode
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
                .animation(
                    .spring(response: 0.55, dampingFraction: 0.8).delay(0.32 + Double(i) * 0.08),
                    value: appeared
                )
            }
        }
    }

    // MARK: - Daily Challenge

    private var dailyChallengeRow: some View {
        NavigationLink { DailyChallengeView() } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.brand.opacity(0.18))
                        .frame(width: 46, height: 46)
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.brand)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Challenge")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Fresh set · Resets at midnight")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSub)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.surface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.brand.opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.50), value: appeared)
    }

    // MARK: - CTA

    private var startButton: some View {
        BrandButton("Start Learning", icon: "arrow.right", isLoading: startVM.isLoading) {
            Task { await startVM.startQuiz(with: quizVM); navigate = true }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.56), value: appeared)
    }

    // MARK: - Destination
    @ViewBuilder private var destinationView: some View {
        if startVM.selectedMode == .normal {
            NormalQuizView(
                viewModel: quizVM,
                subject: startVM.selectedSubject,
                difficulty: startVM.selectedDifficulty,
                count: startVM.questionCount
            )
            .onDisappear {
                // Timer in MainTabView handles emoji restoration automatically
            }
        } else {
            PalaceModeHubView()
                .onDisappear {
                    // Timer in MainTabView handles emoji restoration automatically
                }
        }
    }
} // end StartView

// MARK: - View Extension: stagger helper

private extension View {
    func staggerAppear(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(.spring(response: 0.6, dampingFraction: 0.82).delay(delay), value: appeared)
    }
}

// MARK: - SectionCard

struct SectionCard<Content: View>: View {
    let label:     String
    let icon:      String
    let iconColor: Color
    let content:   Content

    init(label: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.label     = label
        self.icon      = icon
        self.iconColor = iconColor
        self.content   = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Row label
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(iconColor.opacity(0.18))
                        .frame(width: 18, height: 18)
                    Image(systemName: icon)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(iconColor)
                }
                Text(label)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(Color.textMuted)
                    .kerning(1.0)
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.surface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.20), radius: 12, y: 4)
    }
} // end SectionCard

// MARK: - TagPill

struct TagPill: View {
    let icon:  String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.brand)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.textSub)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.06))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 0.8))
        )
    }
} // end TagPill

// MARK: - SubjectSegment

struct SubjectSegment: View {
    let subject:    Subject
    let isSelected: Bool
    let onTap:      () -> Void

    private var accent: Color {
        switch subject {
        case .biology:         return Color.success
        case .computerScience: return Color.brand
        case .solar:           return Color.warn
        }
    }

    var body: some View {
        Button(action: onTap) {
            Text(subject.title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundStyle(isSelected ? .white : Color.textSub)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(segmentBG)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var segmentBG: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(accent)
                .shadow(color: accent.opacity(0.4), radius: 8, y: 3)
        } else {
            Color.clear
        }
    }
} // end SubjectSegment

// MARK: - DifficultyRow

struct DifficultyRow: View {
    let option:     DifficultyOption
    let isSelected: Bool
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: option.icon)
                    .font(.system(size: 13))
                    .foregroundStyle(isSelected ? option.color : Color.textSub)
                    .frame(width: 18)

                Text(option.label)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white : Color.textSub)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                Spacer()

                if isSelected {
                    Circle()
                        .fill(option.color)
                        .frame(width: 7, height: 7)
                        .shadow(color: option.color.opacity(0.7), radius: 4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(rowBG)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var rowBG: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(option.color.opacity(0.13))
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .strokeBorder(option.color.opacity(0.30), lineWidth: 1)
                )
        } else {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.white.opacity(0.04))
        }
    }
} // end DifficultyRow

// MARK: - CircleStepBtn

struct CircleStepBtn: View {
    let icon:    String
    let enabled: Bool
    let action:  () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(enabled ? Color.brand.opacity(0.18) : Color.white.opacity(0.05))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                enabled ? Color.brand.opacity(0.35) : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(enabled ? Color.brand : Color.textMuted)
            }
        }
        .buttonStyle(.plain)
    }
} // end CircleStepBtn

// MARK: - ModeTile

struct ModeTile: View {
    let mode:       QuizMode
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? Color.brand.opacity(0.22) : Color.white.opacity(0.06))
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    isSelected ? Color.brand.opacity(0.40) : Color.white.opacity(0.06),
                                    lineWidth: 1
                                )
                        )
                    Image(systemName: mode.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(isSelected ? Color.white : Color.textSub)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(mode.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(mode.description)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSub)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.brand : Color.white.opacity(0.15),
                            lineWidth: isSelected ? 2 : 1.5
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.brand)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(14)
            .background(tileBG)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var tileBG: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.brand.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.brand.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: Color.brand.opacity(0.15), radius: 12, y: 4)
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.surface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        }
    }
} // end ModeTile

// MARK: - StartConfigSection (kept for external compatibility)

struct StartConfigSection<Content: View>: View {
    let label:   String
    let icon:    String
    let content: Content

    init(label: String, icon: String, @ViewBuilder content: () -> Content) {
        self.label   = label
        self.icon    = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.brand)
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.textMuted)
                    .kerning(1.0)
            }
            content
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
    }
} // end StartConfigSection

#Preview {
    StartView(startVM: StartViewModel(), quizVM: QuestionViewModel())
}
