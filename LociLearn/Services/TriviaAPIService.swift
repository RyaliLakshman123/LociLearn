////
////  TriviaAPIService.swift
////  LociLearn
////
////  Created by Sameer Nikhil on 21/02/26.
////
//
//import Foundation
//
//final class TriviaAPIService {
//    
//    static let shared = TriviaAPIService()
//    private init() {}
//    
//    private let baseURL = "https://opentdb.com/api.php?amount=20&type=multiple"
//    
//    func fetchQuestions() async throws -> [Question] {
//        guard let url = URL(string: baseURL) else {
//            throw URLError(.badURL)
//        }
//        
//        let (data, response) = try await URLSession.shared.data(from: url)
//        
//        guard let httpResponse = response as? HTTPURLResponse,
//              200..<300 ~= httpResponse.statusCode else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
//        
//        return decoded.results.map { Question(apiModel: $0) }
//    }
//}
