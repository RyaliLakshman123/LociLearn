//
//  PlanetSelectionView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 23/02/26.
//


//
//  PlanetSelectionView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 23/02/26.
//

import SwiftUI
import RealityKit

// MARK: - Planet Selection View
struct PlanetSelectionView: View {

    @ObservedObject var viewModel: QuestionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var appeared = false
    @State private var selectedPlanet: PlanetType? = nil
    @State private var showHistory = false
    
    var body: some View {
        ZStack {
            AppBackgroundView()

            // Subtle star-field background dots
            StarFieldBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // ── Hero ──
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().fill(Color.brand.opacity(0.15)).frame(width: 76, height: 76)
                            Circle().strokeBorder(Color.brand.opacity(0.28), lineWidth: 1).frame(width: 76, height: 76)
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(Color.brand)
                        }
                        Text("Choose a Planet")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Select a world to begin your AR journey.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSub)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60).padding(.bottom, 4)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : -16)
                    .animation(.spring(response: 0.65, dampingFraction: 0.80).delay(0.05), value: appeared)

                    // ── Planet Tiles ──
                    VStack(spacing: 12) {
                        ForEach(Array(PlanetType.allCases.enumerated()), id: \.element) { i, planet in
                            NavigationLink(destination: PlanetDetailView(viewModel: viewModel, planet: planet)) {
                                PlanetTile(planet: planet)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .opacity(appeared ? 1 : 0).offset(x: appeared ? 0 : 24)
                            .animation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.20 + Double(i) * 0.09), value: appeared)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarHidden(false)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showHistory = true } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(Color.brand)
                        }
                    }
                }
                .sheet(isPresented: $showHistory) {
                    ARHistoryView(accentColor: Color.brand)
                }
                .onAppear { appeared = true }
    }
}

// MARK: - Planet Tile
struct PlanetTile: View {
    let planet: PlanetType

    var body: some View {
        HStack(spacing: 16) {
            // Planet icon circle
            ZStack {
                Circle()
                    .fill(planet.color.opacity(0.18))
                    .frame(width: 56, height: 56)
                Circle()
                    .strokeBorder(planet.color.opacity(0.40), lineWidth: 1)
                    .frame(width: 56, height: 56)
                Image(systemName: planet.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(planet.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(planet.displayName)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(planet.tagline)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSub)
                    .lineLimit(1)
            }

            Spacer()

            // Stat chip
            VStack(spacing: 2) {
                Text(planet.distanceLabel)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(planet.color)
                Text("from Sun")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.textMuted)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.textSub)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.surface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(planet.color.opacity(0.20), lineWidth: 1)
                )
        )
    }
}


// MARK: - Planet Detail View (non-AR preview + facts + enter AR)
struct PlanetDetailView: View {

    @ObservedObject var viewModel: QuestionViewModel
    let planet: PlanetType

    @State private var appeared = false
    @State private var navigateToAR = false
    @State private var selectedFactIndex = 0

    var body: some View {
        ZStack {
            AppBackgroundView()
            StarFieldBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    PlanetPreview3D(planet: planet)
                        .frame(width: 320, height: 320)
                        .clipShape(Circle())

                    // ── Planet Name & Tagline ──
                    VStack(spacing: 6) {
                        Text(planet.displayName)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(planet.tagline)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSub)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 10)
                    .animation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.18), value: appeared)

                    // ── Stat Chips Row ──
                    HStack(spacing: 10) {
                        ForEach(planet.stats) { stat in
                            StatChip(stat: stat, color: planet.color)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                    .animation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.26), value: appeared)

                    // ── Key Facts Card ──
                    VStack(spacing: 0) {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(planet.color)
                            Text("KEY FACTS")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.textMuted)
                                .kerning(0.9)
                            Spacer()
                        }
                        .padding(.horizontal, 18).padding(.top, 16).padding(.bottom, 14)

                        RowDivider()

                        VStack(spacing: 0) {
                            ForEach(Array(planet.keyFacts.enumerated()), id: \.offset) { i, fact in
                                FactRow(fact: fact, color: planet.color, index: i, appeared: appeared)
                                if i < planet.keyFacts.count - 1 { RowDivider() }
                            }
                        }
                        .padding(.bottom, 6)
                    }
                    .cardStyle(radius: 22)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
                    .animation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.34), value: appeared)

                    // ── Enter AR Button ──
                    Button {
                        viewModel.selectedPlanet = planet
                        navigateToAR = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arkit")
                                .font(.system(size: 16, weight: .bold))
                            Text("Enter AR Mode")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(planet.color)
                                .shadow(color: planet.color.opacity(0.45), radius: 16, y: 6)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 14)
                    .animation(.spring(response: 0.65, dampingFraction: 0.80).delay(0.44), value: appeared)

                    NavigationLink(destination: ARPalaceView(viewModel: viewModel), isActive: $navigateToAR) {
                        EmptyView()
                    }
                }
            }
        }
        .navigationBarHidden(false)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { appeared = true }
    }
}


// MARK: - Fact Row
struct FactRow: View {
    let fact: PlanetFact
    let color: Color
    let index: Int
    let appeared: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: fact.icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(fact.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.textMuted)
                    .kerning(0.5)
                    .textCase(.uppercase)
                Text(fact.value)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
        .opacity(appeared ? 1 : 0).offset(x: appeared ? 0 : -16)
        .animation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.38 + Double(index) * 0.07), value: appeared)
    }
}


// MARK: - Stat Chip
struct StatChip: View {
    let stat: PlanetStat
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(stat.value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(stat.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.surface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(color.opacity(0.20), lineWidth: 1)
                )
        )
    }
}


// MARK: - Star Field Background
struct StarFieldBackground: View {
    // Fixed star positions so they don't regenerate on redraw
    private let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = {
        var result: [(CGFloat, CGFloat, CGFloat, Double)] = []
        var rng = SystemRandomNumberGenerator()
        for _ in 0..<80 {
            result.append((
                CGFloat.random(in: 0...1, using: &rng),
                CGFloat.random(in: 0...1, using: &rng),
                CGFloat.random(in: 1...2.5, using: &rng),
                Double.random(in: 0.1...0.5, using: &rng)
            ))
        }
        return result
    }()

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(stars[i].opacity))
                    .frame(width: stars[i].size, height: stars[i].size)
                    .position(
                        x: stars[i].x * geo.size.width,
                        y: stars[i].y * geo.size.height
                    )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}


// MARK: - PlanetType Extensions
// Add these to your existing PlanetType enum / extend it here

struct PlanetFact: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
}

struct PlanetStat: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

extension PlanetType {

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .mercury: return "circle.hexagongrid.fill"
        case .venus:   return "sun.max.fill"
        case .earth:   return "globe.americas.fill"
        case .mars:    return "flame.fill"
        case .jupiter: return "sparkles"
        case .saturn:  return "circle.dashed.inset.filled"
        case .uranus:  return "drop.fill"
        case .neptune: return "moon.stars.fill"
        }
    }
    
    // MARK: - Theme Color (used only if needed in UI)
    var color: Color {
        switch self {
        case .mercury: return Color(red: 0.72, green: 0.60, blue: 0.50)
        case .venus:   return Color(red: 0.90, green: 0.70, blue: 0.30)
        case .earth:   return Color(red: 0.18, green: 0.60, blue: 0.96)
        case .mars:    return Color(red: 0.90, green: 0.35, blue: 0.22)
        case .jupiter: return Color(red: 0.95, green: 0.68, blue: 0.38)
        case .saturn:  return Color(red: 0.93, green: 0.82, blue: 0.55)
        case .uranus:  return Color(red: 0.55, green: 0.85, blue: 0.90)
        case .neptune: return Color(red: 0.25, green: 0.45, blue: 0.95)
        }
    }

    // MARK: - Tagline
    var tagline: String {
        switch self {
        case .mercury: return "The swiftest planet in the Solar System"
        case .venus:   return "Earth’s scorching twin"
        case .earth:   return "Our pale blue dot — the only known home"
        case .mars:    return "The Red Planet awaits exploration"
        case .jupiter: return "King of planets, giant of storms"
        case .saturn:  return "The ringed jewel of the Solar System"
        case .uranus:  return "The sideways spinning ice giant"
        case .neptune: return "The windy blue world at the edge"
        }
    }

    // MARK: - Distance from Sun
    var distanceLabel: String {
        switch self {
        case .mercury: return "0.39 AU"
        case .venus:   return "0.72 AU"
        case .earth:   return "1.00 AU"
        case .mars:    return "1.52 AU"
        case .jupiter: return "5.20 AU"
        case .saturn:  return "9.58 AU"
        case .uranus:  return "19.2 AU"
        case .neptune: return "30.1 AU"
        }
    }

    // MARK: - Quick Stats
    var stats: [PlanetStat] {
        switch self {
        case .mercury:
            return [
                PlanetStat(label: "Diameter", value: "4,879 km"),
                PlanetStat(label: "Moons", value: "0"),
                PlanetStat(label: "Day", value: "59 Earth days"),
            ]
        case .venus:
            return [
                PlanetStat(label: "Diameter", value: "12,104 km"),
                PlanetStat(label: "Moons", value: "0"),
                PlanetStat(label: "Day", value: "243 Earth days"),
            ]
        case .earth:
            return [
                PlanetStat(label: "Diameter", value: "12,742 km"),
                PlanetStat(label: "Moons", value: "1"),
                PlanetStat(label: "Day", value: "24 hrs"),
            ]
        case .mars:
            return [
                PlanetStat(label: "Diameter", value: "6,779 km"),
                PlanetStat(label: "Moons", value: "2"),
                PlanetStat(label: "Day", value: "24.6 hrs"),
            ]
        case .jupiter:
            return [
                PlanetStat(label: "Diameter", value: "139,820 km"),
                PlanetStat(label: "Moons", value: "95"),
                PlanetStat(label: "Day", value: "9.9 hrs"),
            ]
        case .saturn:
            return [
                PlanetStat(label: "Diameter", value: "116,460 km"),
                PlanetStat(label: "Moons", value: "146"),
                PlanetStat(label: "Day", value: "10.7 hrs"),
            ]
        case .uranus:
            return [
                PlanetStat(label: "Diameter", value: "50,724 km"),
                PlanetStat(label: "Moons", value: "27"),
                PlanetStat(label: "Day", value: "17.2 hrs"),
            ]
        case .neptune:
            return [
                PlanetStat(label: "Diameter", value: "49,244 km"),
                PlanetStat(label: "Moons", value: "14"),
                PlanetStat(label: "Day", value: "16.1 hrs"),
            ]
        }
    }

    // MARK: - Key Facts
    var keyFacts: [PlanetFact] {
        switch self {

        case .mercury:
            return [
                PlanetFact(icon: "thermometer.sun.fill", label: "Surface Temp", value: "430°C day / -180°C night"),
                PlanetFact(icon: "arrow.clockwise", label: "Orbit Period", value: "88 Earth days"),
                PlanetFact(icon: "gauge.with.dots.needle.bottom.50percent", label: "Gravity", value: "3.7 m/s²"),
            ]

        case .venus:
            return [
                PlanetFact(icon: "thermometer.sun.fill", label: "Surface Temp", value: "465°C (hottest planet)"),
                PlanetFact(icon: "cloud.fill", label: "Atmosphere", value: "96% Carbon Dioxide"),
                PlanetFact(icon: "arrow.uturn.backward", label: "Rotation", value: "Spins backward"),
            ]

        case .earth:
            return [
                PlanetFact(icon: "drop.fill", label: "Surface", value: "71% water"),
                PlanetFact(icon: "lungs.fill", label: "Atmosphere", value: "78% Nitrogen, 21% Oxygen"),
                PlanetFact(icon: "gauge.with.dots.needle.bottom.50percent", label: "Gravity", value: "9.8 m/s²"),
            ]

        case .mars:
            return [
                PlanetFact(icon: "mountain.2.fill", label: "Olympus Mons", value: "Tallest volcano in Solar System"),
                PlanetFact(icon: "wind", label: "Atmosphere", value: "Thin, mostly CO₂"),
                PlanetFact(icon: "thermometer.snowflake", label: "Avg Temp", value: "-60°C"),
            ]

        case .jupiter:
            return [
                PlanetFact(icon: "tornado", label: "Great Red Spot", value: "350+ year old storm"),
                PlanetFact(icon: "sparkles", label: "Composition", value: "Hydrogen & Helium"),
                PlanetFact(icon: "moon.stars.fill", label: "Largest Moon", value: "Ganymede"),
            ]

        case .saturn:
            return [
                PlanetFact(icon: "circle.grid.cross.fill", label: "Rings", value: "Made of ice & rock"),
                PlanetFact(icon: "moon.fill", label: "Largest Moon", value: "Titan"),
                PlanetFact(icon: "sparkles", label: "Density", value: "Less dense than water"),
            ]

        case .uranus:
            return [
                PlanetFact(icon: "arrow.up.arrow.down", label: "Tilt", value: "98° axial tilt"),
                PlanetFact(icon: "snowflake", label: "Type", value: "Ice giant"),
                PlanetFact(icon: "wind", label: "Winds", value: "Up to 900 km/h"),
            ]

        case .neptune:
            return [
                PlanetFact(icon: "wind", label: "Fastest Winds", value: "2,100 km/h"),
                PlanetFact(icon: "snowflake", label: "Type", value: "Ice giant"),
                PlanetFact(icon: "moon.fill", label: "Largest Moon", value: "Triton"),
            ]
        }
    }
}


// MARK: - PlanetPreview3D (non-AR, drag-to-rotate + momentum + auto-spin)
struct PlanetPreview3D: UIViewRepresentable {

    let planet: PlanetType

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        view.cameraMode = .nonAR
        view.backgroundColor = .clear
        view.isOpaque = false
        view.environment.background = .color(UIColor.clear)
        view.renderOptions = [.disableMotionBlur, .disableDepthOfField, .disableFaceOcclusions, .disablePersonOcclusion, .disableGroundingShadows]

        // Pan gesture for drag-to-rotate
        let pan = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        view.addGestureRecognizer(pan)

        let anchor = AnchorEntity()
        view.scene.addAnchor(anchor)
        context.coordinator.anchor = anchor

        Task {
            do {
                let model = try await ModelEntity(named: planet.rawValue.capitalized)
                model.scale = SIMD3<Float>(repeating: 0.01)
                model.generateCollisionShapes(recursive: true)
                anchor.addChild(model)
                context.coordinator.model = model

                // Start gentle auto-spin
                context.coordinator.startAutoSpin()
            } catch {
                print("Planet preview model failed to load: \(error)")
            }
        }

        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    // MARK: Coordinator
    class Coordinator: NSObject {
        var model: ModelEntity?
        var anchor: AnchorEntity?

        // Current accumulated rotation (euler angles in radians)
        private var rotationX: Float = 0
        private var rotationY: Float = 0

        // Velocity for momentum
        private var velocityX: Float = 0
        private var velocityY: Float = 0

        // Timers
        private var momentumTimer: CADisplayLink?
        private var autoSpinTimer: CADisplayLink?
        private var isDragging = false

        // Sensitivity
        private let dragSensitivity: Float = 0.008
        private let momentumDecay: Float  = 0.92   // how fast momentum fades
        private let autoSpinSpeed: Float  = 0.004  // radians per frame at 60fps

        // MARK: - Gesture
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let model = model else { return }

            switch gesture.state {
            case .began:
                isDragging = true
                stopAutoSpin()
                stopMomentum()
                velocityX = 0
                velocityY = 0

            case .changed:
                let delta = gesture.translation(in: gesture.view)
                gesture.setTranslation(.zero, in: gesture.view)

                let dY = Float(delta.x) * dragSensitivity   // horizontal drag → Y rotation
                let dX = Float(delta.y) * dragSensitivity   // vertical drag   → X rotation

                velocityY = dY
                velocityX = dX

                rotationY += dY
                rotationX += dX
                // Clamp vertical tilt so planet doesn't flip upside down
                rotationX = max(-1.0, min(1.0, rotationX))

                applyRotation(to: model)

            case .ended, .cancelled:
                isDragging = false
                startMomentum()

            default:
                break
            }
        }

        // MARK: - Apply Rotation
        private func applyRotation(to model: ModelEntity) {
            let qX = simd_quatf(angle: rotationX, axis: [1, 0, 0])
            let qY = simd_quatf(angle: rotationY, axis: [0, 1, 0])
            model.transform.rotation = qY * qX
        }

        // MARK: - Momentum (inertia glide after finger lifts)
        private func startMomentum() {
            stopMomentum()
            let link = CADisplayLink(target: self, selector: #selector(momentumStep))
            link.add(to: .main, forMode: .common)
            momentumTimer = link
        }

        private func stopMomentum() {
            momentumTimer?.invalidate()
            momentumTimer = nil
        }

        @objc private func momentumStep() {
            guard let model = model else { stopMomentum(); return }

            velocityX *= momentumDecay
            velocityY *= momentumDecay

            rotationX += velocityX
            rotationY += velocityY
            rotationX = max(-1.0, min(1.0, rotationX))

            applyRotation(to: model)

            // Once nearly stopped, hand off to auto-spin
            let speed = sqrt(velocityX * velocityX + velocityY * velocityY)
            if speed < 0.0001 {
                stopMomentum()
                startAutoSpin()
            }
        }

        // MARK: - Auto Spin (idle slow rotation)
        func startAutoSpin() {
            guard !isDragging else { return }
            stopAutoSpin()
            let link = CADisplayLink(target: self, selector: #selector(autoSpinStep))
            link.add(to: .main, forMode: .common)
            autoSpinTimer = link
        }

        private func stopAutoSpin() {
            autoSpinTimer?.invalidate()
            autoSpinTimer = nil
        }

        @objc private func autoSpinStep() {
            guard let model = model, !isDragging else { return }
            rotationY += autoSpinSpeed
            applyRotation(to: model)
        }
    }
}


#Preview {
    NavigationStack {
        PlanetSelectionView(viewModel: QuestionViewModel())
    }
}
