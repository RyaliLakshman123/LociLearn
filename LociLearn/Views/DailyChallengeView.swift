//
//  DailyChallengeView.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 22/02/26.
//


import SwiftUI

struct DailyChallengeView: View {

    @StateObject private var viewModel = QuestionViewModel()
    @State private var dailySubject: Subject = .biology
    @State private var navigateToQuiz = false
    @State private var showConfetti   = false

    var body: some View {
        ZStack {
            // ── Background ──
            AppBackgroundView()

            // ── Main content ──
            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle().fill(Color.warn.opacity(0.15)).frame(width: 80, height: 80)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 34)).foregroundStyle(Color.warn)
                }

                VStack(spacing: 8) {
                    Text("Daily Challenge")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("5 questions · Medium · Rotates daily")
                        .font(.system(size: 14)).foregroundStyle(Color.textSub)
                }

                HStack(spacing: 12) {
                    DailyStatChip(icon: "questionmark.circle.fill", label: "5 Questions", color: Color.brand)
                    DailyStatChip(icon: "dial.medium.fill",         label: "Medium",      color: Color.warn)
                    DailyStatChip(icon: "arrow.2.circlepath",       label: "Daily Reset", color: Color.success)
                }

                Spacer()

                if viewModel.isLoading {
                    ProgressView().tint(Color.brand).scaleEffect(1.3)
                } else {
                    Button {
                        guard !viewModel.hasCompletedDaily else { return }
                        navigateToQuiz = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: viewModel.hasCompletedDaily ? "checkmark.seal.fill" : "bolt.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text(viewModel.hasCompletedDaily ? "Completed Today" : "Start Challenge")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(viewModel.hasCompletedDaily ? Color.textSub : .white)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(viewModel.hasCompletedDaily ? Color.surface2 : Color.warn)
                                .shadow(color: viewModel.hasCompletedDaily ? .clear : Color.warn.opacity(0.40), radius: 18, x: 0, y: 6)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(viewModel.hasCompletedDaily)

//                    // TESTING ONLY - remove after confetti works
//                    Button("Reset Daily (Testing)") {
//                        viewModel.resetDailyForTesting()
//                    }
//                    .foregroundStyle(Color.danger)
//                    .font(.caption)
                }
            }
            .padding(.horizontal, 24).padding(.bottom, 40)

            // ── Confetti LAST so it renders on top ──
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

        } // ← ZStack closes here
        .navigationTitle("Daily")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToQuiz) {
            NormalQuizView(
                   viewModel: QuestionViewModel(),
                   subject: .biology,
                   difficulty: "easy",
                   count: 10
               )
        }
        .onReceive(viewModel.$showConfetti) { value in
            if value {
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    showConfetti = false
                    viewModel.showConfetti = false
                }
            }
        }
        .onAppear {
            startDailyChallenge()
        }
    }

    private func startDailyChallenge() {
        let subjects: [Subject] = [.biology, .computerScience]
        let index = Calendar.current.component(.day, from: Date()) % subjects.count
        dailySubject = subjects[index]

        viewModel.startSubjectMode(dailySubject)
        viewModel.questions = Array(viewModel.questions.prefix(5))
    }
}

// MARK: - Daily Stat Chip
struct DailyStatChip: View {
    let icon: String; let label: String; let color: Color
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 11)).foregroundStyle(color)
            Text(label).font(.system(size: 11, weight: .medium)).foregroundStyle(Color.textSub)
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
        .background(Color.surface1)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.07), lineWidth: 1))
    }
}

#Preview {
    NavigationStack {
        DailyChallengeView()
    }
}
