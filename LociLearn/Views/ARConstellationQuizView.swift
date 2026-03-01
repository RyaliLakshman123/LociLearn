//
//  ARProgressHubView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 25/02/26.
//


import SwiftUI
import ARKit
import SceneKit
import Combine

// MARK: - Answer History Model

struct AnswerRecord: Identifiable {
    let id        = UUID()
    let question:  String
    let chosen:    String
    let correct:   String
    let isCorrect: Bool
    let timestamp: Date
}

// MARK: - Main SwiftUI View
struct ARConstellationQuizView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @StateObject  private var coordinator = ConstellationCoordinator()
    @Environment(\.dismiss) private var dismiss
    @State private var showSubjectPicker  = true
    @State private var selectedSubject: Subject = .biology
    @State private var quizStarted        = false
    @State private var showResult         = false
    @State private var lastCorrect        = false
    @State private var aimProgress        = 0.0
    @State private var aimedAnswer        = ""
    @State private var quizComplete       = false
    @State private var appeared           = false
    @State private var showHistory        = false

    var body: some View {
        ZStack {
            // ── App Background ──
            AppBackgroundView()
                .ignoresSafeArea()
            
            // ── AR Scene ──
            ConstellationSceneView(coordinator: coordinator)
                .ignoresSafeArea()

            // ── Subject Picker ──
            if showSubjectPicker { subjectPickerOverlay }

            // ── Quiz HUD ──
            if quizStarted && !quizComplete { quizHUD }

            // ── Crosshair ──
            if quizStarted && !quizComplete { crosshair }

            // ── Answer Result Flash ──
            if showResult {
                resultFlash(correct: lastCorrect)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            // ── Completion Screen ──
            if quizComplete {
                completionScreen
                    .transition(.scale.combined(with: .opacity))
            }

            // ── History Panel ──
            if showHistory {
                historyPanel
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onReceive(coordinator.$answeredCorrect) { val in
            guard let val else { return }
            guard !showResult else { return }
            lastCorrect = val
            withAnimation(.easeInOut(duration: 0.2)) { showResult = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showResult = false }
            }
        }
        .onReceive(coordinator.$aimProgress) { val in
            aimProgress = val
            aimedAnswer = coordinator.aimedAnswer
        }
        .onReceive(coordinator.$quizComplete) { done in
            if done { withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { quizComplete = true } }
        }
        .navigationTitle("Constellation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if quizStarted {
                        // If quiz is running, go back to subject picker
                        withAnimation(.spring()) {
                            quizStarted  = false
                            quizComplete = false
                            showSubjectPicker = true
                            coordinator.reset()
                        }
                    } else {
                        // If already on subject picker, allow normal nav pop
                        // Use a dismiss environment variable
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("")
                            .font(.system(size: 16))
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            NotificationCenter.default.post(name: .reinjectEmoji, object: nil)
        }
    }

    // MARK: - Subject Pill
    @ViewBuilder
    private func subjectPill(_ subject: Subject) -> some View {
        let isSelected = selectedSubject == subject
        let col        = subjectColor(subject)
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedSubject = subject }
        } label: {
            VStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill(isSelected ? col.opacity(0.25) : Color.white.opacity(0.06))
                        .frame(width: 44, height: 44)
                    Image(systemName: subjectIcon(subject))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? col : Color.textSub)
                }
                Text(subject.title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.white : Color.textSub)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? col.opacity(0.12) : Color.white.opacity(0.05),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? col.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subject Picker (enhanced start screen)
    private var subjectPickerOverlay: some View {
        ZStack {
            // Rich deep-space background
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.02, blue: 0.12),
                    Color(red: 0.06, green: 0.02, blue: 0.22),
                    Color(red: 0.10, green: 0.04, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

//            // Animated star field
//            StarFieldView().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {

                    // Hero section
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        colors: [Color.brand, Color.purple, Color.blue, Color.brand],
                                        center: .center
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 130, height: 130)
                                .blur(radius: 4)
                                .opacity(0.6)

                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.brand.opacity(0.3), Color.purple.opacity(0.15), Color.clear],
                                        center: .center, startRadius: 0, endRadius: 65
                                    )
                                )
                                .frame(width: 130, height: 130)

                            ConstellationIconView().frame(width: 90, height: 90)
                        }

                        VStack(spacing: 10) {
                            Text("CONSTELLATION")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundStyle(Color.brand.opacity(0.8))
                                .kerning(4)

                            Text("Quiz")
                                .font(.system(size: 46, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color(red: 0.85, green: 0.7, blue: 1.0)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )

                            Text("Stars orbit around you in 360°\nAim · Hold · Answer")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.textSub)
                                .multilineTextAlignment(.center)
                                .lineSpacing(5)
                        }
                    }
                    .padding(.top, 60)

                    // How to play
                    HStack(spacing: 10) {
                        HowToCard(icon: "scope",     label: "Aim",   desc: "Point at a star",    color: .blue)
                        HowToCard(icon: "timer",     label: "Hold",  desc: "1 second to lock",   color: Color.brand)
                        HowToCard(icon: "star.fill", label: "Score", desc: "Earn XP & streaks",  color: Color.warn)
                    }
                    .padding(.horizontal, 20)

                    // Subject selector
                    VStack(spacing: 14) {
                        HStack {
                            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
                            Text("CHOOSE SUBJECT")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundStyle(Color.textMuted)
                                .kerning(2)
                                .fixedSize()
                            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
                        }
                        .padding(.horizontal, 20)

                        HStack(spacing: 10) {
                            ForEach(Subject.allCases) { subject in subjectPill(subject) }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 4)

                    // History access (if available)
                    if !coordinator.history.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { showHistory = true }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("View Answer History (\(coordinator.history.count))")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .opacity(0.5)
                            }
                            .foregroundStyle(Color.textSub)
                            .padding(.horizontal, 20).padding(.vertical, 14)
                            .background(Color.white.opacity(0.05),
                                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }

                    // CTA
                    Button {
                        withAnimation(.spring()) {
                            showSubjectPicker = false
                            quizStarted = true
                            viewModel.startSubjectMode(selectedSubject)
                            coordinator.startQuiz(questions: viewModel.questions, subject: selectedSubject)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkle")
                                .font(.system(size: 18, weight: .bold))
                            Text("Launch Stars")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                            Spacer()
                            ZStack {
                                Circle().fill(Color.white.opacity(0.15)).frame(width: 32, height: 32)
                                Image(systemName: "arrow.right").font(.system(size: 13, weight: .black))
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22).padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [subjectColor(selectedSubject), subjectColor(selectedSubject).opacity(0.7)],
                                startPoint: .leading, endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .shadow(color: subjectColor(selectedSubject).opacity(0.55), radius: 20, y: 8)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5), value: appeared)
        .onAppear { appeared = true }
    }

    // MARK: - Quiz HUD
    private var quizHUD: some View {
        let progressWidth: Double = coordinator.questions.isEmpty ? 0 :
            Double(coordinator.currentIndex + 1) / Double(coordinator.questions.count)
        let col = subjectColor(selectedSubject)
        return VStack {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill").font(.system(size: 10)).foregroundStyle(col)
                        Text("Q \(coordinator.currentIndex + 1) of \(coordinator.questions.count)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textSub)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                            Capsule().fill(col)
                                .frame(width: geo.size.width * progressWidth, height: 4)
                                .animation(.spring(), value: coordinator.currentIndex)
                        }
                    }.frame(height: 4)
                }

                Spacer()

                // History button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { showHistory = true }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill").font(.system(size: 10))
                        Text("\(coordinator.history.count)").font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color.textSub)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())
                }

                HStack(spacing: 5) {
                    Image(systemName: "bolt.fill").font(.system(size: 10)).foregroundStyle(Color.warn)
                    Text("\(viewModel.score) XP").font(.system(size: 13, weight: .black, design: .rounded)).foregroundStyle(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.warn.opacity(0.3), lineWidth: 1))

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").font(.system(size: 10)).foregroundStyle(Color.warn).symbolEffect(.pulse)
                    Text("\(viewModel.streak)").font(.system(size: 13, weight: .black, design: .rounded)).foregroundStyle(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.warn.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 20).padding(.top, 12)

            Spacer()

            if let q = coordinator.currentQuestion {
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "scope").font(.system(size: 10, weight: .bold)).foregroundStyle(col)
                        Text("Aim at the correct star · Hold to answer")
                            .font(.system(size: 10, weight: .semibold)).foregroundStyle(Color.textMuted).kerning(0.5)
                    }

                    Text(q.question)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    if aimProgress > 0 {
                        VStack(spacing: 4) {
                            Text(aimedAnswer)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(col).lineLimit(1)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 5)
                                    Capsule()
                                        .fill(LinearGradient(colors: [col, .white], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * aimProgress, height: 5)
                                        .animation(.linear(duration: 0.05), value: aimProgress)
                                }
                            }.frame(height: 5)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(col.opacity(0.35), lineWidth: 1))
                .shadow(color: col.opacity(0.25), radius: 14, y: 4)
                .padding(.horizontal, 16).padding(.bottom, 40)
                .animation(.spring(), value: aimProgress > 0)
            }
        }
    }

    // MARK: - Crosshair
    private var crosshair: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: aimProgress)
                .stroke(aimProgress > 0 ? subjectColor(selectedSubject) : Color.white.opacity(0.5),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .frame(width: 52, height: 52)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: aimProgress)

            Circle().stroke(Color.white.opacity(0.15), lineWidth: 1.5).frame(width: 52, height: 52)

            Circle()
                .fill(aimProgress > 0 ? subjectColor(selectedSubject) : Color.white.opacity(0.8))
                .frame(width: 6, height: 6)
                .animation(.easeInOut(duration: 0.1), value: aimProgress > 0)

            Rectangle().fill(Color.white.opacity(0.4)).frame(width: 16, height: 1).offset(x: -22)
            Rectangle().fill(Color.white.opacity(0.4)).frame(width: 16, height: 1).offset(x: 22)
            Rectangle().fill(Color.white.opacity(0.4)).frame(width: 1, height: 16).offset(y: -22)
            Rectangle().fill(Color.white.opacity(0.4)).frame(width: 1, height: 16).offset(y: 22)
        }
    }

    // MARK: - Result Flash
    private func resultFlash(correct: Bool) -> some View {
        ZStack {
            (correct ? Color.success : Color.danger).opacity(0.15).ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: correct ? "star.fill" : "xmark.circle.fill")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(correct ? Color.warn : Color.danger)
                    .symbolEffect(.bounce)
                Text(correct ? "Correct! +20 XP" : "Wrong!")
                    .font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.white)
                if correct {
                    Text("⭐ Keep going!").font(.system(size: 13, weight: .medium)).foregroundStyle(Color.textSub)
                }
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    // MARK: - History Panel (slide-up sheet)
    private var historyPanel: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { showHistory = false }
                }

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5).padding(.top, 12).padding(.bottom, 16)

                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Answer History")
                            .font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.white)
                        Text("\(coordinator.history.filter(\.isCorrect).count) correct · \(coordinator.history.filter { !$0.isCorrect }.count) wrong")
                            .font(.system(size: 12, weight: .medium)).foregroundStyle(Color.textSub)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { showHistory = false }
                    } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 26)).foregroundStyle(Color.textMuted)
                    }
                }
                .padding(.horizontal, 22).padding(.bottom, 14)

                // Accuracy bar
                if !coordinator.history.isEmpty {
                    let accuracy = Double(coordinator.history.filter(\.isCorrect).count) / Double(coordinator.history.count)
                    VStack(spacing: 6) {
                        HStack {
                            Text("Accuracy").font(.system(size: 11, weight: .semibold)).foregroundStyle(Color.textMuted)
                            Spacer()
                            Text("\(Int(accuracy * 100))%")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(accuracy > 0.6 ? Color.success : Color.danger)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.08)).frame(height: 6)
                                Capsule()
                                    .fill(LinearGradient(colors: [Color.success, Color.brand],
                                                         startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * accuracy, height: 6)
                            }
                        }.frame(height: 6)
                    }
                    .padding(.horizontal, 22).padding(.bottom, 14)
                }

                Divider().opacity(0.15).padding(.horizontal, 22)

                if coordinator.history.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.badge.questionmark").font(.system(size: 36)).foregroundStyle(Color.textMuted)
                        Text("No answers yet").font(.system(size: 15, weight: .medium, design: .rounded)).foregroundStyle(Color.textMuted)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 50)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(coordinator.history.reversed()) { record in HistoryRow(record: record) }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                    }
                    .frame(maxHeight: 380)
                }

                Color.clear.frame(height: 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(LinearGradient(
                                colors: [Color(red:0.06,green:0.03,blue:0.18), Color(red:0.10,green:0.05,blue:0.25)],
                                startPoint: .top, endPoint: .bottom
                            ).opacity(0.85))
                    )
            )
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
        }
    }

    // MARK: - Completion Screen
    private var completionScreen: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()

            VStack(spacing: 26) {
                ZStack {
                    Circle().fill(Color.warn.opacity(0.15)).frame(width: 100, height: 100)
                    Image(systemName: "trophy.fill").font(.system(size: 44)).foregroundStyle(Color.warn).symbolEffect(.bounce)
                }

                VStack(spacing: 8) {
                    Text("Constellation Complete!")
                        .font(.system(size: 26, weight: .black, design: .rounded)).foregroundStyle(.white)
                    Text("You navigated \(coordinator.questions.count) stars")
                        .font(.system(size: 14)).foregroundStyle(Color.textSub)
                }

                HStack(spacing: 12) {
                    ConstellationStat(value: "\(viewModel.score)",    label: "Total XP", icon: "bolt.fill",          color: Color.warn)
                    ConstellationStat(value: "\(coordinator.correctCount)/\(coordinator.questions.count)", label: "Correct", icon: "checkmark.seal.fill", color: Color.success)
                    ConstellationStat(value: "\(viewModel.streak)",   label: "Streak",   icon: "flame.fill",          color: subjectColor(selectedSubject))
                }

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { showHistory = true }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath").font(.system(size: 14, weight: .semibold))
                        Text("Review Answers").font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color.textSub)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                }
                .buttonStyle(ScaleButtonStyle())

                Button {
                    withAnimation(.spring()) {
                        quizComplete = false; quizStarted = false; showSubjectPicker = true
                        coordinator.reset()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise").font(.system(size: 14, weight: .bold))
                        Text("Play Again").font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 15)
                    .background(subjectColor(selectedSubject), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: subjectColor(selectedSubject).opacity(0.4), radius: 12, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(32)
        }
    }

    // MARK: - Helpers
    private func subjectIcon(_ s: Subject) -> String {
        switch s {
        case .biology: return "leaf.fill"
        case .computerScience: return "cpu.fill"
        case .solar: return "sun.max.fill"
        }
    }

    private func subjectColor(_ s: Subject) -> Color {
        switch s {
        case .biology: return Color.success
        case .computerScience: return Color.brand
        case .solar: return Color.warn
        }
    }
}

// MARK: - History Row
struct HistoryRow: View {
    let record: AnswerRecord
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(record.isCorrect ? Color.success.opacity(0.15) : Color.danger.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: record.isCorrect ? "checkmark" : "xmark")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(record.isCorrect ? Color.success : Color.danger)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(record.question)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white).lineLimit(2)

                HStack(spacing: 8) {
                    if !record.isCorrect {
                        Label(record.chosen, systemImage: "xmark.circle.fill")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.danger.opacity(0.8)).lineLimit(1)
                    }
                    Label(record.correct, systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.success.opacity(0.9)).lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(record.isCorrect ? Color.success.opacity(0.2) : Color.danger.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - How To Card

struct HowToCard: View {
    let icon: String; let label: String; let desc: String; let color: Color
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(color)
            }
            Text(label).font(.system(size: 13, weight: .black, design: .rounded)).foregroundStyle(.white)
            Text(desc).font(.system(size: 10, weight: .medium)).foregroundStyle(Color.textMuted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(color.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Star Field Background

struct StarFieldView: View {
    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = {
        var arr: [(CGFloat, CGFloat, CGFloat, Double)] = []
        var rng = SeededRandom(seed: 42)
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        for _ in 0..<80 {
            arr.append((
                CGFloat(rng.next()) * w,
                CGFloat(rng.next()) * h,
                CGFloat(rng.next()) * 2.5 + 0.5,
                Double(rng.next()) * 0.6 + 0.1
            ))
        }
        return arr
    }()

    var body: some View {
        Canvas { context, _ in
            for star in stars {
                let rect = CGRect(x: star.x - star.size/2, y: star.y - star.size/2,
                                  width: star.size, height: star.size)
                context.opacity = star.opacity
                context.fill(Path(ellipseIn: rect), with: .color(.white))
            }
        }
    }
}

struct SeededRandom {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> Float {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Float(state >> 33) / Float(UInt32.max)
    }
}

// MARK: - Constellation Icon Decoration

struct ConstellationIconView: View {
    var body: some View {
        ZStack {
            Path { p in
                p.move(to:    CGPoint(x: 45, y: 20))
                p.addLine(to: CGPoint(x: 70, y: 50))
                p.addLine(to: CGPoint(x: 50, y: 75))
                p.addLine(to: CGPoint(x: 20, y: 60))
                p.addLine(to: CGPoint(x: 25, y: 35))
                p.addLine(to: CGPoint(x: 45, y: 20))
            }
            .stroke(
                LinearGradient(colors: [Color.brand.opacity(0.6), Color.purple.opacity(0.4)],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: 1.5
            )

            ForEach([
                CGPoint(x: 45, y: 20), CGPoint(x: 70, y: 50),
                CGPoint(x: 50, y: 75), CGPoint(x: 20, y: 60),
                CGPoint(x: 25, y: 35)
            ], id: \.x) { pt in
                Circle().fill(Color.white).frame(width: 6, height: 6).position(pt)
                    .shadow(color: Color.brand, radius: 4)
            }
        }
    }
}

// MARK: - Stat Chip

struct ConstellationStat: View {
    let value: String; let label: String; let icon: String; let color: Color
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 14)).foregroundStyle(color)
            Text(value).font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 10, weight: .medium)).foregroundStyle(Color.textSub)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(color.opacity(0.25), lineWidth: 1))
    }
}

// MARK: - SceneKit Container
struct ConstellationSceneView: UIViewControllerRepresentable {
    let coordinator: ConstellationCoordinator
    func makeUIViewController(context: Context) -> ConstellationVC {
        let vc = ConstellationVC(); vc.coordinator = coordinator; return vc
    }
    func updateUIViewController(_ vc: ConstellationVC, context: Context) {}
}

// MARK: - Coordinator

@MainActor
class ConstellationCoordinator: NSObject, ObservableObject {
    @Published var questions:        [Question]    = []
    @Published var currentIndex:     Int           = 0
    @Published var correctCount:     Int           = 0
    @Published var quizComplete:     Bool          = false
    @Published var answeredCorrect:  Bool?         = nil
    @Published var aimProgress:      Double        = 0
    @Published var aimedAnswer:      String        = ""
    @Published var history:          [AnswerRecord] = []

    // ← FIX: prevents double-answer submission & double result flash
    private var isProcessingAnswer = false

    weak var vc: ConstellationVC?

    var currentQuestion: Question? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    func startQuiz(questions: [Question], subject: Subject) {
        self.questions       = questions.shuffled()
        self.currentIndex    = 0
        self.correctCount    = 0
        self.quizComplete    = false
        self.answeredCorrect = nil
        self.isProcessingAnswer = false
        vc?.spawnConstellation()
    }

    func submitAnswer(_ answer: String) {
        guard !isProcessingAnswer, let q = currentQuestion else { return }
        isProcessingAnswer = true

        let correct = answer == q.correctAnswer
        history.append(AnswerRecord(
            question: q.question, chosen: answer,
            correct: q.correctAnswer, isCorrect: correct, timestamp: Date()
        ))

        answeredCorrect = correct
        if correct { correctCount += 1 }

        vc?.explodeStar(correct: correct, chosenLabel: answer) { [weak self] in
            guard let self else { return }
            if self.currentIndex < self.questions.count - 1 {
                self.currentIndex += 1
                self.isProcessingAnswer = false
                self.vc?.spawnConstellation()
            } else {
                self.quizComplete = true
                self.vc?.clearAll()
            }
        }
    }

    func reset() {
        questions = []; currentIndex = 0; correctCount = 0
        quizComplete = false; answeredCorrect = nil
        aimProgress = 0; aimedAnswer = ""
        isProcessingAnswer = false
        // history intentionally preserved
        vc?.clearAll(); vc?.restartSession()
    }
}

// MARK: - ARSCNViewController

class ConstellationVC: UIViewController, ARSCNViewDelegate {

    var coordinator: ConstellationCoordinator?

    private var sceneView:   ARSCNView!
    private var sessionReady = false

    private var questionNode: SCNNode?
    private var answerNodes:  [SCNNode] = []
    private var answerLabels: [String]  = []
    private var lineNodes:    [SCNNode] = []

    private var aimTimer:       Timer?
    private var aimedNodeIndex: Int?   = nil
    private var aimAccumulator: Double = 0
    private let aimThreshold:   Double = 1.0

    private let starRadius: Float = 1.4
    private let starHeight: Float = 0.0

    private var starColor: UIColor = .systemIndigo

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear   // ← transparent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !sessionReady, view.bounds.width > 0 else { return }
        sessionReady = true

        sceneView = ARSCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.delegate = self
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = true

        // ─── KEY FIX: show camera feed, not black ───
        sceneView.backgroundColor = .clear
        sceneView.scene.background.contents = nil   // nil = camera pass-through

        view.addSubview(sceneView)
        coordinator?.vc = self
        startSession()
        startAimLoop()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView?.session.pause()
        aimTimer?.invalidate()
    }

    func restartSession() { startSession() }

    private func startSession() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = []
        config.environmentTexturing = .none
        sceneView?.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - Spawn Constellation
    func spawnConstellation() {
        clearAll()
        guard let q = coordinator?.currentQuestion,
              let frame = sceneView?.session.currentFrame else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in self?.spawnConstellation() }
            return
        }

        let cam     = frame.camera.transform
        let camPos  = SIMD3<Float>(cam.columns.3.x, cam.columns.3.y, cam.columns.3.z)
        let forward = SIMD3<Float>(-cam.columns.2.x, 0, -cam.columns.2.z)
        let fwdNorm = simd_length(forward) > 0.001 ? simd_normalize(forward) : SIMD3<Float>(0,0,-1)

        // Question orb
        let orbNode = makeQuestionOrb(text: q.question)
        let orbPos  = SCNVector3(camPos.x + fwdNorm.x * 1.2, camPos.y + 0.05, camPos.z + fwdNorm.z * 1.2)
        orbNode.position = orbPos
        sceneView.scene.rootNode.addChildNode(orbNode)
        questionNode = orbNode

        let constraint = SCNBillboardConstraint(); constraint.freeAxes = .Y
        orbNode.constraints = [constraint]

        // ─── FIX: Opposite pairs — N↔S, E↔W ───
        // Index 0=North, 1=East, 2=South (opposite 0), 3=West (opposite 1)
        answerLabels = q.options
        let angles: [Float] = [0, .pi/2, .pi, 3 * .pi/2]  // N, E, S, W

        for (i, option) in answerLabels.enumerated() {
            let angle    = angles[i]
            let x        = camPos.x + cos(angle) * starRadius
            let z        = camPos.z + sin(angle) * starRadius
            let y        = camPos.y + starHeight

            let starNode = makeAnswerStar(text: option, index: i)
            starNode.position = SCNVector3(x, y, z)

            let bc = SCNBillboardConstraint(); bc.freeAxes = .Y
            starNode.constraints = [bc]

            sceneView.scene.rootNode.addChildNode(starNode)
            answerNodes.append(starNode)

            let line = makeConstellationLine(from: orbPos, to: SCNVector3(x, y, z))
            sceneView.scene.rootNode.addChildNode(line)
            lineNodes.append(line)
        }

        for (i, node) in answerNodes.enumerated() {
            node.scale = SCNVector3(0.01, 0.01, 0.01)
            let grow = SCNAction.scale(to: 1.0, duration: 0.4); grow.timingMode = .easeOut
            node.runAction(SCNAction.sequence([SCNAction.wait(duration: Double(i) * 0.1), grow]))
        }

        pulseNode(orbNode)
    }

    // MARK: - Aim Loop
    private func startAimLoop() {
        aimTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in self?.checkAim() }
    }

    private func checkAim() {
        guard let sceneView = sceneView else { return }
        let centre = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        let hits   = sceneView.hitTest(centre, options: [
            SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue,
            SCNHitTestOption.ignoreHiddenNodes: true
        ])

        var foundIndex: Int? = nil
        for hit in hits {
            var node: SCNNode? = hit.node
            while node != nil {
                if let idx = answerNodes.firstIndex(of: node!) { foundIndex = idx; break }
                node = node?.parent
            }
            if foundIndex != nil { break }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let idx = foundIndex {
                if self.aimedNodeIndex == idx {
                    self.aimAccumulator += 0.05
                    let progress = min(self.aimAccumulator / self.aimThreshold, 1.0)
                    self.coordinator?.aimProgress = progress
                    self.coordinator?.aimedAnswer = self.answerLabels[idx]

                    if self.aimAccumulator >= self.aimThreshold {
                        self.aimAccumulator = 0; self.aimedNodeIndex = nil
                        self.coordinator?.aimProgress = 0; self.coordinator?.aimedAnswer = ""
                        let chosen = self.answerLabels[idx]
                        self.coordinator?.submitAnswer(chosen)
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                } else {
                    self.aimedNodeIndex = idx; self.aimAccumulator = 0
                    self.coordinator?.aimProgress = 0
                }
            } else {
                self.aimedNodeIndex = nil; self.aimAccumulator = 0
                self.coordinator?.aimProgress = 0; self.coordinator?.aimedAnswer = ""
            }
        }
    }

    // MARK: - Explode Star
    // FIX: chosenLabel passed explicitly — no reliance on stale aimedNodeIndex
    func explodeStar(correct: Bool, chosenLabel: String, completion: @escaping () -> Void) {
        if let correctLabel = coordinator?.currentQuestion?.correctAnswer,
           let correctIdx   = answerLabels.firstIndex(of: correctLabel),
           correctIdx < answerNodes.count {
            flashStar(answerNodes[correctIdx], color: .systemGreen)
            burstParticles(at: answerNodes[correctIdx].position, color: .systemGreen)
        }

        if !correct,
           let chosenIdx = answerLabels.firstIndex(of: chosenLabel),
           chosenIdx < answerNodes.count {
            flashStar(answerNodes[chosenIdx], color: .systemRed)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3, execute: completion)
    }

    private func flashStar(_ node: SCNNode, color: UIColor) {
        node.childNodes.first?.geometry?.firstMaterial?.diffuse.contents  = color
        node.childNodes.first?.geometry?.firstMaterial?.emission.contents = color.withAlphaComponent(0.6)
        node.runAction(SCNAction.sequence([
            SCNAction.scale(to: 1.5, duration: 0.2),
            SCNAction.scale(to: 1.0, duration: 0.2)
        ]))
    }

    private func burstParticles(at pos: SCNVector3, color: UIColor) {
        let system = SCNParticleSystem()
        system.particleColor = color; system.birthRate = 400; system.particleLifeSpan = 0.6
        system.particleSize = 0.015; system.spreadingAngle = 180; system.particleVelocity = 0.8
        system.loops = false; system.emissionDuration = 0.15
        let particleNode = SCNNode(); particleNode.position = pos
        sceneView.scene.rootNode.addChildNode(particleNode)
        particleNode.addParticleSystem(system)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { particleNode.removeFromParentNode() }
    }

    // MARK: - Clear
    func clearAll() {
        questionNode?.removeFromParentNode(); questionNode = nil
        answerNodes.forEach { $0.removeFromParentNode() }; answerNodes.removeAll()
        lineNodes.forEach   { $0.removeFromParentNode() }; lineNodes.removeAll()
        answerLabels.removeAll()
        aimedNodeIndex = nil; aimAccumulator = 0
    }

    // MARK: - Node Builders

    private func makeQuestionOrb(text: String) -> SCNNode {
        let container = SCNNode()

        let outerSphere = SCNSphere(radius: 0.045); let outerMat = SCNMaterial()
        outerMat.diffuse.contents  = UIColor(red:0.4,green:0.1,blue:0.9,alpha:0.3)
        outerMat.emission.contents = UIColor(red:0.4,green:0.1,blue:0.9,alpha:0.4)
        outerMat.isDoubleSided = true; outerSphere.materials = [outerMat]
        container.addChildNode(SCNNode(geometry: outerSphere))

        let innerSphere = SCNSphere(radius: 0.028); let innerMat = SCNMaterial()
        innerMat.diffuse.contents  = UIColor(red:0.6,green:0.3,blue:1.0,alpha:1)
        innerMat.emission.contents = UIColor(red:0.5,green:0.2,blue:0.9,alpha:0.8)
        innerMat.specular.contents = UIColor.white; innerSphere.materials = [innerMat]
        container.addChildNode(SCNNode(geometry: innerSphere))

        let textPlane = SCNPlane(width: 0.55, height: 0.22); textPlane.cornerRadius = 0.015
        let textMat = SCNMaterial(); textMat.diffuse.contents = renderQuestionImage(text: text)
        textMat.isDoubleSided = true; textMat.transparencyMode = .aOne; textPlane.materials = [textMat]
        let textNode = SCNNode(geometry: textPlane); textNode.position = SCNVector3(0, 0.18, 0)
        container.addChildNode(textNode)

        return container
    }

    private func makeAnswerStar(text: String, index: Int) -> SCNNode {
        let container = SCNNode()

        let glowSphere = SCNSphere(radius: 0.040); let glowMat = SCNMaterial()
        glowMat.diffuse.contents  = starColor.withAlphaComponent(0.25)
        glowMat.emission.contents = starColor.withAlphaComponent(0.3)
        glowMat.isDoubleSided = true; glowSphere.materials = [glowMat]
        container.addChildNode(SCNNode(geometry: glowSphere))

        let coreSphere = SCNSphere(radius: 0.022); let coreMat = SCNMaterial()
        coreMat.diffuse.contents  = starColor; coreMat.emission.contents = starColor.withAlphaComponent(0.7)
        coreMat.specular.contents = UIColor.white; coreSphere.materials = [coreMat]
        container.addChildNode(SCNNode(geometry: coreSphere))

        let labelPlane = SCNPlane(width: 0.40, height: 0.14); labelPlane.cornerRadius = 0.010
        let labelMat = SCNMaterial(); labelMat.diffuse.contents = renderAnswerImage(text: text, index: index)
        labelMat.isDoubleSided = true; labelMat.transparencyMode = .aOne; labelPlane.materials = [labelMat]
        let labelNode = SCNNode(geometry: labelPlane); labelNode.position = SCNVector3(0, 0.12, 0)
        container.addChildNode(labelNode)

        let torus = SCNTorus(ringRadius: 0.048, pipeRadius: 0.003); let torusMat = SCNMaterial()
        torusMat.diffuse.contents  = starColor.withAlphaComponent(0.4)
        torusMat.emission.contents = starColor.withAlphaComponent(0.2); torus.materials = [torusMat]
        let torusNode = SCNNode(geometry: torus); torusNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
        container.addChildNode(torusNode)
        torusNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x:0,y:.pi*2,z:0,duration:4)))

        return container
    }

    private func makeConstellationLine(from: SCNVector3, to: SCNVector3) -> SCNNode {

        let dx = to.x - from.x
        let dy = to.y - from.y
        let dz = to.z - from.z
        let dist = sqrt(dx*dx + dy*dy + dz*dz)

        // Thicker + darker line
        let cylinder = SCNCylinder(radius: 0.004, height: CGFloat(dist))

        let mat = SCNMaterial()
        
        // DARKER + Stronger Glow
        mat.diffuse.contents  = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.9)
        mat.emission.contents = UIColor(red: 0.5, green: 0.3, blue: 1.0, alpha: 0.8)
        mat.lightingModel = .constant   // ← makes it always bright
        cylinder.materials = [mat]

        let node = SCNNode(geometry: cylinder)

        node.position = SCNVector3(
            (from.x + to.x) / 2,
            (from.y + to.y) / 2,
            (from.z + to.z) / 2
        )

        let dir = SCNVector3(dx, dy, dz)
        let up  = SCNVector3(0, 1, 0)

        let cross = SCNVector3(
            up.y * dir.z - up.z * dir.y,
            up.z * dir.x - up.x * dir.z,
            up.x * dir.y - up.y * dir.x
        )

        let angle = acos(
            Double(up.x * dir.x + up.y * dir.y + up.z * dir.z) / Double(dist)
        )

        node.rotation = SCNVector4(cross.x, cross.y, cross.z, Float(angle))

        return node
    }

    private func pulseNode(_ node: SCNNode) {
        node.runAction(SCNAction.repeatForever(SCNAction.sequence([
            SCNAction.scale(to:1.08,duration:0.8), SCNAction.scale(to:0.95,duration:0.8)
        ])), forKey: "pulse")
    }

    // MARK: - Image Renderers

    private func renderQuestionImage(text: String) -> UIImage {
        let size = CGSize(width: 900, height: 360)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let c = ctx.cgContext
            let bg = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
                UIColor(red:0.08,green:0.02,blue:0.25,alpha:0.95).cgColor,
                UIColor(red:0.18,green:0.04,blue:0.45,alpha:0.95).cgColor] as CFArray, locations:[0,1])!
            let path = UIBezierPath(roundedRect:CGRect(origin:.zero,size:size),cornerRadius:28)
            c.addPath(path.cgPath); c.clip()
            c.drawLinearGradient(bg,start:.zero,end:CGPoint(x:size.width,y:size.height),options:[])

            c.saveGState(); c.clip(to:CGRect(x:0,y:0,width:size.width,height:6))
            let accent = CGGradient(colorsSpace:CGColorSpaceCreateDeviceRGB(),colors:[
                UIColor(red:0.4,green:0.8,blue:1,alpha:1).cgColor,
                UIColor(red:0.7,green:0.3,blue:1,alpha:1).cgColor] as CFArray, locations:[0,1])!
            c.drawLinearGradient(accent,start:.zero,end:CGPoint(x:size.width,y:0),options:[])
            c.restoreGState()

            let para = NSMutableParagraphStyle(); para.alignment = .center; para.lineSpacing = 8
            NSAttributedString(string:text,attributes:[
                .font: UIFont.systemFont(ofSize:38,weight:.bold),
                .foregroundColor: UIColor.white, .paragraphStyle: para
            ]).draw(in:CGRect(x:40,y:40,width:size.width-80,height:size.height-80))
        }
    }

    private func renderAnswerImage(text: String, index: Int) -> UIImage {
        let size = CGSize(width:660,height:230); let letters = ["A","B","C","D"]
        let colors: [UIColor] = [starColor,
            UIColor(red:0.2,green:0.8,blue:0.6,alpha:1),
            UIColor(red:1.0,green:0.6,blue:0.2,alpha:1),
            UIColor(red:0.9,green:0.3,blue:0.5,alpha:1)]
        let col = index < colors.count ? colors[index] : starColor

        return UIGraphicsImageRenderer(size:size).image { ctx in
            let c = ctx.cgContext
            let bg = CGGradient(colorsSpace:CGColorSpaceCreateDeviceRGB(),colors:[
                UIColor(red:0.06,green:0.06,blue:0.18,alpha:0.96).cgColor,
                UIColor(red:0.10,green:0.05,blue:0.28,alpha:0.96).cgColor] as CFArray,locations:[0,1])!
            let path = UIBezierPath(roundedRect:CGRect(origin:.zero,size:size),cornerRadius:22)
            c.addPath(path.cgPath); c.clip()
            c.drawLinearGradient(bg,start:.zero,end:CGPoint(x:size.width,y:size.height),options:[])

            col.withAlphaComponent(0.6).setFill()
            UIBezierPath(roundedRect:CGRect(x:0,y:0,width:8,height:size.height),cornerRadius:4).fill()

            col.withAlphaComponent(0.2).setFill()
            UIBezierPath(roundedRect:CGRect(x:28,y:size.height/2-30,width:60,height:60),cornerRadius:14).fill()
            NSAttributedString(string:letters[min(index,3)],attributes:[
                .font: UIFont.systemFont(ofSize:30,weight:.black), .foregroundColor: col
            ]).draw(at:CGPoint(x:44,y:size.height/2-20))

            let para = NSMutableParagraphStyle(); para.lineBreakMode = .byWordWrapping
            NSAttributedString(string:text,attributes:[
                .font: UIFont.systemFont(ofSize:30,weight:.semibold),
                .foregroundColor: UIColor.white, .paragraphStyle: para
            ]).draw(in:CGRect(x:108,y:28,width:size.width-130,height:size.height-56))
        }
    }
}

// MARK: - Preview
#Preview {
    ARConstellationQuizView(viewModel: QuestionViewModel())
}

// MARK: - Constellation Launcher View
struct ConstellationLauncherView: View {
    @ObservedObject var viewModel: QuestionViewModel

    @State private var phase1 = false  // stars fade in
    @State private var phase2 = false  // orb + rings appear
    @State private var phase4 = false  // text slides up
    @State private var phase5 = false  // button appears

    @State private var orbFloat       = false
    @State private var pulseRing      = false
    @State private var rotateRing1    = false
    @State private var rotateRing2    = false
    @State private var shimmerPhase   = false
    @State private var meteors: [MeteorData] = []
    @State private var meteorTimer: Timer?

    @State private var nodeScales  = Array(repeating: CGFloat(0), count: 8)
    @State private var lineDrawn   = Array(repeating: CGFloat(0), count: 9)

    private let nodeOffsets: [CGSize] = [
        CGSize(width: -58,  height: -105),
        CGSize(width:  62,  height: -88),
        CGSize(width:  108, height:  10),
        CGSize(width:  52,  height:  90),
        CGSize(width: -70,  height:  82),
        CGSize(width: -105, height: -12),
        CGSize(width:  18,  height: -145),
        CGSize(width:  135, height: -55),
    ]

    private let lineIndices: [(Int,Int)] = [
        (0,1),(1,2),(2,3),(3,4),(4,5),(5,0),(1,6),(2,7),(0,6)
    ]

    var body: some View {
        GeometryReader { geo in
            // Fixed background only - never scrolls
            ZStack {
                deepSpaceBackground
                nebulaLayers
                AppBackgroundView()
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .top) {
                        // Constellation + orb scroll with content
                        VStack(spacing: 0) {
                            constellationCanvas(geo: geo)
                                .frame(height: geo.size.height * 0.65)
                            Spacer()
                        }
                        
                        VStack(spacing: 0) {
                            mainOrb(geo: geo)
                                .frame(height: geo.size.height * 0.65)
                            Spacer()
                        }
                        
                        // Text + button content below
                        VStack(spacing: 28) {
                            Color.clear.frame(height: geo.size.height * 0.62)
                            
                            // Badge
                            HStack(spacing: 7) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundStyle(Color(red:0.72,green:0.55,blue:1.0))
                                Text("SPATIAL · AR · IMMERSIVE")
                                    .font(.system(size: 9, weight: .black, design: .monospaced))
                                    .foregroundStyle(Color(red:0.72,green:0.55,blue:1.0))
                                    .kerning(2.5)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(Color(red:0.45,green:0.20,blue:0.95).opacity(0.18))
                                    .overlay(Capsule().strokeBorder(Color(red:0.55,green:0.30,blue:1.0).opacity(0.35), lineWidth: 0.8))
                            )
                            .opacity(phase4 ? 1 : 0)
                            .offset(y: phase4 ? 0 : 30)
                            .animation(.spring(response: 0.7, dampingFraction: 0.78), value: phase4)

                            // Title
                            VStack(spacing: 8) {
                                ZStack {
                                    Text("Constellation")
                                        .font(.system(size: 48, weight: .black, design: .rounded))
                                        .foregroundStyle(Color(red:0.55,green:0.28,blue:1.0).opacity(0.6))
                                        .blur(radius: 18)
                                        .scaleEffect(1.05)
                                    Text("Constellation")
                                        .font(.system(size: 48, weight: .black, design: .rounded))
                                        .foregroundStyle(LinearGradient(
                                            colors: [Color.white, Color(red:0.88,green:0.78,blue:1.00), Color(red:0.60,green:0.42,blue:1.00)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        ))
                                        .tracking(-1.2)
                                }
                                Text("Questions orbit around you in AR space.\nAim your gaze · Lock on · Answer.")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.white.opacity(0.40))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                            }
                            .opacity(phase4 ? 1 : 0)
                            .offset(y: phase4 ? 0 : 30)
                            .animation(.spring(response: 0.7, dampingFraction: 0.78).delay(0.05), value: phase4)

                            // Stats row
                            HStack(spacing: 10) {
                                LaunchStatPill(value: "360°", label: "Spatial",    icon: "rotate.3d")
                                LaunchStatPill(value: "AR",   label: "Real Space", icon: "arkit")
                                LaunchStatPill(value: "XP",   label: "Rewards",    icon: "bolt.fill")
                                LaunchStatPill(value: "Live", label: "Score",      icon: "flame.fill")
                            }
                            .opacity(phase4 ? 1 : 0)
                            .offset(y: phase4 ? 0 : 20)
                            .animation(.spring(response: 0.65, dampingFraction: 0.78).delay(0.10), value: phase4)

                            // CTA Button
                            NavigationLink {
                                ARConstellationQuizView(viewModel: viewModel)
                            } label: {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(LinearGradient(
                                            colors: [Color.clear, Color.white.opacity(shimmerPhase ? 0.10 : 0.0), Color.clear],
                                            startPoint: UnitPoint(x: shimmerPhase ? 1.4 : -0.4, y: 0.3),
                                            endPoint:   UnitPoint(x: shimmerPhase ? 2.0 : 0.2,  y: 0.8)
                                        ))
                                        .allowsHitTesting(false)

                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle().fill(Color.white.opacity(0.14)).frame(width: 48, height: 48)
                                            Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1).frame(width: 48, height: 48)
                                            Image(systemName: "arkit").font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                        }
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("Enter Constellation")
                                                .font(.system(size: 18, weight: .black, design: .rounded))
                                                .foregroundStyle(.white).tracking(-0.3)
                                            Text("Augmented Reality Experience")
                                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                                .foregroundStyle(Color.white.opacity(0.50))
                                        }
                                        Spacer()
                                        ZStack {
                                            Circle().fill(Color.white.opacity(0.18)).frame(width: 36, height: 36)
                                            Image(systemName: "arrow.right").font(.system(size: 13, weight: .black)).foregroundStyle(.white)
                                        }
                                    }
                                    .padding(.horizontal, 14).padding(.vertical, 14)
                                }
                                .frame(maxWidth: .infinity).frame(height: 76)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(LinearGradient(
                                                colors: [Color(red:0.52,green:0.24,blue:1.00), Color(red:0.30,green:0.10,blue:0.82)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            ))
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                                    }
                                )
                                .shadow(color: Color(red:0.45,green:0.18,blue:0.95).opacity(0.70), radius: 32, y: 12)
                                .shadow(color: Color(red:0.28,green:0.10,blue:0.65).opacity(0.40), radius: 60, y: 20)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                            .buttonStyle(DeepSpaceButtonStyle())
                            .opacity(phase5 ? 1 : 0)
                            .scaleEffect(phase5 ? 1 : 0.92)
                            .animation(.spring(response: 0.65, dampingFraction: 0.72), value: phase5)
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 100)
                    }
                    .frame(width: geo.size.width)
                }
            }
            .ignoresSafeArea()
            .onAppear { runEntrance(geo: geo) }
            .onDisappear {
                meteorTimer?.invalidate()
                NotificationCenter.default.post(name: .reinjectEmoji, object: nil)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Deep Space Background
    private var deepSpaceBackground: some View {
        ZStack {
            Color(red: 0.010, green: 0.008, blue: 0.055).ignoresSafeArea()
            RadialGradient(
                colors: [Color(red:0.22,green:0.06,blue:0.55).opacity(0.55), .clear],
                center: UnitPoint(x:0.1, y:0.9), startRadius: 0, endRadius: 420
            ).ignoresSafeArea()
            RadialGradient(
                colors: [Color(red:0.04,green:0.14,blue:0.50).opacity(0.45), .clear],
                center: UnitPoint(x:0.9, y:0.1), startRadius: 0, endRadius: 360
            ).ignoresSafeArea()
            RadialGradient(
                colors: [Color(red:0.28,green:0.08,blue:0.72).opacity(0.30), .clear],
                center: .center, startRadius: 0, endRadius: 300
            ).ignoresSafeArea()
        }
    }

    private var nebulaLayers: some View {
        ZStack {
            Ellipse()
                .fill(Color(red:0.05,green:0.40,blue:0.60).opacity(0.07))
                .frame(width: 340, height: 180)
                .blur(radius: 55)
                .offset(x: 100, y: -180)
            Ellipse()
                .fill(Color(red:0.65,green:0.12,blue:0.55).opacity(0.09))
                .frame(width: 280, height: 160)
                .blur(radius: 50)
                .offset(x: -120, y: 200)
        }
    }

    // MARK: - Constellation Canvas
    private func constellationCanvas(geo: GeometryProxy) -> some View {
        let cx = geo.size.width  / 2
        let cy = geo.size.height * 0.40

        return ZStack {
            ForEach(0..<lineIndices.count, id:\.self) { i in
                let (a, b) = lineIndices[i]
                let start = CGPoint(x: cx + nodeOffsets[a].width,  y: cy + nodeOffsets[a].height)
                let end   = CGPoint(x: cx + nodeOffsets[b].width,  y: cy + nodeOffsets[b].height)
                AnimatedLine(from: start, to: end, progress: lineDrawn[i])
            }
            ForEach(0..<nodeOffsets.count, id:\.self) { i in
                ConstellationNode(scale: nodeScales[i])
                    .position(x: cx + nodeOffsets[i].width, y: cy + nodeOffsets[i].height)
            }
        }
    }

    // MARK: - Main Orb
    private func mainOrb(geo: GeometryProxy) -> some View {
        let cx = geo.size.width  / 2
        let cy = geo.size.height * 0.40

        return ZStack {
            // Atmosphere bloom
            Circle()
                .fill(RadialGradient(
                    colors: [Color(red:0.45,green:0.18,blue:0.95).opacity(0.22), Color.clear],
                    center: .center, startRadius: 0, endRadius: 120
                ))
                .frame(width: 240, height: 240)
                .scaleEffect(pulseRing ? 1.10 : 0.92)
                .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: pulseRing)

            // Outer rotating arc
            Circle()
                .trim(from: 0.0, to: 0.65)
                .stroke(
                    AngularGradient(colors: [
                        Color(red:0.55,green:0.30,blue:1.00).opacity(0.0),
                        Color(red:0.55,green:0.30,blue:1.00).opacity(0.7),
                        Color(red:0.30,green:0.65,blue:1.00).opacity(0.4),
                        Color(red:0.55,green:0.30,blue:1.00).opacity(0.0),
                    ], center: .center),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
                .frame(width: 168, height: 168)
                .rotationEffect(.degrees(rotateRing1 ? 360 : 0))
                .animation(.linear(duration: 9).repeatForever(autoreverses: false), value: rotateRing1)

            // Inner counter-arc
            Circle()
                .trim(from: 0.0, to: 0.45)
                .stroke(
                    AngularGradient(colors: [
                        Color(red:0.30,green:0.75,blue:1.00).opacity(0.0),
                        Color(red:0.30,green:0.75,blue:1.00).opacity(0.6),
                        Color(red:0.30,green:0.75,blue:1.00).opacity(0.0),
                    ], center: .center),
                    style: StrokeStyle(lineWidth: 1.0, lineCap: .round)
                )
                .frame(width: 130, height: 130)
                .rotationEffect(.degrees(rotateRing2 ? -360 : 0))
                .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: rotateRing2)

            // Core sphere
            Circle()
                .fill(RadialGradient(
                    colors: [
                        Color(red:0.80,green:0.62,blue:1.00),
                        Color(red:0.50,green:0.22,blue:0.95),
                        Color(red:0.18,green:0.05,blue:0.55),
                    ],
                    center: UnitPoint(x:0.30, y:0.22),
                    startRadius: 0, endRadius: 52
                ))
                .frame(width: 100, height: 100)
                .shadow(color: Color(red:0.55,green:0.28,blue:1.0).opacity(0.95), radius: 40)
                .shadow(color: Color(red:0.28,green:0.55,blue:1.0).opacity(0.60), radius: 70)
                .overlay(
                    Ellipse()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 28, height: 18)
                        .offset(x: -14, y: -18)
                        .blur(radius: 4)
                )

            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(LinearGradient(
                    colors: [Color.white, Color(red:0.85,green:0.78,blue:1.0)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .shadow(color: Color.white.opacity(0.5), radius: 8)

            // Orbiting dot 1
            Circle()
                .fill(Color(red:0.55,green:0.85,blue:1.0))
                .frame(width: 6, height: 6)
                .shadow(color: Color(red:0.35,green:0.75,blue:1.0), radius: 6)
                .offset(y: -84)
                .rotationEffect(.degrees(rotateRing1 ? 360 : 0))
                .animation(.linear(duration: 9).repeatForever(autoreverses: false), value: rotateRing1)

            // Orbiting dot 2
            Circle()
                .fill(Color(red:0.90,green:0.65,blue:1.0))
                .frame(width: 4, height: 4)
                .shadow(color: Color(red:0.75,green:0.45,blue:1.0), radius: 5)
                .offset(y: -65)
                .rotationEffect(.degrees(rotateRing2 ? -360 : 0))
                .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: rotateRing2)
        }
        .offset(y: orbFloat ? -8 : 8)
        .animation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true), value: orbFloat)
        .opacity(phase2 ? 1 : 0)
        .scaleEffect(phase2 ? 1 : 0.55)
        .animation(.spring(response: 0.9, dampingFraction: 0.62).delay(0.05), value: phase2)
        .position(x: cx, y: cy)
    }

    // MARK: - Bottom Content
    private func bottomContent(geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 28) {

                // Title block
                VStack(spacing: 12) {
                    HStack(spacing: 7) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Color(red:0.72,green:0.55,blue:1.0))
                        Text("SPATIAL · AR · IMMERSIVE")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundStyle(Color(red:0.72,green:0.55,blue:1.0))
                            .kerning(2.5)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color(red:0.45,green:0.20,blue:0.95).opacity(0.18))
                            .overlay(Capsule().strokeBorder(Color(red:0.55,green:0.30,blue:1.0).opacity(0.35), lineWidth: 0.8))
                    )

                    ZStack {
                        Text("Constellation")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red:0.55,green:0.28,blue:1.0).opacity(0.6))
                            .blur(radius: 18)
                            .scaleEffect(1.05)
                        Text("Constellation")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(LinearGradient(
                                colors: [Color.white, Color(red:0.88,green:0.78,blue:1.00), Color(red:0.60,green:0.42,blue:1.00)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .tracking(-1.2)
                    }

                    Text("Questions orbit around you in AR space.\nAim your gaze · Lock on · Answer.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.40))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                .opacity(phase4 ? 1 : 0)
                .offset(y: phase4 ? 0 : 30)
                .animation(.spring(response: 0.7, dampingFraction: 0.78), value: phase4)

                // Stats row
                HStack(spacing: 10) {
                    LaunchStatPill(value: "360°", label: "Spatial",    icon: "rotate.3d")
                    LaunchStatPill(value: "AR",   label: "Real Space", icon: "arkit")
                    LaunchStatPill(value: "XP",   label: "Rewards",    icon: "bolt.fill")
                    LaunchStatPill(value: "Live", label: "Score",      icon: "flame.fill")
                }
                .opacity(phase4 ? 1 : 0)
                .offset(y: phase4 ? 0 : 20)
                .animation(.spring(response: 0.65, dampingFraction: 0.78).delay(0.10), value: phase4)

                // CTA
                NavigationLink {
                    ARConstellationQuizView(viewModel: viewModel)
                } label: {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(LinearGradient(
                                colors: [Color.clear, Color.white.opacity(shimmerPhase ? 0.10 : 0.0), Color.clear],
                                startPoint: UnitPoint(x: shimmerPhase ? 1.4 : -0.4, y: 0.3),
                                endPoint:   UnitPoint(x: shimmerPhase ? 2.0 : 0.2,  y: 0.8)
                            ))
                            .allowsHitTesting(false)

                        HStack(spacing: 16) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.14)).frame(width: 48, height: 48)
                                Circle().strokeBorder(Color.white.opacity(0.20), lineWidth: 1).frame(width: 48, height: 48)
                                Image(systemName: "arkit").font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Enter Constellation")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundStyle(.white).tracking(-0.3)
                                Text("Augmented Reality Experience")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.white.opacity(0.50))
                            }
                            Spacer()
                            ZStack {
                                Circle().fill(Color.white.opacity(0.18)).frame(width: 36, height: 36)
                                Image(systemName: "arrow.right").font(.system(size: 13, weight: .black)).foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 14)
                    }
                    .frame(maxWidth: .infinity).frame(height: 76)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(LinearGradient(
                                    colors: [Color(red:0.52,green:0.24,blue:1.00), Color(red:0.30,green:0.10,blue:0.82)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                        }
                    )
                    .shadow(color: Color(red:0.45,green:0.18,blue:0.95).opacity(0.70), radius: 32, y: 12)
                    .shadow(color: Color(red:0.28,green:0.10,blue:0.65).opacity(0.40), radius: 60, y: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(DeepSpaceButtonStyle())
                .opacity(phase5 ? 1 : 0)
                .scaleEffect(phase5 ? 1 : 0.92)
                .animation(.spring(response: 0.65, dampingFraction: 0.72), value: phase5)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 44)
        }
    }

    // MARK: - Entrance Sequence

    private func runEntrance(geo: GeometryProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)  { withAnimation { phase1 = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20)  {
            phase2 = true; orbFloat = true; pulseRing = true; rotateRing1 = true; rotateRing2 = true
        }
        for i in 0..<lineIndices.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45 + Double(i) * 0.10) {
                withAnimation(.easeOut(duration: 0.5)) { lineDrawn[i] = 1.0 }
            }
        }
        for i in 0..<nodeOffsets.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45 + Double(i) * 0.08) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { nodeScales[i] = 1.0 }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { withAnimation { phase4 = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) { withAnimation { phase5 = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) { shimmerPhase = true }
        }
        spawnMeteors()
        meteorTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in spawnMeteors() }
    }

    private func spawnMeteors() {
        let newMeteors = (0..<Int.random(in: 1...2)).map { _ in MeteorData() }
        withAnimation { meteors.append(contentsOf: newMeteors) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if meteors.count > 6 { meteors.removeFirst(meteors.count - 6) }
        }
    }
}

// MARK: - Animated Line

struct AnimatedLine: View {
    let from: CGPoint
    let to:   CGPoint
    let progress: CGFloat

    var body: some View {
        let dx  = to.x - from.x
        let dy  = to.y - from.y
        let end = CGPoint(x: from.x + dx * progress, y: from.y + dy * progress)

        return Path { p in p.move(to: from); p.addLine(to: end) }
            .stroke(
                LinearGradient(
                    colors: [
                        Color(red:0.55,green:0.30,blue:1.00).opacity(0.15),
                        Color(red:0.55,green:0.35,blue:1.00).opacity(0.65),
                        Color(red:0.35,green:0.65,blue:1.00).opacity(0.40),
                    ],
                    startPoint: UnitPoint(x: from.x / UIScreen.main.bounds.width,
                                         y: from.y / UIScreen.main.bounds.height),
                    endPoint:   UnitPoint(x: end.x  / UIScreen.main.bounds.width,
                                         y: end.y   / UIScreen.main.bounds.height)
                ),
                style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
            )
    }
}

// MARK: - Constellation Node

struct ConstellationNode: View {
    let scale: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red:0.55,green:0.32,blue:1.0).opacity(0.35))
                .frame(width: 16, height: 16).blur(radius: 4)
            Circle()
                .fill(RadialGradient(
                    colors: [Color.white, Color(red:0.75,green:0.60,blue:1.0)],
                    center: .center, startRadius: 0, endRadius: 4
                ))
                .frame(width: 5, height: 5)
        }
        .scaleEffect(scale)
    }
}

// MARK: - Ambient Star Field

struct AmbientStarField: View {
    let size: CGSize
    let visible: Bool

    private struct Star: Identifiable {
        let id = UUID()
        let x, y, sz: CGFloat
        let delay, speed: Double
    }

    private let stars: [Star] = (0..<90).map { i in
        let s = Double(i)
        let f: (Double) -> CGFloat = { v in CGFloat((sin(v * 127.1 + 311.7) * 0.5 + 0.5)) }
        return Star(x: f(s), y: f(s+1), sz: f(s+2) * 2.2 + 0.4,
                    delay: Double(f(s+3)) * 3.0, speed: Double(f(s+4)) * 2.0 + 1.5)
    }

    var body: some View {
        ZStack {
            ForEach(stars) { star in
                Circle().fill(Color.white)
                    .frame(width: star.sz, height: star.sz)
                    .position(x: star.x * size.width, y: star.y * size.height)
                    .opacity(visible ? Double.random(in: 0.25...0.90) : 0)
                    .animation(
                        .easeInOut(duration: star.speed).repeatForever(autoreverses: true).delay(star.delay),
                        value: visible
                    )
            }
        }
    }
}

// MARK: - Meteor

struct MeteorData: Identifiable {
    let id     = UUID()
    let startX = CGFloat.random(in: 0.1...0.9) * UIScreen.main.bounds.width
    let startY = CGFloat.random(in: 0.0...0.3) * UIScreen.main.bounds.height
    let angle  = Double.random(in: 20...45)
    let length = CGFloat.random(in: 80...180)
    let speed  = Double.random(in: 0.8...1.8)
}

struct MeteorLayer: View {
    let meteors: [MeteorData]
    var body: some View {
        ZStack { ForEach(meteors) { MeteorView(data: $0) } }
    }
}

struct MeteorView: View {
    let data: MeteorData
    @State private var progress: CGFloat = 0

    var body: some View {
        let rad = data.angle * .pi / 180
        let endX = data.startX + cos(rad) * data.length * progress
        let endY = data.startY + sin(rad) * data.length * progress

        return Path { p in
            p.move(to: CGPoint(x: data.startX, y: data.startY))
            p.addLine(to: CGPoint(x: endX, y: endY))
        }
        .stroke(
            LinearGradient(
                colors: [Color.white.opacity(0), Color.white.opacity(0.7), Color.white.opacity(0)],
                startPoint: .leading, endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
        )
        .onAppear {
            withAnimation(.easeOut(duration: data.speed)) { progress = 1 }
        }
    }
}

// MARK: - Stat Pill

struct LaunchStatPill: View {
    let value: String
    let label: String
    let icon:  String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(Color(red:0.45,green:0.20,blue:0.95).opacity(0.20)).frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(red:0.72,green:0.55,blue:1.0))
            }
            Text(value).font(.system(size: 14, weight: .black, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.38)).lineLimit(1).minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color(red:0.55,green:0.30,blue:1.0).opacity(0.35),
                                         Color(red:0.30,green:0.55,blue:1.0).opacity(0.20)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ), lineWidth: 0.8
                        )
                )
        )
    }
}

// MARK: - Button Style

struct DeepSpaceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.68), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ConstellationLauncherView(viewModel: QuestionViewModel())
    }
}
