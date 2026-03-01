//
//  ARPalaceView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 21/02/26.
//

//
//  ARPalaceView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 21/02/26.
//

import SwiftUI
import ARKit
import SceneKit
import AVFoundation

// MARK: - Main View

struct ARPalaceView: View {

    @ObservedObject var viewModel: QuestionViewModel
    @State private var showQuizComplete = false

    var body: some View {
        ZStack {
            ARSceneContainer(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            ARHUDView(viewModel: viewModel)

            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                    Text("Loading questions…")
                        .foregroundStyle(.white)
                        .font(.caption)
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if viewModel.isCardFlipped {
                OptionsOverlay(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8),
                               value: viewModel.isCardFlipped)
            }
        }
        .onDisappear {
            NotificationCenter.default.post(name: .reinjectEmoji, object: nil)
        }
        .onAppear {
            viewModel.arQuestions = []
            viewModel.currentARQuestionIndex = 0
            viewModel.selectedAnswer = nil
            viewModel.isCardFlipped = false
            viewModel.arModeActive = false
            viewModel.startSolarMode()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.placeCardTrigger = true
            }
        }
        .sheet(isPresented: $viewModel.showHistory) {
            HistoryView(viewModel: viewModel)
        }
        .onChange(of: viewModel.isARLastQuestion) { _, isLast in
            if isLast && !viewModel.answeredQuestions.isEmpty {
                showQuizComplete = true
            }
        }
        .sheet(isPresented: $showQuizComplete) {
            QuizCompleteView(viewModel: viewModel)
        }
    }
}

// MARK: - HUD

struct ARHUDView: View {

    @ObservedObject var viewModel: QuestionViewModel

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 12) {
                
                Button {
                    viewModel.placeCardTrigger.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 52, height: 52)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text("\(viewModel.score) pts")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Text("Q \(viewModel.currentARQuestionIndex + 1) of \(max(1, viewModel.arQuestions.count))")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 3)
                
                Button {
                    viewModel.showHistory = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 44, height: 44)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 3)
                        Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                .opacity(viewModel.answeredQuestions.isEmpty ? 0.4 : 1)
                .disabled(viewModel.answeredQuestions.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(height: 3)
                    Rectangle()
                        .fill(LinearGradient(colors: [.cyan, .blue],
                                             startPoint: .leading,
                                             endPoint: .trailing))
                        .frame(width: geo.size.width * arProgress, height: 3)
                        .animation(.spring(response: 0.5), value: arProgress)
                }
            }
            .frame(height: 3)
            .padding(.horizontal, 20)
            .padding(.top, 4)
            
            Spacer()
            
            if !viewModel.isCardFlipped {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.arModeActive ? "hand.tap.fill" : "plus.circle.fill")
                        .font(.caption)
                    Text(viewModel.arModeActive ? "Tap the card to reveal answers" : "Tap + to place your question card")
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 8)
                .padding(.bottom, 28)
                .animation(.easeInOut(duration: 0.3), value: viewModel.arModeActive)
            }
        }
    }

    private var arProgress: Double {
        let n = viewModel.arQuestions.count
        guard n > 0 else { return 0 }
        return Double(viewModel.currentARQuestionIndex) / Double(n)
    }
}

// MARK: - AR Scene Container
// Uses ARSCNView (pure ARKit + SceneKit) — completely avoids
// the RealityKit 'arKitPassthrough.rematerial' black screen bug.

struct ARSceneContainer: UIViewControllerRepresentable {

    @ObservedObject var viewModel: QuestionViewModel

    func makeUIViewController(context: Context) -> ARSceneVC {
        let vc = ARSceneVC()
        vc.viewModel = viewModel
        return vc
    }

    func updateUIViewController(_ vc: ARSceneVC, context: Context) {
        if viewModel.placeCardTrigger && !viewModel.arQuestions.isEmpty {
            DispatchQueue.main.async { viewModel.placeCardTrigger = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                vc.placeCard()
            }
        }
        if viewModel.refreshCardTrigger != vc.lastRefreshTrigger
            && !viewModel.arQuestions.isEmpty {
            vc.lastRefreshTrigger = viewModel.refreshCardTrigger
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                vc.placeCard()
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    class Coordinator: NSObject {}
}

// MARK: - AR Scene View Controller

class ARSceneVC: UIViewController, ARSCNViewDelegate {

    var viewModel: QuestionViewModel?
    var lastRefreshTrigger: Bool = false

    private var sceneView: ARSCNView!
    private var cardNode: SCNNode?
    private var sessionStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !sessionStarted, view.bounds.width > 0 else { return }
        sessionStarted = true

        // ARSCNView — pure ARKit camera, no RealityKit shaders
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.delegate = self
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = true
        view.addSubview(sceneView)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        sceneView.session.run(config)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView?.session.pause()
    }

    // MARK: - Place Card

    func placeCard() {
        guard let sceneView = sceneView,
              let frame = sceneView.session.currentFrame,
              let vm = viewModel,
              vm.arQuestions.indices.contains(vm.currentARQuestionIndex) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.placeCard() }
            return
        }

        cardNode?.removeFromParentNode()

        let question = vm.arQuestions[vm.currentARQuestionIndex].question
        let qNum     = vm.currentARQuestionIndex + 1
        let total    = vm.arQuestions.count

        DispatchQueue.main.async { vm.isCardFlipped = false }

        let camTransform = frame.camera.transform
        let camPos = SIMD3<Float>(camTransform.columns.3.x,
                                  camTransform.columns.3.y,
                                  camTransform.columns.3.z)
        let rawFwd = SIMD3<Float>(-camTransform.columns.2.x, 0, -camTransform.columns.2.z)
        let fwd    = simd_length(rawFwd) > 0.001 ? simd_normalize(rawFwd) : SIMD3<Float>(0, 0, -1)

        let node = makeCardNode(question: question, qNum: qNum, total: total)
        node.position = SCNVector3(camPos.x + fwd.x * 1.1,
                                   camPos.y + 0.05,
                                   camPos.z + fwd.z * 1.1)
        node.eulerAngles.y = atan2(fwd.x, fwd.z)

        sceneView.scene.rootNode.addChildNode(node)
        cardNode = node

        DispatchQueue.main.async { vm.arModeActive = true }
    }

    // MARK: - Tap Handler

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let sceneView = sceneView else { return }
        let loc  = gesture.location(in: sceneView)
        let hits = sceneView.hitTest(loc, options: [
            SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue
        ])
        let tapped = hits.first {
            $0.node.name == "questionCard" || $0.node.parent?.name == "questionCard"
        }
        if tapped != nil { flipCard() }
    }

    private func flipCard() {
        guard let card = cardNode else { return }
        let flip = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 0.4)
        flip.timingMode = .easeInEaseOut
        card.runAction(flip)
        DispatchQueue.main.async { self.viewModel?.isCardFlipped = true }
    }

    // MARK: - Build Card Node

    private func makeCardNode(question: String, qNum: Int, total: Int) -> SCNNode {
        let W: CGFloat = 0.60
        let H: CGFloat = 0.42
        let image = renderCardImage(question: question, qNum: qNum, total: total)

        // Main card
        let plane = SCNPlane(width: W, height: H)
        plane.cornerRadius = 0.022
        let mat = SCNMaterial()
        mat.diffuse.contents = image
        mat.isDoubleSided = true
        plane.materials = [mat]
        let cardNode = SCNNode(geometry: plane)
        cardNode.name = "questionCard"

        // Outer glow
        let glowPlane = SCNPlane(width: W + 0.045, height: H + 0.045)
        glowPlane.cornerRadius = 0.035
        let glowMat = SCNMaterial()
        glowMat.diffuse.contents = UIColor(red: 0.38, green: 0.20, blue: 0.90, alpha: 0.25)
        glowMat.isDoubleSided = true
        glowPlane.materials = [glowMat]
        let glowNode = SCNNode(geometry: glowPlane)
        glowNode.position = SCNVector3(0, 0, -0.002)

        // Mid glow
        let midPlane = SCNPlane(width: W + 0.020, height: H + 0.020)
        midPlane.cornerRadius = 0.026
        let midMat = SCNMaterial()
        midMat.diffuse.contents = UIColor(red: 0.55, green: 0.30, blue: 1.00, alpha: 0.30)
        midMat.isDoubleSided = true
        midPlane.materials = [midMat]
        let midNode = SCNNode(geometry: midPlane)
        midNode.position = SCNVector3(0, 0, -0.001)

        let container = SCNNode()
        container.addChildNode(glowNode)
        container.addChildNode(midNode)
        container.addChildNode(cardNode)
        return container
    }

    // MARK: - Render Card Image

    private func renderCardImage(question: String, qNum: Int, total: Int) -> UIImage {
        let size = CGSize(width: 1024, height: 720)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let c = ctx.cgContext

            let bg = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [UIColor(red:0.10,green:0.02,blue:0.30,alpha:1).cgColor,
                         UIColor(red:0.25,green:0.05,blue:0.60,alpha:1).cgColor,
                         UIColor(red:0.10,green:0.20,blue:0.80,alpha:1).cgColor] as CFArray,
                locations: [0, 0.5, 1.0])!
            c.drawLinearGradient(bg, start: .zero,
                                 end: CGPoint(x: size.width, y: size.height), options: [])

            UIColor(white: 1, alpha: 0.03).setFill()
            for _ in 0..<800 {
                c.fillEllipse(in: CGRect(x: CGFloat.random(in: 0...size.width),
                                         y: CGFloat.random(in: 0...size.height),
                                         width: 1.5, height: 1.5))
            }

            c.saveGState()
            c.clip(to: CGRect(x: 0, y: 0, width: size.width, height: 10))
            let accent = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [UIColor(red:0.20,green:0.90,blue:1,alpha:1).cgColor,
                         UIColor(red:0.70,green:0.30,blue:1,alpha:1).cgColor] as CFArray,
                locations: [0, 1.0])!
            c.drawLinearGradient(accent, start: .zero,
                                 end: CGPoint(x: size.width, y: 0), options: [])
            c.restoreGState()

            let badge = NSAttributedString(
                string: "Q\(qNum)  ·  \(qNum) of \(total)",
                attributes: [.font: UIFont.systemFont(ofSize: 28, weight: .bold),
                             .foregroundColor: UIColor(red:0.70,green:0.90,blue:1,alpha:0.90)])
            let bs = badge.size()
            badge.draw(at: CGPoint(x: (size.width - bs.width)/2, y: 32))

            c.saveGState()
            let div = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [UIColor.clear.cgColor,
                         UIColor(white:1,alpha:0.25).cgColor,
                         UIColor.clear.cgColor] as CFArray,
                locations: [0, 0.5, 1.0])!
            c.clip(to: CGRect(x: 60, y: 84, width: size.width - 120, height: 1.5))
            c.drawLinearGradient(div,
                                 start: CGPoint(x: 60, y: 84),
                                 end: CGPoint(x: size.width - 60, y: 84), options: [])
            c.restoreGState()

            let para = NSMutableParagraphStyle()
            para.alignment = .center
            para.lineSpacing = 6
            NSAttributedString(string: question, attributes: [
                .font: UIFont.systemFont(ofSize: 42, weight: .semibold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: para
            ]).draw(in: CGRect(x: 60, y: 110,
                               width: size.width - 120,
                               height: size.height - 200))

            let hint = NSAttributedString(
                string: "✦  tap to reveal answers  ✦",
                attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium),
                             .foregroundColor: UIColor(red:0.80,green:0.70,blue:1,alpha:0.60)])
            let hs = hint.size()
            hint.draw(at: CGPoint(x: (size.width - hs.width)/2, y: size.height - 60))
        }
    }
}

// MARK: - Preview
#Preview { ARPalaceView(viewModel: QuestionViewModel()) }
