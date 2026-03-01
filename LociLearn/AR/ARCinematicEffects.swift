//
//  ARCinematicEffects.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 23/02/26.
//

import RealityKit
import UIKit
import Combine

struct ARCinematicEffects {
    
    static func addGlow(to entity: ModelEntity) {
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor.white.withAlphaComponent(0.85))
        material.metallic = .float(0)
        material.roughness = .float(0.2)
        
        entity.model?.materials = [material]
    }
    
    static func pulse(_ entity: Entity) {
        entity.move(
            to: Transform(scale: [1.25,1.25,1.25]),
            relativeTo: entity,
            duration: 0.25,
            timingFunction: .easeInOut
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            entity.move(
                to: Transform(scale: [1,1,1]),
                relativeTo: entity,
                duration: 0.25,
                timingFunction: .easeInOut
            )
        }
    }
}
