//
//  QuizMode.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 22/02/26.
//

import Foundation

enum QuizMode: String, CaseIterable {
    case normal
    case ar
    
    var title: String {
        switch self {
        case .normal: return "Normal Mode"
        case .ar: return "AR Palace Mode"
        }
    }
    
    var description: String {
        switch self {
        case .normal:
            return "Quick daily practice with a clean, distraction-free interface."
        case .ar:
            return "Immersive spatial learning experience in augmented reality."
        }
    }
    
    var icon: String {
        switch self {
        case .normal: return "rectangle.stack.fill"
        case .ar: return "arkit"
        }
    }
}
