//
//  MainTabView.swift
//  LociLearn
//
//  Created by Lakshman Ryali on 22/02/26.
//

import SwiftUI
import Combine

struct MainTabView: View {

    @StateObject private var startVM = StartViewModel()
    @StateObject private var quizVM  = QuestionViewModel()
    @AppStorage("selectedAvatar") var selectedAvatar: Int = 0
    @State private var selectedTab: Int = 0

    private let avatars = ["🚀", "🌌", "⭐", "🪐", "🔭", "🧠"]

    var body: some View {
        TabView(selection: $selectedTab) {
            StartView(startVM: startVM, quizVM: quizVM)
                .onAppear { injectEmojiIcon() }  // 👈 add
                .tabItem { Label("Learn", systemImage: "brain.head.profile") }
                .tag(0)
            
            NavigationStack {
                ConstellationLauncherView(viewModel: quizVM)
            }
            .onAppear { injectEmojiIcon() }  // 👈 already there, remove the asyncAfter delay
            .tabItem { Label("Constellation", systemImage: "sparkles") }
            .tag(1)
            
            NavigationStack {
                ProfileView(viewModel: quizVM)
            }
            .onAppear { injectEmojiIcon() }  // 👈 add
            .tabItem { Text("Profile") }
            .tag(2)
        }
        .tint(.brand)
        .task {
            applyTabBarStyling()
            try? await Task.sleep(nanoseconds: 300_000_000)
            injectEmojiIcon()
        }
        .onChange(of: selectedAvatar) { injectEmojiIcon() }
        .onChange(of: selectedTab) { injectEmojiIcon() }
        .onReceive(NotificationCenter.default.publisher(for: .reinjectEmoji)) { _ in
            injectEmojiIcon()
        }
        .onReceive(Timer.publish(every: 0.0000001, on: .main, in: .common).autoconnect()) { _ in
            applyEmojiToTabBar()
        }
    }

    // MARK: - Tab Bar Styling

    private func applyTabBarStyling() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor  = UIColor(red: 0.08, green: 0.07, blue: 0.18, alpha: 0.55)
        appearance.shadowColor      = .clear

        let brandColor = UIColor(red: 0.55, green: 0.30, blue: 1.0, alpha: 1)

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.45)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.45),
            .font: UIFont.systemFont(ofSize: 8, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = brandColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: brandColor,
            .font: UIFont.systemFont(ofSize: 8, weight: .bold)
        ]

        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

//        injectEmojiIcon()
    }

    // Separated so it can be called repeatedly without recreating appearance
    private func injectEmojiIcon() {
        DispatchQueue.main.async {
            guard
                let scene  = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
                let window = scene.windows.first(where: { $0.isKeyWindow }),
                let tabBar = window.rootViewController?.findTabBarController(),
                let items  = tabBar.tabBar.items,
                items.count > 2
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { injectEmojiIcon() }
                return
            }

            let img = emojiToImage(avatars[selectedAvatar], size: CGSize(width: 28, height: 28))
            let normal   = img?.withRenderingMode(.alwaysOriginal)
            let selected = img?.withRenderingMode(.alwaysOriginal)

            items[2].image         = normal
            items[2].selectedImage = selected

            // Bake into ALL appearance states so navigation can't reset it
            let appearance = tabBar.tabBar.standardAppearance.copy()
            tabBar.tabBar.standardAppearance   = appearance
            tabBar.tabBar.scrollEdgeAppearance = appearance
            tabBar.tabBar.setNeedsLayout()
            tabBar.tabBar.layoutIfNeeded()
        }
    }

    // ✅ WITH this — only apply, no broken comparison:
    private func applyEmojiToTabBar() {
        guard
            let scene  = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
            let window = scene.windows.first(where: { $0.isKeyWindow }),
            let tabBar = window.rootViewController?.findTabBarController(),
            let items  = tabBar.tabBar.items,
            items.count > 2
        else { return }

        let img      = emojiToImage(avatars[selectedAvatar], size: CGSize(width: 28, height: 28))
        let rendered = img?.withRenderingMode(.alwaysOriginal)
        items[2].image         = rendered
        items[2].selectedImage = rendered
        // ✅ No layout calls — these were forcing redraws every 0.5s
    }

    private func emojiToImage(_ emoji: String, size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { _ in
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: size.height * 0.80)]
            let str     = NSAttributedString(string: emoji, attributes: attrs)
            let sz      = str.size()
            str.draw(at: CGPoint(x: (size.width - sz.width) / 2, y: (size.height - sz.height) / 2))
        }
    }
}

// MARK: - VC helper
extension UIViewController {
    func findTabBarController() -> UITabBarController? {
        if let t = self as? UITabBarController { return t }
        for child in children { if let f = child.findTabBarController() { return f } }
        return presentedViewController?.findTabBarController()
    }
}

#Preview { MainTabView() }

extension Notification.Name {
    static let reinjectEmoji = Notification.Name("reinjectEmoji")
}
