////
////  QuestionAPIService.swift
////  LociLearn
////
////  Created by Lakshman Ryali on 22/02/26.
////
//
//import Foundation
//
//class QuestionAPIService {
//
//    func fetchQuestions(
//        amount: Int,
//        category: Int,
//        difficulty: String
//    ) async throws -> [Question] {
//
//        let urlString =
//        "https://locilearn-backend.onrender.com/api/questions?amount=\(amount)&category=\(category)&difficulty=\(difficulty)"
//
//        guard let url = URL(string: urlString) else { return [] }
//
//        let (data, _) = try await URLSession.shared.data(from: url)
//
//        let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
//        return decoded.questions
//    }
//}
//
//struct APIResponse: Codable {
//    let questions: [Question]
//}
//
