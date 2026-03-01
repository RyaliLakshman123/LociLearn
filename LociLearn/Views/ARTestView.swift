//
//  ARTestView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 24/02/26.
//

// MARK: - Paste this TEMPORARILY anywhere in your project and navigate to it
// This is a dead-simple AR test with zero extras — if this shows camera, the
// bug is in ARPalaceView's surrounding SwiftUI. If this is also black, it's
// a device/permission/signing issue.

import SwiftUI
import ARKit
import RealityKit

struct ARTestView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> ARTestVC {
        ARTestVC()
    }

    func updateUIViewController(_ vc: ARTestVC, context: Context) {}
}

class ARTestVC: UIViewController {

    private var arView: ARView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Only set up once, after the view has a real frame
        guard arView == nil, view.bounds.width > 0 else { return }

        arView = ARView(frame: view.bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(arView)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
    }
}

// ── Use it like this in any SwiftUI view ──
struct ARTestWrapper: View {
    var body: some View {
        ARTestView()
            .ignoresSafeArea()
    }
}
