//
//  OnboardingView.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 28/02/26.
//

import SwiftUI

// MARK: - Onboarding Entry Point
struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var hasSeenOnboarding: Bool

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.15).ignoresSafeArea()
            StarfieldView().ignoresSafeArea()

            TabView(selection: $currentPage) {
                OnboardingPage1(currentPage: $currentPage).tag(0)
                OnboardingPage2(hasSeenOnboarding: $hasSeenOnboarding).tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            // Dots — fixed 100pt above bottom, same on both pages
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<2) { i in
                        Capsule()
                            .fill(i == currentPage
                                  ? Color(red: 0.3, green: 0.9, blue: 0.6)
                                  : Color.white.opacity(0.25))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 96) // sits just above the 58pt button + 34pt bottom gap
            }
        }
    }
}

// MARK: - Starfield
struct StarfieldView: View {
    let stars: [StarData] = (0..<120).map { _ in StarData() }
    var body: some View {
        Canvas { context, size in
            for star in stars {
                let pt   = CGPoint(x: star.x * size.width, y: star.y * size.height)
                let rect = CGRect(x: pt.x - star.size/2, y: pt.y - star.size/2,
                                  width: star.size, height: star.size)
                context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(star.opacity)))
            }
        }
    }
}

struct StarData {
    let x: CGFloat      = .random(in: 0...1)
    let y: CGFloat      = .random(in: 0...1)
    let size: CGFloat   = .random(in: 1...3)
    let opacity: Double = .random(in: 0.2...0.85)
}

// MARK: - Page 1
struct OnboardingPage1: View {
    @Binding var currentPage: Int
    @State private var appeared      = false
    @State private var orbitRotation: Double  = 0
    @State private var pulseScale: CGFloat    = 1.0
    @State private var glowOpacity: Double    = 0.5

    let features: [(icon: String, title: String, subtitle: String)] = [
        ("sparkles",           "AI-Powered Learning", "Intelligent questions tailored to you"),
        ("arkit",              "AR Immersion",        "Step inside your memory palace"),
        ("brain.head.profile", "Spatial Recall",      "Remember more, forget less")
    ]

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            VStack(spacing: 0) {
                Spacer().frame(height: h * 0.07)

                // Constellation visual
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 0.45, green: 0.35, blue: 0.95)
                                                .opacity(0.3 - Double(i) * 0.08), .clear],
                                    startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1)
                            .frame(width: CGFloat(130 + i * 36), height: CGFloat(130 + i * 36))
                            .scaleEffect(pulseScale + CGFloat(i) * 0.05)
                            .opacity(glowOpacity)
                    }
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(red: 0.5, green: 0.4, blue: 0.98),
                                     Color(red: 0.2, green: 0.15, blue: 0.55),
                                     Color(red: 0.08, green: 0.06, blue: 0.2)],
                            center: .init(x: 0.35, y: 0.3),
                            startRadius: 5, endRadius: 60))
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(red: 0.4, green: 0.3, blue: 0.9).opacity(0.8), radius: 28)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(LinearGradient(
                            colors: [.white, Color(red: 0.8, green: 0.75, blue: 1.0)],
                            startPoint: .top, endPoint: .bottom))
                    ConstellationOrbitView(rotation: orbitRotation)
                }
                .frame(height: h * 0.27)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 18)
                .animation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.1), value: appeared)

                Spacer().frame(height: h * 0.03)

                // Title
                VStack(spacing: 8) {
                    Text("SPATIAL · AR · IMMERSIVE")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.95).opacity(0.9))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: appeared)

                    Text("Learn in\nSpace.")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(
                            colors: [.white, Color(red: 0.85, green: 0.8, blue: 1.0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.45), value: appeared)

                    Text("Transform abstract knowledge into\nimmersive 3D memory experiences.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.top, 2)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: appeared)
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: h * 0.03)

                // Feature pills
                VStack(spacing: 10) {
                    ForEach(Array(features.enumerated()), id: \.offset) { idx, f in
                        FeaturePillRow(icon: f.icon, title: f.title, subtitle: f.subtitle)
                            .opacity(appeared ? 1 : 0)
                            .offset(x: appeared ? 0 : -20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8)
                                           .delay(0.75 + Double(idx) * 0.12), value: appeared)
                    }
                }
                .padding(.horizontal, 24)

                // Push button to exact bottom position
                Spacer()

                // CTA — 34pt from bottom (same as page 2)
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { currentPage = 1 }
                } label: {
                    HStack(spacing: 10) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(LinearGradient(
                        colors: [Color(red: 0.25, green: 0.95, blue: 0.65),
                                 Color(red: 0.15, green: 0.85, blue: 0.55)],
                        startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 34) // ← same on both pages
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(1.1), value: appeared)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            appeared = true
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) { orbitRotation = 360 }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseScale  = 1.06
                glowOpacity = 0.8
            }
        }
    }
}

// MARK: - Orbit Visual
struct ConstellationOrbitView: View {
    let rotation: Double
    private let dotCount = 6
    private let radius: CGFloat = 84

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                .frame(width: radius * 2, height: radius * 2)
            ForEach(0..<dotCount, id: \.self) { i in
                let angle   = (Double(i) / Double(dotCount)) * 360 + rotation
                let radians = angle * .pi / 180
                Circle()
                    .fill(i % 2 == 0 ? Color(red: 0.55, green: 0.85, blue: 1.0)
                                     : Color(red: 0.8, green: 0.7, blue: 1.0))
                    .frame(width: i % 3 == 0 ? 7 : 5, height: i % 3 == 0 ? 7 : 5)
                    .shadow(color: (i % 2 == 0 ? Color(red: 0.55, green: 0.85, blue: 1.0)
                                               : Color(red: 0.8, green: 0.7, blue: 1.0)).opacity(0.9), radius: 6)
                    .offset(x: radius * CGFloat(cos(radians)), y: radius * CGFloat(sin(radians)))
            }
            ConstellationLinesView(rotation: rotation, dotCount: dotCount, radius: radius)
        }
    }
}

struct ConstellationLinesView: View {
    let rotation: Double
    let dotCount: Int
    let radius: CGFloat
    let connections = [(0,2),(2,4),(4,1),(1,3),(3,5)]

    func pos(_ i: Int) -> CGPoint {
        let a = (Double(i) / Double(dotCount)) * 360 + rotation
        let r = a * .pi / 180
        return CGPoint(x: radius * CGFloat(cos(r)), y: radius * CGFloat(sin(r)))
    }

    var body: some View {
        Canvas { ctx, size in
            let c = CGPoint(x: size.width/2, y: size.height/2)
            for (a, b) in connections {
                let p1 = pos(a), p2 = pos(b)
                var path = Path()
                path.move(to: CGPoint(x: c.x + p1.x, y: c.y + p1.y))
                path.addLine(to: CGPoint(x: c.x + p2.x, y: c.y + p2.y))
                ctx.stroke(path, with: .color(.white.opacity(0.18)), lineWidth: 1)
            }
        }
        .frame(width: radius * 2 + 20, height: radius * 2 + 20)
    }
}

// MARK: - Feature Pill Row
struct FeaturePillRow: View {
    let icon, title, subtitle: String
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.25, green: 0.2, blue: 0.5).opacity(0.7))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(LinearGradient(
                        colors: [Color(red: 0.7, green: 0.6, blue: 1.0), .white],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.12, green: 0.1, blue: 0.25).opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }
}

// MARK: - Page 2
struct OnboardingPage2: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var appeared            = false
    @State private var crosshairScale: CGFloat  = 0.8
    @State private var crosshairOpacity: Double = 0
    @State private var xpVisible           = false
    @State private var orbitAngle: Double  = 0
    @State private var floatOffset: CGFloat = 0

    let steps: [(icon: String, title: String, desc: String, color: Color)] = [
        ("scope",     "Aim",   "Point your device at orbiting stars",   Color(red: 0.3, green: 0.7, blue: 1.0)),
        ("timer",     "Hold",  "1 second to lock on and answer",        Color(red: 0.6, green: 0.4, blue: 1.0)),
        ("star.fill", "Score", "Earn XP, streaks & unlock badges",      Color(red: 1.0, green: 0.75, blue: 0.2))
    ]

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            VStack(spacing: 0) {
                Spacer().frame(height: h * 0.07)

                // AR visual
                ZStack {
                    ForEach(0..<5) { i in
                        let angle = Double(i) / 5.0 * 360 + orbitAngle
                        let r: CGFloat = i % 2 == 0 ? 96 : 70
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.6, green: 0.5, blue: 1.0).opacity(0.2))
                                .frame(width: i == 2 ? 50 : 36, height: i == 2 ? 50 : 36)
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: i == 2 ? 24 : 18))
                                .foregroundStyle(LinearGradient(
                                    colors: [Color(red: 0.75, green: 0.65, blue: 1.0), .white],
                                    startPoint: .top, endPoint: .bottom))
                                .shadow(color: Color(red: 0.6, green: 0.5, blue: 1.0).opacity(0.9), radius: 10)
                        }
                        .offset(
                            x: r * CGFloat(cos(angle * .pi / 180)),
                            y: r * CGFloat(sin(angle * .pi / 180)) + floatOffset * CGFloat(i % 2 == 0 ? 1 : -1) * 0.3
                        )
                    }
                    ZStack {
                        CrosshairShape()
                            .stroke(Color(red: 0.3, green: 0.9, blue: 0.65), lineWidth: 2)
                            .frame(width: 68, height: 68)
                        Circle()
                            .stroke(Color(red: 0.3, green: 0.9, blue: 0.65).opacity(0.4), lineWidth: 1)
                            .frame(width: 88, height: 88)
                        Circle()
                            .fill(Color(red: 0.3, green: 0.9, blue: 0.65).opacity(0.1))
                            .frame(width: 68, height: 68)
                    }
                    .scaleEffect(crosshairScale)
                    .opacity(crosshairOpacity)

                    if xpVisible {
                        Text("+10 XP")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.9, blue: 0.65))
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.1, green: 0.3, blue: 0.2).opacity(0.85))
                                    .overlay(Capsule()
                                        .stroke(Color(red: 0.3, green: 0.9, blue: 0.65).opacity(0.5), lineWidth: 1))
                            )
                            .offset(y: -80)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.5).combined(with: .opacity).combined(with: .offset(y: 20)),
                                removal: .opacity.combined(with: .offset(y: -20))))
                    }
                }
                .frame(height: h * 0.30)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.1), value: appeared)

                Spacer().frame(height: h * 0.03)

                // Title
                VStack(spacing: 8) {
                    Text("CONSTELLATION MODE")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.95).opacity(0.9))
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: appeared)

                    Text("Aim. Hold.\nRemember.")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(
                            colors: [.white, Color(red: 0.85, green: 0.78, blue: 1.0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.45), value: appeared)

                    Text("Questions orbit you in 360°.\nInteract with knowledge through space.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.top, 2)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: appeared)
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: h * 0.03)

                // Step cards
                HStack(spacing: 10) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        StepCard(icon: step.icon, title: step.title,
                                 desc: step.desc, accentColor: step.color)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.75)
                                           .delay(0.7 + Double(idx) * 0.1), value: appeared)
                    }
                }
                .padding(.horizontal, 20)

                // Push button to exact same bottom position as page 1
                Spacer()

                // CTA — 34pt from bottom (same as page 1)
                Button { hasSeenOnboarding = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Start Exploring")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(LinearGradient(
                        colors: [Color(red: 0.25, green: 0.95, blue: 0.65),
                                 Color(red: 0.15, green: 0.85, blue: 0.55)],
                        startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 34) // ← same as page 1
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(1.1), value: appeared)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            appeared = true
            withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) { orbitAngle = 360 }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { floatOffset = 8 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    crosshairScale = 1.0; crosshairOpacity = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { xpPulseCycle() }
        }
    }

    func xpPulseCycle() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) { xpVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.4)) { xpVisible = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { xpPulseCycle() }
        }
    }
}

// MARK: - Crosshair Shape
struct CrosshairShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        let arm: CGFloat = rect.width * 0.28, gap: CGFloat = rect.width * 0.12
        p.move(to: .init(x: cx-arm, y: cy)); p.addLine(to: .init(x: cx-gap, y: cy))
        p.move(to: .init(x: cx+gap, y: cy)); p.addLine(to: .init(x: cx+arm, y: cy))
        p.move(to: .init(x: cx, y: cy-arm)); p.addLine(to: .init(x: cx, y: cy-gap))
        p.move(to: .init(x: cx, y: cy+gap)); p.addLine(to: .init(x: cx, y: cy+arm))
        let b: CGFloat = rect.width*0.36, bl: CGFloat = rect.width*0.12
        p.move(to: .init(x: cx-b, y: cy-b+bl)); p.addLine(to: .init(x: cx-b, y: cy-b)); p.addLine(to: .init(x: cx-b+bl, y: cy-b))
        p.move(to: .init(x: cx+b-bl, y: cy-b)); p.addLine(to: .init(x: cx+b, y: cy-b)); p.addLine(to: .init(x: cx+b, y: cy-b+bl))
        p.move(to: .init(x: cx+b, y: cy+b-bl)); p.addLine(to: .init(x: cx+b, y: cy+b)); p.addLine(to: .init(x: cx+b-bl, y: cy+b))
        p.move(to: .init(x: cx-b+bl, y: cy+b)); p.addLine(to: .init(x: cx-b, y: cy+b)); p.addLine(to: .init(x: cx-b, y: cy+b-bl))
        return p
    }
}

// MARK: - Step Card
struct StepCard: View {
    let icon, title, desc: String
    let accentColor: Color
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(accentColor.opacity(0.15)).frame(width: 48, height: 48)
                Image(systemName: icon).font(.system(size: 20, weight: .medium)).foregroundColor(accentColor)
            }
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white)
            Text(desc)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center).lineSpacing(2)
        }
        .padding(.vertical, 18).padding(.horizontal, 10).frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.1, green: 0.09, blue: 0.22).opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(accentColor.opacity(0.18), lineWidth: 1))
        )
    }
}


#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false)).preferredColorScheme(.dark)
}
