//
//  Subject.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 22/02/26.
//

import Foundation

enum Subject: String, CaseIterable, Identifiable {
    
    case solar
    case biology
    case computerScience
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .solar: return "Solar System"
        case .biology: return "Biology"
        case .computerScience: return "Computer Science"
        }
    }
    
    var modelName: String? {
        switch self {
        case .biology: return "AnimalCell"
        case .computerScience: return "Motherboard"
        case .solar: return nil
        }
    }
}
