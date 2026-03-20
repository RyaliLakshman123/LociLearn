//
//  SolarLevelSystem.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 23/02/26.
//

import Foundation

enum SolarLevel: String {
    case beginner
    case explorer
    case thinker
    case master
    case nightOwl
}

struct SolarLevelManager {
    
    static func level(for xp: Int) -> SolarLevel {
        switch xp {
        case 0..<50: return .beginner
        case 50..<150: return .explorer
        case 150..<300: return .thinker
        case 300..<600: return .master
        default: return .nightOwl
        }
    }
}
