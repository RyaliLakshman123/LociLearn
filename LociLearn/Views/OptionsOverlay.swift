//
//  OptionsOverlay.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 21/02/26.
//


import SwiftUI

struct OptionsOverlay: View {
    @ObservedObject var viewModel: QuestionViewModel
    @State private var appeared = false

    private var isARMode: Bool {
        viewModel.arModeActive
    }

    private var currentQuestion: Question? {
        if isARMode {
            guard viewModel.arQuestions.indices.contains(viewModel.currentARQuestionIndex) else { return nil }
            return viewModel.arQuestions[viewModel.currentARQuestionIndex]
        } else {
            return viewModel.currentQuestion
        }
    }
    
    private var progressValue: Double {
        if isARMode {
            guard totalCount > 0 else { return 0 }
            return Double(currentIndex) / Double(totalCount)
        } else {
            return viewModel.progress
        }
    }
    
    private var currentIndex: Int {
        isARMode ? viewModel.currentARQuestionIndex : viewModel.currentQuestionIndex
    }

    private var totalCount: Int {
        isARMode ? viewModel.arQuestions.count : viewModel.questions.count
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {

                // Drag pill
                Capsule().fill(Color.white.opacity(0.18)).frame(width: 36, height: 4)
                    .padding(.top, 12).padding(.bottom, 14)

                // ── Header ──
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Color.brand.opacity(0.20)).frame(width: 40, height: 40)
                        Circle().strokeBorder(Color.brand.opacity(0.30), lineWidth: 1).frame(width: 40, height: 40)
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 17, weight: .semibold)).foregroundStyle(Color.brand)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Choose your answer")
                            .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(.white)
                        Text("Question \(currentIndex + 1) of \(totalCount)")
                            .font(.system(size: 11)).foregroundStyle(Color.textSub)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").font(.system(size: 10)).foregroundStyle(Color.warn)
                        Text("\(viewModel.score)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.white.opacity(0.10)).clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.brand.opacity(0.35), lineWidth: 1))
                }
                .padding(.horizontal, 18).padding(.bottom, 12)

                // Progress strip
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.white.opacity(0.06))
                        Rectangle()
                            .fill(LinearGradient(colors: [Color.brandSoft, Color.brand],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progressValue)
                            .animation(.spring(response: 0.5), value: viewModel.progress)
                    }
                }.frame(height: 2)

                // ── Options ──
                VStack(spacing: 9) {
                    ForEach(Array((currentQuestion?.options ?? []).enumerated()), id: \.offset) { i, opt in
                        AROptionButton(
                            option: opt,
                            label: ["A","B","C","D"][safe: i] ?? "?",
                            state: buttonState(for: opt)
                        ) {
                            if isARMode {
                                viewModel.selectARAnswer(opt)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    viewModel.advanceARQuestion()
                                    viewModel.isCardFlipped = false
                                    viewModel.refreshCardTrigger.toggle()
                                }
                            } else {
                                viewModel.selectAnswer(opt)
                            }
                        }
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 14)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(i) * 0.07), value: appeared)
                    }
                }
                .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 22)
            }
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(.ultraThinMaterial).environment(\.colorScheme, .dark)
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color(red: 0.07, green: 0.06, blue: 0.15).opacity(0.78))
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: .black.opacity(0.50), radius: 44, x: 0, y: -12)
            .padding(.horizontal, 10).padding(.bottom, 26)
        }
        .onAppear { appeared = true }
    }

    private func buttonState(for option: String) -> AnswerButtonState {
        guard let sel = viewModel.selectedAnswer else { return .idle }
        if option == currentQuestion?.correctAnswer { return .correct }
        if option == sel { return .wrong }
        return .dimmed
    }
}

// MARK: - AR Option Button
struct AROptionButton: View {
    let option: String; let label: String; let state: AnswerButtonState; let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(badgeBg).frame(width: 34, height: 34)
                    Text(label).font(.system(size: 13, weight: .black, design: .rounded)).foregroundStyle(badgeFg)
                }
                Text(option)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(state == .dimmed ? Color.textMuted : Color.white.opacity(0.92))
                    .multilineTextAlignment(.leading).lineLimit(2)
                Spacer()
                Group {
                    if state == .correct {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 20)).foregroundStyle(Color.success)
                            .transition(.scale(scale: 0.2).combined(with: .opacity))
                    } else if state == .wrong {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(Color.danger)
                            .transition(.scale(scale: 0.2).combined(with: .opacity))
                    }
                }.animation(.spring(response: 0.35, dampingFraction: 0.65), value: state)
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(rowBg)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(state != .idle)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: state)
    }

    private var badgeBg: Color {
        switch state {
        case .idle:    return Color.brand.opacity(0.18)
        case .correct: return Color.success.opacity(0.22)
        case .wrong:   return Color.danger.opacity(0.22)
        case .dimmed:  return Color.white.opacity(0.05)
        }
    }
    private var badgeFg: Color {
        switch state {
        case .idle:    return Color.brandSoft
        case .correct: return Color.success
        case .wrong:   return Color.danger
        case .dimmed:  return Color.textMuted
        }
    }
    private var rowBg: some ShapeStyle {
        switch state {
        case .idle:    return AnyShapeStyle(Color.white.opacity(0.07))
        case .correct: return AnyShapeStyle(Color.success.opacity(0.12))
        case .wrong:   return AnyShapeStyle(Color.danger.opacity(0.12))
        case .dimmed:  return AnyShapeStyle(Color.white.opacity(0.02))
        }
    }
    private var borderColor: Color {
        switch state {
        case .idle:    return Color.white.opacity(0.12)
        case .correct: return Color.success.opacity(0.60)
        case .wrong:   return Color.danger.opacity(0.60)
        case .dimmed:  return Color.clear
        }
    }
}
