////
////  DailyChallengeViewModel.swift
////  LociLearn
////
////  Created by Sameer Nikhil on 22/02/26.
////
//
//import Foundation
//import SwiftUI
//import Combine
//
//@MainActor
//final class DailyChallengeViewModel: ObservableObject {
//
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published var dailySubject: Subject = .biology
//    @Published var dailyQuestions: [Question] = []
//    
//    private let service = QuizAPIService()
//
//    // MARK: - Compute Today's Subject
//    private func subjectForToday() -> Subject {
//        let subjects = Subject.allCases
//        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
//        return subjects[dayIndex % subjects.count]
//    }
//
//    // MARK: - Load Daily Challenge
//    func loadDailyChallenge() async {
//        isLoading = true
//        errorMessage = nil
//        
//        dailySubject = subjectForToday()
//        
//        do {
//            let questions = try await service.fetchQuestions(
//                amount: 5,
//                subject: dailySubject,
//                difficulty: "medium"
//            )
//            
//            dailyQuestions = questions
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        
//        isLoading = false
//    }
//}
