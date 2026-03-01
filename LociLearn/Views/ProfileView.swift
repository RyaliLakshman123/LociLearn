//
//  ProfileView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 22/02/26.
//


import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @AppStorage("selectedAvatar") private var selectedAvatar: Int = 0
    @AppStorage("username")       private var username:       String = ""
    @State private var appeared      = false
    @State private var selectedTab   = 0
    @State private var showEditSheet = false

    private let avatars = ["🚀", "🌌", "⭐", "🪐", "🔭", "🧠"]

    private var total:    Int    { viewModel.answeredQuestions.count }
    private var correct:  Int    { viewModel.answeredQuestions.filter(\.isCorrect).count }
    private var wrong:    Int    { total - correct }
    private var accuracy: Double { total > 0 ? Double(correct) / Double(total) : 0 }
    private var level:             Int    { max(1, viewModel.score / 50 + 1) }
    private var xpForCurrentLevel: Int    { (level - 1) * 50 }
    private var xpToNext:          Int    { level * 50 }
    private var xpIntoLevel:       Int    { viewModel.score - xpForCurrentLevel }
    private var xpNeededThisLevel: Int    { xpToNext - xpForCurrentLevel }
    private var xpProg: Double {
        guard xpNeededThisLevel > 0 else { return 0 }
        return min(Double(xpIntoLevel) / Double(xpNeededThisLevel), 1.0)
    }
    private var ringColor: Color {
        if accuracy >= 0.75 { return .success }
        if accuracy >= 0.45 { return .warn }
        return .danger
    }
    private var accuracyLabel: String {
        if accuracy >= 0.90 { return "Outstanding! 🏆" }
        if accuracy >= 0.75 { return "Great work! 🎉" }
        if accuracy >= 0.50 { return "Keep going! 💪" }
        return total == 0 ? "No answers yet" : "Practice more 📚"
    }
    private var badges: [(String, String, Bool)] {[
        ("First Steps",   "figure.walk",       viewModel.totalAnswered >= 1),
        ("Quiz Master",   "trophy.fill",        viewModel.score >= 100),
        ("Streak: 3",     "flame.fill",         viewModel.bestStreak >= 3),
        ("Perfect Score", "star.fill",          viewModel.totalAnswered >= 5 && viewModel.totalCorrectAnswers == viewModel.totalAnswered),
        ("Night Owl",     "moon.fill",          false),
        ("Deep Focus",    "brain.head.profile", viewModel.totalAnswered >= 20),
    ]}

    var body: some View {
        ZStack {
            AppBackgroundView()
            RadialGradient(colors: [Color.brand.opacity(0.14), Color.clear],
                           center: UnitPoint(x: 0.5, y: 0.1), startRadius: 0, endRadius: 360).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    xpBar.padding(.horizontal, 20).padding(.top, 24)
                    statsRow.padding(.horizontal, 20).padding(.top, 14)
                    Text("\(Int(accuracy * 100))% Accuracy")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(ringColor).padding(.top, 8)
                    scoreBanner.padding(.horizontal, 20).padding(.top, 16)
                    picker.padding(.horizontal, 20).padding(.top, 28)
                    tabContent.padding(.top, 16)
                    Spacer(minLength: 60)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showEditSheet) {
            EditProfileSheet(currentAvatar: selectedAvatar, currentName: username, avatars: avatars) { newAvatar, newName in
                selectedAvatar = newAvatar
                username = newName.trimmingCharacters(in: .whitespaces).isEmpty ? "Explorer"
                         : newName.trimmingCharacters(in: .whitespaces)
            }
        }
        .onAppear { appeared = true }
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.brand.opacity(0.12)).frame(width: 140, height: 140).blur(radius: 20)
                Circle()
                    .trim(from: 0, to: appeared ? 1.0 : 0)
                    .stroke(AngularGradient(colors: [Color.brand.opacity(0.2), Color.brand, Color.brandSoft, Color.brand.opacity(0.2)], center: .center),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 106, height: 106).rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.1).delay(0.2), value: appeared)
                Circle().fill(Color.surface2).frame(width: 98, height: 98)
                Text(avatars[selectedAvatar])
                    .font(.system(size: 52))
                    .id(selectedAvatar)
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                // Edit badge
                Button { showEditSheet = true } label: {
                    ZStack {
                        Circle().fill(Color.brand).frame(width: 26, height: 26)
                        Image(systemName: "pencil").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                    }
                }
                .offset(x: 34, y: 34)
            }
            VStack(spacing: 8) {
                // Bigger username
                Text(username.isEmpty ? "Explorer" : username)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                HStack(spacing: 12) {
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill").font(.system(size: 10)).foregroundStyle(Color.warn)
                        Text("Level \(level)").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(Color.warn)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 5).background(Color.warn.opacity(0.12), in: Capsule())
                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill").font(.system(size: 10)).foregroundStyle(Color.danger)
                        Text("Streak \(viewModel.streak)").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(Color.danger)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 5).background(Color.danger.opacity(0.10), in: Capsule())
                }
            }
        }
        .padding(.top, 50)
        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : -18)
        .animation(.spring(response: 0.65, dampingFraction: 0.8).delay(0.05), value: appeared)
    }

    private var xpBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("XP Progress").font(.system(size: 11, weight: .semibold)).foregroundStyle(Color.textMuted).kerning(0.9)
                Spacer()
                Text("\(xpIntoLevel) / \(xpNeededThisLevel) XP  •  Lv.\(level)").font(.system(size: 11, weight: .semibold)).foregroundStyle(Color.brandSoft)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.07)).frame(height: 10)
                    Capsule()
                        .fill(LinearGradient(colors: [Color.brandSoft, Color.brand], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * (appeared ? xpProg : 0), height: 10)
                        .animation(.easeOut(duration: 1.1).delay(0.35), value: appeared)
                }
            }.frame(height: 10)
        }
        .padding(18).cardStyle(radius: 18)
        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.18), value: appeared)
    }

    private var statsRow: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatTile2(value: "\(total)",   label: "Answered", icon: "checkmark.circle",    color: Color.brandSoft)
            StatTile2(value: "\(correct)", label: "Correct",  icon: "checkmark.seal.fill", color: Color.success)
            StatTile2(value: "\(wrong)",   label: "Wrong",    icon: "xmark.circle.fill",   color: Color.danger)
        }
        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.28), value: appeared)
    }

    private var scoreBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Score").font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.textSub).kerning(0.8)
                Text("\(viewModel.score)").font(.system(size: 42, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
            Spacer()
            VStack(spacing: 4) {
                ZStack {
                    Circle().fill(Color.warn.opacity(0.15)).frame(width: 58, height: 58)
                    Image(systemName: "star.fill").font(.system(size: 26)).foregroundStyle(Color.warn)
                }
                Text("Best \(viewModel.bestStreak)🔥").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundStyle(Color.textMuted)
            }
        }
        .padding(22).cardStyle(radius: 22)
        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.38), value: appeared)
    }

    private var picker: some View {
        HStack(spacing: 0) {
            ForEach(["Badges", "Review", "History"].enumerated().map { $0 }, id: \.offset) { i, title in
                Button { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selectedTab = i } } label: {
                    Text(title)
                        .font(.system(size: 13, weight: selectedTab == i ? .black : .medium, design: .rounded))
                        .foregroundStyle(selectedTab == i ? .white : Color.textMuted)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(selectedTab == i ? Color.brand.opacity(0.25) : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }.buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.45), value: appeared)
    }

    @ViewBuilder private var tabContent: some View {
        switch selectedTab {
        case 0: badgesTab
        case 1: reviewTab
        default: historyTab
        }
    }

    private var badgesTab: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(Array(badges.enumerated()), id: \.offset) { i, badge in
                BadgeTile(name: badge.0, icon: badge.1, unlocked: badge.2)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.45 + Double(i) * 0.06), value: appeared)
            }
        }.padding(.horizontal, 20)
    }

    @ViewBuilder private var reviewTab: some View {
        if viewModel.answeredQuestions.isEmpty {
            emptyState(icon: "text.bubble", message: "Complete a quiz to see your performance review.").padding(.horizontal, 20)
        } else {
            VStack(spacing: 12) {
                VStack(spacing: 16) {
                    Text(accuracyLabel).font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(ringColor)
                    HStack(spacing: 20) {
                        reviewStat(value: "\(correct)", label: "Correct", color: .success)
                        reviewStat(value: "\(wrong)", label: "Wrong", color: .danger)
                        reviewStat(value: "\(Int(accuracy * 100))%", label: "Accuracy", color: ringColor)
                    }
                    Text(performanceAdvice).font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.textSub).multilineTextAlignment(.center).padding(.horizontal, 8)
                }
                .padding(20).cardStyle(radius: 20).padding(.horizontal, 20)
                if wrong > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("REVIEW MISSED QUESTIONS").font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(Color.textMuted).kerning(1.1).padding(.horizontal, 20)
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.answeredQuestions.filter { !$0.isCorrect }.enumerated()), id: \.offset) { idx, q in
                                ReviewRow(index: idx + 1, item: q)
                                if idx < viewModel.answeredQuestions.filter({ !$0.isCorrect }).count - 1 { RowsDivider() }
                            }
                        }.cardStyle(radius: 20).padding(.horizontal, 20)
                    }
                }
            }
        }
    }

    private func reviewStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(color)
            Text(label).font(.system(size: 11, weight: .medium)).foregroundStyle(Color.textSub)
        }.frame(maxWidth: .infinity)
    }

    private var performanceAdvice: String {
        if accuracy >= 0.90 { return "Incredible! You've mastered this topic. Try Hard mode!" }
        if accuracy >= 0.75 { return "Great performance! Review the missed questions to reach 90%+." }
        if accuracy >= 0.50 { return "Good effort! Focus on the missed questions and try again." }
        if total == 0       { return "No answers yet. Start a quiz!" }
        return "Keep practicing! Consistency is key."
    }

    @ViewBuilder private var historyTab: some View {
        if viewModel.allTimeAnsweredQuestions.isEmpty {
            emptyState(icon: "clock", message: "No history yet. Start a quiz!").padding(.horizontal, 20)
        } else {
            VStack(spacing: 0) {
                ForEach(Array(viewModel.allTimeAnsweredQuestions.enumerated()), id: \.offset) { idx, q in
                    ReviewRow(index: idx + 1, item: q)
                    if idx < viewModel.allTimeAnsweredQuestions.count - 1 { RowsDivider() }
                }
            }.cardStyle(radius: 20).padding(.horizontal, 20)
        }
    }

    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 36)).foregroundStyle(Color.textMuted)
            Text(message).font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.textMuted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 50).cardStyle(radius: 20)
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedAvatar") private var savedAvatar: Int = 0

    let currentAvatar: Int
    let currentName:   String
    let avatars:       [String]
    let onSave: (Int, String) -> Void

    @State private var tempAvatar: Int
    @State private var tempName:   String
    @FocusState private var focused: Bool

    private let gradientColors: [Color] = [
        Color(red: 0.45, green: 0.18, blue: 0.95),
        Color(red: 0.28, green: 0.10, blue: 0.72)
    ]

    init(currentAvatar: Int, currentName: String, avatars: [String], onSave: @escaping (Int, String) -> Void) {
        self.currentAvatar = currentAvatar
        self.currentName   = currentName
        self.avatars       = avatars
        self.onSave        = onSave
        _tempAvatar = State(initialValue: currentAvatar)
        _tempName   = State(initialValue: currentName == "Explorer" ? "" : currentName)
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.15).ignoresSafeArea()
            StarfieldView().ignoresSafeArea()
            ZStack {
                RadialGradient(colors: [Color(red: 0.22, green: 0.06, blue: 0.55).opacity(0.40), .clear],
                               center: .init(x: 0.2, y: 0.2), startRadius: 0, endRadius: 300)
                RadialGradient(colors: [Color(red: 0.04, green: 0.14, blue: 0.50).opacity(0.30), .clear],
                               center: .init(x: 0.85, y: 0.75), startRadius: 0, endRadius: 250)
            }.ignoresSafeArea()

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.25))
                    .frame(width: 40, height: 5).padding(.top, 14).padding(.bottom, 24)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Edit Profile").font(.system(size: 22, weight: .black, design: .rounded)).foregroundStyle(.white)
                        Text("Change your avatar and name").font(.system(size: 13, weight: .medium)).foregroundStyle(Color.white.opacity(0.40))
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 26)).foregroundStyle(Color.white.opacity(0.30))
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 28)

                // Big avatar preview
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [gradientColors[0].opacity(0.30), gradientColors[1].opacity(0.12), .clear],
                                            center: .center, startRadius: 0, endRadius: 70))
                        .frame(width: 140, height: 140)
                    Circle()
                        .trim(from: 0, to: 0.6)
                        .stroke(AngularGradient(colors: [
                            Color(red: 0.55, green: 0.30, blue: 1.0).opacity(0.0),
                            Color(red: 0.55, green: 0.30, blue: 1.0).opacity(0.55),
                            Color(red: 0.55, green: 0.30, blue: 1.0).opacity(0.0),
                        ], center: .center), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                        .frame(width: 115, height: 115)
                    Text(avatars[tempAvatar]).font(.system(size: 58))
                        .id(tempAvatar).transition(.scale(scale: 0.6).combined(with: .opacity))
                }
                .padding(.bottom, 24)

                // Avatar grid
                HStack(spacing: 10) {
                    ForEach(Array(avatars.enumerated()), id: \.offset) { i, emoji in
                        Button {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.65)) { tempAvatar = i }
                        } label: {
                            Text(emoji).font(.system(size: 22))
                                .frame(width: 46, height: 46)
                                .background(
                                    Circle()
                                        .fill(tempAvatar == i ? gradientColors[0].opacity(0.28) : Color.white.opacity(0.06))
                                        .overlay(Circle().strokeBorder(
                                            tempAvatar == i ? gradientColors[0].opacity(0.65) : Color.white.opacity(0.10),
                                            lineWidth: tempAvatar == i ? 2 : 1))
                                )
                                .scaleEffect(tempAvatar == i ? 1.12 : 1.0)
                                .animation(.spring(response: 0.32, dampingFraction: 0.65), value: tempAvatar)
                                .contentShape(Circle())
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 28)

                // Name field
                HStack(spacing: 12) {
                    Image(systemName: "pencil.line").font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(red: 0.72, green: 0.55, blue: 1.0))
                    TextField("", text: $tempName, prompt: Text("Your name (optional)").foregroundStyle(Color.white.opacity(0.25)))
                        .font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundStyle(.white)
                        .focused($focused).submitLabel(.done).onSubmit { focused = false }
                    if !tempName.isEmpty {
                        Button { withAnimation { tempName = "" } } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(Color.white.opacity(0.35))
                        }
                    }
                }
                .padding(.horizontal, 18).padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(focused ? gradientColors[0].opacity(0.65) : Color.white.opacity(0.10),
                                          lineWidth: focused ? 1.5 : 1))
                )
                .padding(.horizontal, 24)
                .animation(.easeInOut(duration: 0.2), value: focused)

                Spacer()

                // Save button
                Button {
                    focused = false
                    savedAvatar = tempAvatar
                    onSave(tempAvatar, tempName)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(avatars[tempAvatar]).font(.system(size: 20))
                        Text("Save Changes").font(.system(size: 17, weight: .black, design: .rounded))
                        Spacer()
                        ZStack {
                            Circle().fill(Color.white.opacity(0.15)).frame(width: 32, height: 32)
                            Image(systemName: "checkmark").font(.system(size: 12, weight: .black))
                        }
                    }
                    .foregroundStyle(.white).padding(.horizontal, 20).padding(.vertical, 17)
                    .background(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: gradientColors[0].opacity(0.5), radius: 20, y: 8)
                }
                .buttonStyle(SetupButtonStyle())
                .padding(.horizontal, 24).padding(.bottom, 40)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Supporting Views
struct StatTile2: View {
    let value: String; let label: String; let icon: String; let color: Color
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).font(.system(size: 18)).foregroundStyle(color)
            }
            Text(value).font(.system(size: 24, weight: .black, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 11, weight: .medium)).foregroundStyle(Color.textSub)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 18).cardStyle(radius: 18)
    }
}

struct BadgeTile: View {
    let name: String; let icon: String; let unlocked: Bool
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(unlocked ? Color.brand.opacity(0.18) : Color.white.opacity(0.05)).frame(width: 48, height: 48)
                Image(systemName: icon).font(.system(size: 20)).foregroundStyle(unlocked ? Color.brand : Color.textMuted).opacity(unlocked ? 1 : 0.4)
                if !unlocked {
                    Image(systemName: "lock.fill").font(.system(size: 9)).foregroundStyle(Color.textMuted).offset(x: 14, y: 14)
                }
            }
            Text(name).font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(unlocked ? .white : Color.textMuted).multilineTextAlignment(.center).lineLimit(2)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14).padding(.horizontal, 8).cardStyle(radius: 16).opacity(unlocked ? 1 : 0.55)
    }
}

struct ReviewRow: View {
    let index: Int; let item: AnsweredQuestion
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(item.isCorrect ? Color.success.opacity(0.15) : Color.danger.opacity(0.15)).frame(width: 30, height: 30)
                Text("\(index)").font(.system(size: 12, weight: .bold)).foregroundStyle(item.isCorrect ? Color.success : Color.danger)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(item.question.question).font(.system(size: 13, weight: .medium, design: .rounded)).foregroundStyle(.white).lineLimit(2)
                if !item.isCorrect {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(Color.success)
                        Text(item.question.correctAnswer).font(.system(size: 11)).foregroundStyle(Color.success).lineLimit(1)
                    }
                }
            }
            Spacer()
            Image(systemName: item.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 18)).foregroundStyle(item.isCorrect ? Color.success : Color.danger)
        }
        .padding(.horizontal, 18).padding(.vertical, 13)
    }
}

struct RowsDivider: View {
    var body: some View {
        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1).padding(.horizontal, 18)
    }
}

#Preview {
    NavigationStack { ProfileView(viewModel: QuestionViewModel()) }
}
