//
//  StartViewModel.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 22/02/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class StartViewModel: ObservableObject {
    
    @Published var selectedSubject: Subject = .biology
    @Published var selectedDifficulty: String = "medium"
    @Published var questionCount: Int = 10
    @Published var selectedMode: QuizMode = .normal
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func startQuiz(with quizVM: QuestionViewModel) async {
        
        // Reset quiz state
        quizVM.selectedAnswer = nil
        quizVM.currentQuestionIndex = 0
        quizVM.answeredQuestions = []
        quizVM.score = 0
        quizVM.streak = 0
        
        isLoading = true
        errorMessage = nil
        
        // Use hardcoded subject questions
        quizVM.startSubjectMode(selectedSubject)
        
        // Apply question count limit
        quizVM.questions = Array(quizVM.questions.prefix(questionCount))
        
        isLoading = false
    }
}
