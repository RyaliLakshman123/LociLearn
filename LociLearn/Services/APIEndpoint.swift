////
////  APIEndpoint.swift
////  LociLearn
////
////  Created by Lakshman Ryali on 22/02/26.
////
//
//import Foundation
//
//enum APIEndpoint {
//    
//    static func questions(amount: Int,
//                          subject: Subject,
//                          difficulty: String) -> URL? {
//        
//        let category = subject.categoryID
//        
//        var components = URLComponents(string: "https://opentdb.com/api.php")
//        components?.queryItems = [
//            URLQueryItem(name: "amount", value: "\(amount)"),
//            URLQueryItem(name: "category", value: "\(category)"),
//            URLQueryItem(name: "difficulty", value: difficulty),
//            URLQueryItem(name: "type", value: "multiple")
//        ]
//        
//        return components?.url
//    }
//}
