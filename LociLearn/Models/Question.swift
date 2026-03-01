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

// MARK: - Raw API Question (from OpenTrivia)
struct TriviaQuestion: Decodable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

// MARK: - App Model (Cleaned + Shuffled)
struct Question {
    let question: String
    let options: [String]
    let correctAnswer: String
    let topic: String

    init(question: String,
         options: [String],
         correctAnswer: String,
         topic: String) {
        
        self.question = question
        self.correctAnswer = correctAnswer
        self.topic = topic
        
        // ✅ Automatically shuffle options
        self.options = options.shuffled()
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

