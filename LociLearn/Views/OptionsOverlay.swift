//
//  OptionsOverlay.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 21/02/26.
//

import SwiftUI

// MARK: - Answer State Enum (top-level to avoid Swift access issues)
enum AnswerButtonState: Equatable {
    case idle, correct, wrong, dimmed
}

// MARK: - Options Overlay

struct OptionsOverlay: View {

    @ObservedObject var viewModel: QuestionViewModel

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 0) {

                // ── Header ──
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 16))
                            .foregroundStyle(.blue)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Choose your answer")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Score badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("\(viewModel.score)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.yellow.opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 14)

                Divider()
                    .padding(.horizontal, 16)

                // ── Options ──
                VStack(spacing: 9) {
                    ForEach(Array((viewModel.currentQuestion?.options ?? []).enumerated()),
                            id: \.offset) { index, option in
                        OptionButton(
                            option: option,
                            label: ["A", "B", "C", "D"][safe: index] ?? "?",
                            state: buttonState(for: option),
                            action: { viewModel.selectAnswer(option) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: -6)
            .padding(.horizontal, 12)
            .padding(.bottom, 20)
        }
    }

    private func buttonState(for option: String) -> AnswerButtonState {
        guard let selected = viewModel.selectedAnswer else { return .idle }
        if option == viewModel.correctAnswer { return .correct }
        if option == selected { return .wrong }
        return .dimmed
    }
}

// MARK: - Option Button

struct OptionButton: View {

    let option: String
    let label: String
    let state: AnswerButtonState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Letter badge
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(badgeBackground)
                        .frame(width: 34, height: 34)
                    Text(label)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(badgeColor)
                }

                Text(option)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                // Result icon
                Group {
                    if state == .correct {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    } else if state == .wrong {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.title3)
                    }
                }
                .transition(.scale(scale: 0.5).combined(with: .opacity))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(rowBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(state != .idle)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: state)
    }

    // MARK: Style helpers

    private var badgeBackground: Color {
        switch state {
        case .idle:    return Color.blue.opacity(0.12)
        case .correct: return Color.green.opacity(0.2)
        case .wrong:   return Color.red.opacity(0.2)
        case .dimmed:  return Color.gray.opacity(0.1)
        }
    }

    private var badgeColor: Color {
        switch state {
        case .idle:    return .blue
        case .correct: return .green
        case .wrong:   return .red
        case .dimmed:  return .gray
        }
    }

    private var rowBackground: some ShapeStyle {
        switch state {
        case .idle:    return AnyShapeStyle(Color.primary.opacity(0.04))
        case .correct: return AnyShapeStyle(Color.green.opacity(0.1))
        case .wrong:   return AnyShapeStyle(Color.red.opacity(0.1))
        case .dimmed:  return AnyShapeStyle(Color.gray.opacity(0.04))
        }
    }

    private var borderColor: Color {
        switch state {
        case .idle:    return Color.primary.opacity(0.08)
        case .correct: return .green
        case .wrong:   return .red
        case .dimmed:  return Color.clear
        }
    }

    private var textColor: Color {
        switch state {
        case .dimmed: return .secondary
        default:      return .primary
        }
    }
}

// MARK: - Safe Array Index

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
