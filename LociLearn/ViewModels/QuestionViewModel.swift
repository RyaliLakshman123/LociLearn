//
//  QuestionViewModel.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 21/02/26.
//


import Foundation
import SwiftUI
import Combine
import ARKit

// MARK: - Answered Question (for history)
struct AnsweredQuestion: Identifiable {
    let id = UUID()
    let question: Question
    let selectedAnswer: String
    let isCorrect: Bool
}

@MainActor
final class QuestionViewModel: ObservableObject {

    // MARK: - Published State
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // AR triggers
    @Published var placeCardTrigger: Bool = false
    @Published var refreshCardTrigger: Bool = false   // ✅ NEW: forces card to redraw after next question
    @Published var isCardFlipped: Bool = false
    @Published var selectedAnswer: String? = nil

    // History
    @Published var answeredQuestions: [AnsweredQuestion] = []  // ✅ NEW
    @Published var showHistory: Bool = false                   // ✅ NEW

   // MARK: - Computed
    var correctAnswer: String {
        currentQuestion?.correctAnswer ?? ""
    }

    var currentQuestion: Question? {
        guard questions.indices.contains(currentQuestionIndex) else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }

    var isLastQuestion: Bool {
        currentQuestionIndex >= questions.count - 1
    }

    // MARK: - Actions
   func selectAnswer(_ option: String) {
        selectedAnswer = option
        if option == correctAnswer { score += 1 }
        
        answeredQuestions.append(AnsweredQuestion(
            question: currentQuestion!,
            selectedAnswer: option,
            isCorrect: option == correctAnswer
        ))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isCardFlipped = false
            self.selectedAnswer = nil
            self.nextQuestion()
            // ✅ Small delay so camera has settled before refresh
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.refreshCardTrigger.toggle()
            }
        }
    }

    func fetchQuestions() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let fetched = try await TriviaAPIService.shared.fetchQuestions()
                questions = fetched
                currentQuestionIndex = 0
                answeredQuestions = []
                score = 0
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
        }
    }
}
