//
//  HistoryView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 22/02/26.
//

import SwiftUI

// MARK: - History View

struct HistoryView: View {

    @ObservedObject var viewModel: QuestionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.allTimeAnsweredQuestions.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No answered questions yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Place a card in AR and start answering!")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Summary card
                            SummaryBannerView(viewModel: viewModel)
                                .padding(.horizontal, 16)
                                .padding(.top, 4)

                            // Answered questions
                            ForEach(Array(viewModel.allTimeAnsweredQuestions.enumerated()), id: \.element.id) { index, answered in
                                HistoryCard(index: index + 1, answered: answered)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Summary Banner

private struct SummaryBannerView: View {

    @ObservedObject var viewModel: QuestionViewModel

    private var accuracy: Int {
        guard !viewModel.allTimeAnsweredQuestions.isEmpty else { return 0 }
        let correct = viewModel.allTimeAnsweredQuestions.filter(\.isCorrect).count
        return Int((Double(correct) / Double(viewModel.allTimeAnsweredQuestions.count)) * 100)
    }

    var body: some View {
        HStack(spacing: 0) {
            statCell(value: "\(viewModel.score)", label: "Score", icon: "star.fill", color: .yellow)
            Divider().frame(height: 40)
            statCell(value: "\(viewModel.allTimeAnsweredQuestions.count)", label: "Answered", icon: "checkmark.circle", color: .blue)
            Divider().frame(height: 40)
            statCell(value: "\(accuracy)%", label: "Accuracy", icon: "chart.pie.fill", color: .green)
        }
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - History Card

private struct HistoryCard: View {

    let index: Int
    let answered: AnsweredQuestion
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Question row
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // Index + result badge
                    ZStack {
                        Circle()
                            .fill(answered.isCorrect ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                            .frame(width: 38, height: 38)
                        Text("\(index)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(answered.isCorrect ? .green : .red)
                    }

                    Text(answered.question.question)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : 2)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            // Expanded answer detail
            if isExpanded {
                Divider().padding(.horizontal, 14)

                VStack(spacing: 8) {
                    ForEach(answered.question.options, id: \.self) { option in
                        HistoryOptionRow(
                            option: option,
                            correctAnswer: answered.question.correctAnswer,
                            selectedAnswer: answered.selectedAnswer
                        )
                    }
                }
                .padding(14)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    answered.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - History Option Row

private struct HistoryOptionRow: View {

    let option: String
    let correctAnswer: String
    let selectedAnswer: String

    private var isCorrect: Bool { option == correctAnswer }
    private var wasSelected: Bool { option == selectedAnswer }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : (wasSelected ? "xmark.circle.fill" : "circle"))
                .font(.system(size: 16))
                .foregroundStyle(isCorrect ? .green : (wasSelected ? .red : Color.secondary.opacity(0.4)))

            Text(option)
                .font(.system(size: 14))
                .foregroundStyle(isCorrect ? .green : (wasSelected ? .red : .secondary))

            if isCorrect {
                Text("Correct")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
            }

            if wasSelected && !isCorrect {
                Text("Your answer")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            isCorrect ? Color.green.opacity(0.06) : (wasSelected ? Color.red.opacity(0.06) : Color.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Quiz Complete View

struct QuizCompleteView: View {

    @ObservedObject var viewModel: QuestionViewModel
    @Environment(\.dismiss) private var dismiss

    private var correctCount: Int { viewModel.answeredQuestions.filter(\.isCorrect).count }
    private var total: Int { viewModel.answeredQuestions.count }
    private var accuracy: Int {
        guard total > 0 else { return 0 }
        return Int(Double(correctCount) / Double(total) * 100)
    }

    private var grade: (label: String, color: Color, icon: String) {
        switch accuracy {
        case 90...100: return ("Excellent!", .green, "trophy.fill")
        case 70...89:  return ("Great Job!", .blue, "star.fill")
        case 50...69:  return ("Good Try!", .orange, "hand.thumbsup.fill")
        default:       return ("Keep Going!", .red, "flame.fill")
        }
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Grade icon
            ZStack {
                Circle()
                    .fill(grade.color.opacity(0.15))
                    .frame(width: 110, height: 110)
                Image(systemName: grade.icon)
                    .font(.system(size: 46))
                    .foregroundStyle(grade.color)
            }

            VStack(spacing: 6) {
                Text(grade.label)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("Quiz Complete")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            // Stats
            HStack(spacing: 20) {
                completeStat(value: "\(correctCount)/\(total)", label: "Correct", color: .green)
                completeStat(value: "\(accuracy)%", label: "Accuracy", color: .blue)
                completeStat(value: "\(viewModel.score)", label: "Points", color: .yellow)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    dismiss()
                    viewModel.showHistory = true
                } label: {
                    Label("Review Answers", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue.opacity(0.12))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .fontWeight(.semibold)
                }

                Button {
                    viewModel.currentQuestionIndex = 0
                    viewModel.score = 0
                    viewModel.answeredQuestions = []
                    dismiss()
                } label: {
                    Label("Play Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func completeStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
