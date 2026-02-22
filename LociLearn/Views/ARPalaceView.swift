//
//  ARPalaceView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 21/02/26.
//

import SwiftUI
import ARKit
import RealityKit

// MARK: - Main AR View

struct ARPalaceView: View {

    @ObservedObject var viewModel: QuestionViewModel
    @State private var showQuizComplete = false

    var body: some View {
        ZStack {
            // AR Scene
            ARViewContainer(viewModel: viewModel)
                .ignoresSafeArea()

            // HUD Layer
            ARHUDView(viewModel: viewModel)

            // Options Sheet
            if viewModel.isCardFlipped {
                OptionsOverlay(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isCardFlipped)
            }
        }
        .sheet(isPresented: $viewModel.showHistory) {
            HistoryView(viewModel: viewModel)
        }
        .onChange(of: viewModel.isLastQuestion) { _, isLast in
            if isLast && !viewModel.answeredQuestions.isEmpty {
                showQuizComplete = true
            }
        }
        .sheet(isPresented: $showQuizComplete) {
            QuizCompleteView(viewModel: viewModel)
        }
    }
}

// MARK: - HUD Overlay
struct ARHUDView: View {

    @ObservedObject var viewModel: QuestionViewModel

    var body: some View {
        VStack {
            // Top bar
            HStack(alignment: .center, spacing: 12) {

                // Place card button
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

                // Progress + Score pill
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text("\(viewModel.score) pts")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Text("\(viewModel.currentQuestionIndex + 1) / \(viewModel.questions.count)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 3)

                // History button
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

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(height: 3)
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [.cyan, .blue],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * viewModel.progress, height: 3)
                        .animation(.spring(response: 0.5), value: viewModel.progress)
                }
            }
            .frame(height: 3)
            .padding(.horizontal, 20)
            .padding(.top, 4)

            Spacer()

            // Bottom hint
            if !viewModel.isCardFlipped && !viewModel.questions.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption)
                    Text("Tap the card to reveal answer options")
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 8)
                .padding(.bottom, 28)
            }
        }
    }
}

// MARK: - AR View Container

struct ARViewContainer: UIViewRepresentable {

    @ObservedObject var viewModel: QuestionViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tap)
        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // ✅ Place card on + button press
        if viewModel.placeCardTrigger {
            context.coordinator.placeCardInFront()
        }
        // ✅ Refresh card when question advances
        if viewModel.refreshCardTrigger != context.coordinator.lastRefreshTrigger {
            context.coordinator.lastRefreshTrigger = viewModel.refreshCardTrigger
            context.coordinator.placeCardInFront()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    // MARK: Coordinator

    class Coordinator: NSObject {

        var viewModel: QuestionViewModel
        weak var arView: ARView?
        var lastRefreshTrigger: Bool = false

        init(viewModel: QuestionViewModel) {
            self.viewModel = viewModel
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = gesture.location(in: arView)

            guard let hit = arView.entity(at: location) else { return }

            // Walk up hierarchy looking for "questionCard"
            var current: Entity? = hit
            while let entity = current {
                if entity.name == "questionCard", let model = entity as? ModelEntity {
                    flipCard(model)
                    return
                }
                current = entity.parent
            }
        }

        func flipCard(_ model: ModelEntity) {
            var transform = model.transform
            transform.rotation *= simd_quatf(angle: .pi, axis: [0, 1, 0])
            model.move(to: transform,
                       relativeTo: model.parent,
                       duration: 0.4,
                       timingFunction: .easeInOut)
            DispatchQueue.main.async {
                self.viewModel.isCardFlipped.toggle()
            }
        }

        func placeCardInFront() {
            guard let arView = arView,
                  let question = viewModel.currentQuestion,
                  let frame = arView.session.currentFrame
            else { return }

            DispatchQueue.main.async { self.viewModel.placeCardTrigger = false }

            arView.scene.anchors.removeAll()

            let cam = frame.camera.transform
            let camPos = SIMD3<Float>(cam.columns.3.x, cam.columns.3.y, cam.columns.3.z)

            let rawForward = SIMD3<Float>(-cam.columns.2.x, 0, -cam.columns.2.z)
            guard length(rawForward) > 0.001 else { return }
            let flatForward = normalize(rawForward)

            let cardPos = SIMD3<Float>(
                camPos.x + flatForward.x * 1.1,
                camPos.y + 0.05,
                camPos.z + flatForward.z * 1.1
            )

            let yaw = atan2(flatForward.x, flatForward.z)
            let cardRotation = simd_quatf(angle: yaw, axis: [0, 1, 0])

            let anchor = AnchorEntity(world: cardPos)

            let cardW: Float = 0.60
            let cardH: Float = 0.42
            let cardD: Float = 0.006

            // ── Render card face as UIImage with real gradient ──
            let texSize = CGSize(width: 1024, height: 720)
            let qNum = viewModel.currentQuestionIndex + 1
            let total = viewModel.questions.count
            let cardImage = renderCardTexture(
                size: texSize,
                question: question.question,
                qNum: qNum,
                total: total
            )

            // ── Glow layers ──
            var outerGlowMat = SimpleMaterial()
            outerGlowMat.color = .init(tint: UIColor(red: 0.38, green: 0.20, blue: 0.90, alpha: 0.20))
            outerGlowMat.roughness = 1; outerGlowMat.metallic = 0
            let outerGlow = ModelEntity(
                mesh: .generateBox(width: cardW + 0.045, height: cardH + 0.045,
                                   depth: 0.001, cornerRadius: 0.035),
                materials: [outerGlowMat]
            )
            outerGlow.position = [0, 0, -0.009]

            var midGlowMat = SimpleMaterial()
            midGlowMat.color = .init(tint: UIColor(red: 0.55, green: 0.30, blue: 1.00, alpha: 0.30))
            midGlowMat.roughness = 1; midGlowMat.metallic = 0
            let midGlow = ModelEntity(
                mesh: .generateBox(width: cardW + 0.020, height: cardH + 0.020,
                                   depth: 0.001, cornerRadius: 0.026),
                materials: [midGlowMat]
            )
            midGlow.position = [0, 0, -0.005]

            // ── Card body with texture ──
            var cardMat = UnlitMaterial()
            if let cgImage = cardImage.cgImage {
                if let tex = try? TextureResource(image: cgImage, options: .init(semantic: .color)) {
                    cardMat.color = .init(texture: .init(tex))
                }
            }

            let cardBody = ModelEntity(
                mesh: .generateBox(width: cardW, height: cardH,
                                   depth: cardD, cornerRadius: 0.022),
                materials: [cardMat]
            )
            cardBody.position = [0, 0, 0]
            cardBody.name = "questionCard"
            cardBody.generateCollisionShapes(recursive: true)

            // ── Assemble ──
            let container = Entity()
            container.transform.rotation = cardRotation
            container.addChild(outerGlow)
            container.addChild(midGlow)
            container.addChild(cardBody)

            anchor.addChild(container)
            arView.scene.addAnchor(anchor)
        }

        // ── Renders the card face as a UIImage with real gradient + text ──
        private func renderCardTexture(size: CGSize, question: String, qNum: Int, total: Int) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { ctx in
                let rect = CGRect(origin: .zero, size: size)
                let context = ctx.cgContext

                // ── Background gradient: deep purple → vivid indigo → electric blue ──
                let colors = [
                    UIColor(red: 0.10, green: 0.02, blue: 0.30, alpha: 1).cgColor,
                    UIColor(red: 0.25, green: 0.05, blue: 0.60, alpha: 1).cgColor,
                    UIColor(red: 0.10, green: 0.20, blue: 0.80, alpha: 1).cgColor
                ]
                let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: colors as CFArray,
                    locations: [0, 0.5, 1.0]
                )!
                context.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )

                // ── Subtle noise overlay for depth ──
                UIColor(white: 1.0, alpha: 0.03).setFill()
                for _ in 0..<800 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let dot = CGRect(x: x, y: y, width: 1.5, height: 1.5)
                    context.fillEllipse(in: dot)
                }

                // ── Top accent line: cyan → purple ──
                let accentColors = [
                    UIColor(red: 0.20, green: 0.90, blue: 1.00, alpha: 1).cgColor,
                    UIColor(red: 0.70, green: 0.30, blue: 1.00, alpha: 1).cgColor
                ]
                let accentGrad = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: accentColors as CFArray,
                    locations: [0, 1.0]
                )!
                context.saveGState()
                context.clip(to: CGRect(x: 0, y: 0, width: size.width, height: 10))
                context.drawLinearGradient(accentGrad,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: 0), options: [])
                context.restoreGState()

                // ── Q badge ──
                let badgeText = "Q\(qNum)  ·  \(qNum) of \(total)"
                let badgeAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                    .foregroundColor: UIColor(red: 0.70, green: 0.90, blue: 1.00, alpha: 0.90)
                ]
                let badgeStr = NSAttributedString(string: badgeText, attributes: badgeAttrs)
                let badgeSize = badgeStr.size()
                let badgeX = (size.width - badgeSize.width) / 2
                badgeStr.draw(at: CGPoint(x: badgeX, y: 32))

                // ── Divider ──
                context.saveGState()
                let divGrad = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: [
                        UIColor.clear.cgColor,
                        UIColor(white: 1, alpha: 0.25).cgColor,
                        UIColor.clear.cgColor
                    ] as CFArray,
                    locations: [0, 0.5, 1.0]
                )!
                context.clip(to: CGRect(x: 60, y: 84, width: size.width - 120, height: 1.5))
                context.drawLinearGradient(divGrad,
                    start: CGPoint(x: 60, y: 84),
                    end: CGPoint(x: size.width - 60, y: 84), options: [])
                context.restoreGState()

                // ── Question text ──
                let paraStyle = NSMutableParagraphStyle()
                paraStyle.alignment = .center
                paraStyle.lineSpacing = 6

                let questionAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 42, weight: .semibold),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paraStyle
                ]
                let questionStr = NSAttributedString(string: question, attributes: questionAttrs)
                let textRect = CGRect(x: 60, y: 110, width: size.width - 120, height: size.height - 200)
                questionStr.draw(in: textRect)

                // ── Bottom hint ──
                let hintAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                    .foregroundColor: UIColor(red: 0.80, green: 0.70, blue: 1.00, alpha: 0.60)
                ]
                let hintStr = NSAttributedString(string: "✦  tap to reveal answers  ✦", attributes: hintAttrs)
                let hintSize = hintStr.size()
                hintStr.draw(at: CGPoint(x: (size.width - hintSize.width) / 2, y: size.height - 60))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ARPalaceView(viewModel: QuestionViewModel())
}

