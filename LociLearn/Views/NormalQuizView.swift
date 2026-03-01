//
//  NormalQuizView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 22/02/26.
//


import SwiftUI

struct NormalQuizView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var questionKey = UUID()
    @State private var appeared    = false
    @State private var isLoading = true
    @State private var loadError: String?
    let subject: Subject
    let difficulty: String
    let count: Int
    
    var body: some View {
        ZStack {
            // 1 - Background
            AppBackgroundView()

            // 2 - Ambient glow
            RadialGradient(
                colors: [ambientColor.opacity(0.14), Color.clear],
                center: .center, startRadius: 0, endRadius: 480
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.55), value: viewModel.selectedAnswer)

            // 3 - Main content
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.questions.isEmpty {
                    Text("No questions available.")
                        .foregroundStyle(.white)
                } else {
                    
                // ── Top bar ──
                HStack(spacing: 14) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.textSub)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }.buttonStyle(.plain)
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08)).frame(height: 5)
                            Capsule()
                                .fill(LinearGradient(colors: [Color.brandSoft, Color.brand],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * viewModel.progress, height: 5)
                                .animation(.spring(response: 0.5), value: viewModel.progress)
                        }
                    }.frame(height: 5)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").font(.system(size: 10)).foregroundStyle(Color.warn)
                        Text("\(viewModel.score)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.white.opacity(0.08)).clipShape(Capsule())
                }
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 28)
                
                // ── Question label ──
                HStack {
                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                        .font(.system(size: 11, weight: .semibold)).foregroundStyle(Color.brandSoft)
                        .kerning(1.2).textCase(.uppercase)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.bottom, 14)
                
                // ── Question card ──
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.surface1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    Text(viewModel.currentQuestion?.question ?? "")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(26)
                }
                .padding(.horizontal, 20)
                .id(questionKey)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.42, dampingFraction: 0.82), value: questionKey)
                
                Spacer(minLength: 24)
                
                // ── Options ──
                    VStack(spacing: 10) {

                        if let question = viewModel.currentQuestion {

                            ForEach(Array(question.options.enumerated()), id: \.offset) { idx, option in
                                NormalOptionButton(
                                    option: option,
                                    label: ["A","B","C","D"][idx],
                                    isSelected: viewModel.selectedAnswer == option,
                                    isCorrect: option == question.correctAnswer,
                                    hasAnswered: viewModel.selectedAnswer != nil
                                ) {
                                    viewModel.selectAnswer(option)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                
                // ── Next / Finish ──
                if viewModel.selectedAnswer != nil {
                    Button {
                        if viewModel.isLastQuestion {
                            viewModel.showConfetti = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                dismiss()
                            }
                        } else {
                            viewModel.currentQuestionIndex += 1
                            viewModel.selectedAnswer = nil
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(viewModel.isLastQuestion ? "Finish" : "Next Question")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Image(systemName: viewModel.isLastQuestion ? "checkmark" : "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.brand)
                                .shadow(color: Color.brand.opacity(0.45), radius: 18, x: 0, y: 6)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer(minLength: 24)
              }

            } // ← VStack closes here

            // 4 - Confetti LAST so it renders on top
            if viewModel.showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

        } // ← ZStack closes here
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.selectedAnswer)
        .navigationBarHidden(true)
        .task {
            await loadQuestions()
        }
        .onChange(of: viewModel.currentQuestionIndex) { _ in questionKey = UUID() }
    }

    private var ambientColor: Color {
        guard let sel = viewModel.selectedAnswer else { return Color.brand }
        return sel == viewModel.correctAnswer ? .success : .danger
    }
    
    @MainActor
    private func loadQuestions() async {
        
        isLoading = true
        
        do {
            let fetched = try await fetchQuestions()
            
            viewModel.questions = fetched
            print("Fetched count:", fetched.count)
            viewModel.currentQuestionIndex = 0
            viewModel.selectedAnswer = nil
            viewModel.score = 0
            
            isLoading = false
            
        } catch {
            print("API error:", error)
            isLoading = false
        }
    }
    
    private var categoryID: Int {
        switch subject {
        case .biology:
            return 17   // Science & Nature
        case .computerScience:
            return 18   // Science: Computers
        case .solar:
            return 17   // Science & Nature (planets)
        }
    }
    
    private func fetchQuestions() async throws -> [Question] {
        
        let urlString =
        "https://opentdb.com/api.php?amount=\(count)&category=\(categoryID)&difficulty=\(difficulty)&type=multiple"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(LocalTriviaResponse.self, from: data)

        return decoded.results.map { api in
            
            let options = (api.incorrect_answers + [api.correct_answer]).shuffled()

            return Question(
                question: api.question.htmlDecoded,
                options: options.map { $0.htmlDecoded },
                correctAnswer: api.correct_answer.htmlDecoded,
                topic: subject.title
            )
        }
    }
}

// MARK: - Normal Option Button
struct NormalOptionButton: View {
    let option: String; let label: String
    let isSelected: Bool; let isCorrect: Bool; let hasAnswered: Bool
    let action: () -> Void

    private var state: AnswerButtonState {
        guard hasAnswered else { return .idle }
        if isCorrect  { return .correct }
        if isSelected { return .wrong }
        return .dimmed
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(badgeBg).frame(width: 36, height: 36)
                    Text(label)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(badgeFg)
                }
                Text(option)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(state == .dimmed ? Color.textMuted : .white)
                    .multilineTextAlignment(.leading).lineLimit(3)
                Spacer()
                Group {
                    if state == .correct {
                        Image(systemName: "checkmark.circle.fill").font(.title3).foregroundStyle(Color.success)
                            .transition(.scale(scale: 0.2).combined(with: .opacity))
                    } else if state == .wrong {
                        Image(systemName: "xmark.circle.fill").font(.title3).foregroundStyle(Color.danger)
                            .transition(.scale(scale: 0.2).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: state)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(rowBg)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(hasAnswered)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: state)
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
        case .idle:    return AnyShapeStyle(Color.white.opacity(0.05))
        case .correct: return AnyShapeStyle(Color.success.opacity(0.10))
        case .wrong:   return AnyShapeStyle(Color.danger.opacity(0.10))
        case .dimmed:  return AnyShapeStyle(Color.white.opacity(0.02))
        }
    }
    private var borderColor: Color {
        switch state {
        case .idle:    return Color.white.opacity(0.09)
        case .correct: return Color.success.opacity(0.65)
        case .wrong:   return Color.danger.opacity(0.65)
        case .dimmed:  return Color.clear
        }
    }
}

#Preview {
    NormalQuizView(
        viewModel: QuestionViewModel(),
        subject: .biology,
        difficulty: "easy",
        count: 10
    )
}

// MARK: - API Models
struct LocalTriviaResponse: Codable {
    let response_code: Int
    let results: [LocalTriviaQuestion]
}

struct LocalTriviaQuestion: Codable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

extension String {
    var htmlDecoded: String {
        guard let data = data(using: .utf8) else { return self }
        return (try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        ).string) ?? self
    }
}

