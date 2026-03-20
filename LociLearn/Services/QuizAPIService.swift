////
////  QuizAPIService.swift
////  LociLearn
////
////  Created by Lakshman Ryali on 22/02/26.
////
//
//
//import Foundation
//
//final class QuizAPIService {
//    
//    func fetchQuestions(
//        amount: Int,
//        subject: Subject,
//        difficulty: String
//    ) async throws -> [Question] {
//        
//        guard let url = APIEndpoint.questions(
//            amount: amount,
//            subject: subject,
//            difficulty: difficulty
//        ) else { throw URLError(.badURL) }
//        
//        var attempts = 0
//        var lastError: Error?
//        
//        while attempts < 3 {
//            do {
//                let (data, response) = try await URLSession.shared.data(from: url)
//                
//                guard let http = response as? HTTPURLResponse,
//                      http.statusCode == 200 else {
//                    throw URLError(.badServerResponse)
//                }
//                
//                let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
//                return decoded.results.map { Question(apiModel: $0) }
//                
//            } catch {
//                lastError = error
//                attempts += 1
//                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
//            }
//        }
//        
//        throw lastError ?? URLError(.cannotLoadFromNetwork)
//    }
//}
