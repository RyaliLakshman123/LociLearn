//
//  ModelARView.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 24/02/26.
//

import SwiftUI
import RealityKit
import ARKit

struct ModelARView: UIViewRepresentable {
    
    let modelName: String
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        arView.automaticallyConfigureSession = false
        
        loadModel(into: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func loadModel(into arView: ARView) {
        
        guard let entity = try? ModelEntity.loadModel(named: modelName + ".usdz") else {
            print("❌ Failed to load \(modelName)")
            return
        }
        
        entity.generateCollisionShapes(recursive: true)
        
        let anchor = AnchorEntity(plane: .horizontal)
        entity.scale = [0.2, 0.2, 0.2]
        anchor.addChild(entity)
        
        arView.scene.addAnchor(anchor)
    }
}


//MARK: SubjectARView
struct SubjectARView: View {
    
    let subject: Subject
    @StateObject private var viewModel: QuestionViewModel
    
    init(subject: Subject) {
        self.subject = subject
        _viewModel = StateObject(wrappedValue: QuestionViewModel())
    }
    
    var body: some View {
        ZStack {
            
            if subject == .solar {
                ARPalaceView(viewModel: viewModel)
            } else if let modelName = subject.modelName {
                ModelARView(modelName: modelName)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            if subject != .solar {
                viewModel.startSubjectMode(subject)
            }
        }
    }
}
