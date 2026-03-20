//
//  LociLearnApp.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 21/02/26.
//

import SwiftUI

@main
struct LociLearnApp: App {

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool   = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup: Bool   = false
    @AppStorage("username")          private var username:          String = ""

        // ── TEMPORARY: delete after one run ──
        init() {
            UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
            UserDefaults.standard.removeObject(forKey: "hasCompletedSetup")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "selectedAvatar")
        }
        //
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasSeenOnboarding {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else if !hasCompletedSetup {
                    ProfileSetupView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    MainTabView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.45), value: hasSeenOnboarding)
            .animation(.easeInOut(duration: 0.45), value: hasCompletedSetup)
        }
    }
}
