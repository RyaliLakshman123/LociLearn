////
////  StatsView.swift
////  LociLearn
////
////  Created by Sameer Nikhil on 22/02/26.
////
//
//
//import SwiftUI
//
//struct StatsView: View {
//    @ObservedObject var viewModel: QuestionViewModel
//    @Environment(\.dismiss) private var dismiss
//    @State private var appeared = false
//
//    private var total:   Int { viewModel.answeredQuestions.count }
//    private var correct: Int { viewModel.answeredQuestions.filter(\.isCorrect).count }
//    private var wrong:   Int { total - correct }
//    private var accuracy: Double { total > 0 ? Double(correct) / Double(total) : 0 }
//
//    // Accuracy ring colour
//    private var ringColor: Color {
//        if accuracy >= 0.75 { return .success }
//        if accuracy >= 0.45 { return .warn }
//        return .danger
//    }
//
//    var body: some View {
//        ZStack {
//            Color.surface0.ignoresSafeArea()
//
//            // Ambient top glow
//            RadialGradient(
//                colors: [Color.brand.opacity(0.12), Color.clear],
//                center: UnitPoint(x: 0.5, y: 0), startRadius: 0, endRadius: 340
//            ).ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 32) {
//
//                    // ── Accuracy Ring ──
//                    VStack(spacing: 18) {
//                        ZStack {
//                            // Track
//                            Circle()
//                                .stroke(Color.white.opacity(0.07), style: StrokeStyle(lineWidth: 18, lineCap: .round))
//
//                            // Fill
//                            Circle()
//                                .trim(from: 0, to: appeared ? accuracy : 0)
//                                .stroke(
//                                    AngularGradient(colors: [ringColor.opacity(0.6), ringColor],
//                                                    center: .center, startAngle: .degrees(-90), endAngle: .degrees(270)),
//                                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
//                                )
//                                .rotationEffect(.degrees(-90))
//                                .animation(.easeOut(duration: 1.1).delay(0.25), value: appeared)
//
//                            // Center text
//                            VStack(spacing: 2) {
//                                Text("\(Int(accuracy * 100))%")
//                                    .font(.system(size: 38, weight: .black, design: .rounded))
//                                    .foregroundStyle(.white)
//                                Text("Accuracy")
//                                    .font(.system(size: 12, weight: .medium))
//                                    .foregroundStyle(Color.textSub)
//                                    .kerning(0.8)
//                                    .textCase(.uppercase)
//                            }
//                        }
//                        .frame(width: 190, height: 190)
//
//                        Text(accuracyLabel)
//                            .font(.system(size: 15, weight: .semibold, design: .rounded))
//                            .foregroundStyle(ringColor)
//                    }
//                    .padding(.top, 40)
//                    .opacity(appeared ? 1 : 0)
//                    .animation(.easeOut(duration: 0.5), value: appeared)
//
//                    // ── Stats Grid ──
//                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
//                        StatTile(value: "\(total)",   label: "Answered", icon: "checkmark.circle",     color: Color.brandSoft)
//                        StatTile(value: "\(correct)", label: "Correct",  icon: "checkmark.seal.fill",  color: Color.success)
//                        StatTile(value: "\(wrong)",   label: "Wrong",    icon: "xmark.circle.fill",    color: Color.danger)
//                    }
//                    .padding(.horizontal, 20)
//                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
//                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.30), value: appeared)
//
//                    // ── Score Banner ──
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Total Score")
//                                .font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.textSub)
//                                .kerning(0.8).textCase(.uppercase)
//                            Text("\(viewModel.score)")
//                                .font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(.white)
//                        }
//                        Spacer()
//                        ZStack {
//                            Circle().fill(Color.warn.opacity(0.15)).frame(width: 64, height: 64)
//                            Image(systemName: "star.fill")
//                                .font(.system(size: 28)).foregroundStyle(Color.warn)
//                        }
//                    }
//                    .padding(22)
//                    .cardStyle(radius: 22)
//                    .padding(.horizontal, 20)
//                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
//                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.42), value: appeared)
//
//                    // ── Per-question breakdown ──
//                    if !viewModel.answeredQuestions.isEmpty {
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("Review")
//                                .font(.system(size: 11, weight: .semibold)).foregroundStyle(Color.textMuted)
//                                .kerning(0.9).textCase(.uppercase)
//                                .padding(.horizontal, 2)
//
//                            VStack(spacing: 0) {
//                                ForEach(Array(viewModel.answeredQuestions.enumerated()), id: \.offset) { idx, q in
//                                    ReviewRow(index: idx + 1, item: q)
//                                    if idx < viewModel.answeredQuestions.count - 1 { RowDivider() }
//                                }
//                            }
//                            .cardStyle(radius: 20)
//                        }
//                        .padding(.horizontal, 20)
//                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
//                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.54), value: appeared)
//                    }
//
//                    // ── All Time History ──
//                    if !viewModel.allTimeAnsweredQuestions.isEmpty {
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("All Time History")
//                                .font(.system(size: 11, weight: .semibold)).foregroundStyle(Color.textMuted)
//                                .kerning(0.9).textCase(.uppercase)
//                                .padding(.horizontal, 2)
//
//                            VStack(spacing: 0) {
//                                ForEach(Array(viewModel.allTimeAnsweredQuestions.enumerated()), id: \.offset) { idx, q in
//                                    ReviewRow(index: idx + 1, item: q)
//                                    if idx < viewModel.allTimeAnsweredQuestions.count - 1 { RowDivider() }
//                                }
//                            }
//                            .cardStyle(radius: 20)
//                        }
//                        .padding(.horizontal, 20)
//                    }
//                    
//                    Spacer(minLength: 48)
//                }
//            }
//        }
//        .navigationTitle("Progress")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbarColorScheme(.dark, for: .navigationBar)
//        .onAppear { appeared = true }
//    }
//
//    private var accuracyLabel: String {
//        if accuracy >= 0.90 { return "Outstanding! 🏆" }
//        if accuracy >= 0.75 { return "Great work! 🎉" }
//        if accuracy >= 0.50 { return "Keep going! 💪" }
//        return "Practice more 📚"
//    }
//}
//
//// MARK: - Stat Tile
//struct StatTile: View {
//    let value: String; let label: String; let icon: String; let color: Color
//
//    var body: some View {
//        VStack(spacing: 10) {
//            ZStack {
//                Circle().fill(color.opacity(0.15)).frame(width: 44, height: 44)
//                Image(systemName: icon).font(.system(size: 18)).foregroundStyle(color)
//            }
//            Text(value)
//                .font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
//            Text(label)
//                .font(.system(size: 11, weight: .medium)).foregroundStyle(Color.textSub)
//        }
//        .frame(maxWidth: .infinity).padding(.vertical, 18)
//        .cardStyle(radius: 18)
//    }
//}
//
//// MARK: - Review Row
//struct ReviewRow: View {
//    let index: Int
//    let item: AnsweredQuestion   // assumes AnsweredQuestion has .question, .isCorrect, .selectedAnswer, .correctAnswer
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // Number badge
//            ZStack {
//                Circle()
//                    .fill(item.isCorrect ? Color.success.opacity(0.15) : Color.danger.opacity(0.15))
//                    .frame(width: 30, height: 30)
//                Text("\(index)")
//                    .font(.system(size: 12, weight: .bold)).foregroundStyle(item.isCorrect ? Color.success : Color.danger)
//            }
//
//            VStack(alignment: .leading, spacing: 3) {
//                Text(item.question.question)
//                    .font(.system(size: 13, weight: .medium, design: .rounded)).foregroundStyle(.white)
//                    .lineLimit(2)
//                if !item.isCorrect {
//                    HStack(spacing: 4) {
//                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(Color.success)
//                        Text(item.question.correctAnswer)
//                            .font(.system(size: 11)).foregroundStyle(Color.success).lineLimit(1)
//                    }
//                }
//            }
//
//            Spacer()
//
//            Image(systemName: item.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
//                .font(.system(size: 18))
//                .foregroundStyle(item.isCorrect ? Color.success : Color.danger)
//        }
//        .padding(.horizontal, 18).padding(.vertical, 13)
//    }
//}
//
//#Preview {
//    StatsView(viewModel: QuestionViewModel())
//}
