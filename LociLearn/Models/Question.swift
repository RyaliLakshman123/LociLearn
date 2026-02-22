//
//  Question.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 21/02/26.
//

import Foundation
import UIKit

// MARK: - API Response Wrapper
struct TriviaResponse: Decodable {
    let results: [TriviaQuestion]
}

// MARK: - Raw API Question
struct TriviaQuestion: Decodable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

// MARK: - App Model
struct Question: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: String
    
    init(from apiModel: TriviaQuestion) {
        self.question = apiModel.question.decodedHTML
        self.correctAnswer = apiModel.correct_answer.decodedHTML
        
        let allOptions = (apiModel.incorrect_answers + [apiModel.correct_answer])
            .map { $0.decodedHTML }
            .shuffled()
        
        self.options = allOptions
    }
}

// MARK: - HTML Decode Helper
extension String {
    var decodedHTML: String {
        guard let data = data(using: .utf8) else { return self }
        let attributed = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
        return attributed?.string ?? self
    }
}
