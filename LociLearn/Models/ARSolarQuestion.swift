//
//  ARSolarQuestion.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 23/02/26.
//

import Foundation

struct ARSolarQuestion {
    let question: String
    let correctPlanet: PlanetType
}

enum PlanetType: String, CaseIterable {
    case mercury
    case venus
    case earth
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
}
