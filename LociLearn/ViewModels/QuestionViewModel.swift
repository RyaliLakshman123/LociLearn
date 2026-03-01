//
//  QuestionViewModel.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 21/02/26.
//


import Foundation
import SwiftUI
import Combine
import ARKit
import UIKit

// MARK: - Answered Question (for history)
struct AnsweredQuestion: Identifiable {
    let id = UUID()
    let question: Question
    let selectedAnswer: String
    let isCorrect: Bool
}

@MainActor
class QuestionViewModel: ObservableObject {

    // MARK: - Published State
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // AR triggers
    @Published var placeCardTrigger: Bool = false
    @Published var refreshCardTrigger: Bool = false
    @Published var isCardFlipped: Bool = false
    @Published var selectedAnswer: String? = nil

    // History
    @Published var answeredQuestions: [AnsweredQuestion] = []
    @Published var showHistory: Bool = false
    @Published var cachedQuestions: [Question] = []
    
    // Game
    @Published var streak: Int = 0
    @Published var bestStreak: Int = 0
    
    // Streak / XP
    @Published var xp: Int = 0
    @Published var showResultBanner: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var totalSessions: Int = 0
    @Published var totalCorrectAnswers: Int = 0
    @Published var totalAnswered: Int = 0
    @Published var allTimeAnsweredQuestions: [AnsweredQuestion] = []
    @Published var currentDifficulty: String = "medium"
    
    // MARK: - Daily Challenge
    @Published var hasCompletedDaily: Bool = false
    private let dailyCompletionKey = "ll_dailyCompletionDate"
    @Published var isDailyMode: Bool = false
    @Published var showDailyCompletionCelebration: Bool = false
    @Published var showConfetti: Bool = false
    
    // MARK: - Solar / AR
    @Published var arQuestions: [Question] = []
    @Published var currentARQuestionIndex: Int = 0
    @Published var arModeActive: Bool = false
    @Published var selectedPlanet: PlanetType?
    
    private let streakKey = "ll_streak"
    private let bestStreakKey = "ll_bestStreak"
    private let lastActiveDateKey = "ll_lastActiveDate"
    private let historyKey      = "ll_allTimeAnsweredQuestions"
    private let scoreKey        = "ll_score"
    private let xpKey           = "ll_xp"
    
    init() {
        loadStreak()
        checkDailyCompletion()
        loadHistory()
    }
    
    struct PersistedAnswer: Codable {
        let questionText: String
        let options: [String]
        let correctAnswer: String
        let topic: String
        let selectedAnswer: String
        let isCorrect: Bool
    }
    
    // MARK: - Streak persistence
    
    private func saveStreak() {
        UserDefaults.standard.set(streak, forKey: streakKey)
        UserDefaults.standard.set(bestStreak, forKey: bestStreakKey)
        UserDefaults.standard.set(Date(), forKey: lastActiveDateKey)
    }
    
    private func loadStreak() {
        streak = UserDefaults.standard.integer(forKey: streakKey)
        bestStreak = UserDefaults.standard.integer(forKey: bestStreakKey)
        
        if let lastDate = UserDefaults.standard.object(forKey: lastActiveDateKey) as? Date {
            if !Calendar.current.isDateInYesterday(lastDate) &&
               !Calendar.current.isDateInToday(lastDate) {
                streak = 0
            }
        }
    }
    
    private func dailyRotatingSubject() -> Subject {
        let subjects = Subject.allCases
        let index = dailySeed() % subjects.count
        return subjects[index]
    }
    
    private func markDailyCompleted() {
        UserDefaults.standard.set(Date(), forKey: dailyCompletionKey)
        hasCompletedDaily = true
    }
    
    // MARK: - Computed
    
    var correctAnswer: String? {
        currentQuestion?.correctAnswer
    }

    var currentQuestion: Question? {
        guard questions.indices.contains(currentQuestionIndex) else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }

    var isLastQuestion: Bool {
        currentQuestionIndex >= questions.count - 1
    }

    // MARK: - Actions
    
    func selectAnswer(_ option: String) {
        selectedAnswer = option
        
        let correct = option == correctAnswer
        lastAnswerCorrect = correct
        showResultBanner = true
        totalAnswered += 1
        
        if correct {
            totalCorrectAnswers += 1
            let earnedXP = xpForDifficulty()
            score += earnedXP
            xp += earnedXP
            streak += 1
            bestStreak = max(bestStreak, streak)
            saveStreak()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else {
            streak = 0
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }

        if let current = currentQuestion {
            let aq = AnsweredQuestion(
                question: current,
                selectedAnswer: option,
                isCorrect: correct
            )
            answeredQuestions.append(aq)
            allTimeAnsweredQuestions.append(aq)
            saveHistory()
        }
    }
    
    func saveHistory() {
        let persisted = allTimeAnsweredQuestions.map { aq in
            PersistedAnswer(
                questionText: aq.question.question,
                options: aq.question.options,
                correctAnswer: aq.question.correctAnswer,
                topic: aq.question.topic,
                selectedAnswer: aq.selectedAnswer,
                isCorrect: aq.isCorrect
            )
        }
        if let data = try? JSONEncoder().encode(persisted) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
        UserDefaults.standard.set(totalAnswered,        forKey: "ll_totalAnswered")
        UserDefaults.standard.set(totalCorrectAnswers,  forKey: "ll_totalCorrect")
        UserDefaults.standard.set(score,                forKey: scoreKey)
        UserDefaults.standard.set(xp,                   forKey: xpKey)
    }

    func loadHistory() {
        totalAnswered       = UserDefaults.standard.integer(forKey: "ll_totalAnswered")
        totalCorrectAnswers = UserDefaults.standard.integer(forKey: "ll_totalCorrect")
        score               = UserDefaults.standard.integer(forKey: scoreKey)
        xp                  = UserDefaults.standard.integer(forKey: xpKey)

        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let persisted = try? JSONDecoder().decode([PersistedAnswer].self, from: data) else { return }

        allTimeAnsweredQuestions = persisted.map { p in
            AnsweredQuestion(
                question: Question(
                    question: p.questionText,
                    options: p.options,
                    correctAnswer: p.correctAnswer,
                    topic: p.topic
                ),
                selectedAnswer: p.selectedAnswer,
                isCorrect: p.isCorrect
            )
        }
    }

    func nextQuestion() {
        if currentQuestionIndex >= questions.count - 1 {
            if isDailyMode { markDailyCompleted() }
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showConfetti = false
            }
        } else {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showResultBanner = false
        }
    }
    
    func startSubjectMode(_ subject: Subject) {
        questions = subjectQuestions(for: subject).shuffled()
        currentQuestionIndex = 0
        selectedAnswer = nil
        score = 0
    }
    
    private func xpForDifficulty() -> Int {
        var base: Int
        switch currentDifficulty {
        case "easy":   base = 10
        case "medium": base = 20
        case "hard":   base = 35
        default:       base = 15
        }
        return isDailyMode ? base * 2 : base
    }
    
    
    func dailySeed() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return Int(formatter.string(from: Date())) ?? 1
    }
    
    func checkDailyCompletion() {
        if let savedDate = UserDefaults.standard.object(forKey: dailyCompletionKey) as? Date {
            hasCompletedDaily = Calendar.current.isDateInToday(savedDate)
        } else {
            hasCompletedDaily = false
        }
    }
    
    func resetDailyForTesting() {
        UserDefaults.standard.removeObject(forKey: dailyCompletionKey)
        hasCompletedDaily = false
    }
    
    // MARK: - Solar AR Mode
    func startSolarMode() {
        guard let planet = selectedPlanet else { return }

        arModeActive = true
        currentARQuestionIndex = 0
        selectedAnswer = nil
        showConfetti = false

        arQuestions = planetQuestions(for: planet).shuffled()
    }

//    private func fetchARQuestions(for planet: PlanetType) async {
//        // Skip Render entirely — it cold-starts too slowly
//        // Use OpenTDB Science category as primary source
//        let fallbackURL = "https://opentdb.com/api.php?amount=10&category=17&type=multiple"
//        
//        do {
//            guard let url = URL(string: fallbackURL) else { throw URLError(.badURL) }
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
//            let fetched = decoded.results.map { Question(apiModel: $0) }
//            
//            guard !fetched.isEmpty else {
//                arQuestions = planetQuestions(for: planet) // use hardcoded fallback
//                placeCardTrigger = true
//                return
//            }
//            
//            arQuestions = fetched
//            placeCardTrigger = true  // ← fire AFTER data arrives
//            
//        } catch {
//            // Network failed — use hardcoded planet questions so app still works
//            arQuestions = planetQuestions(for: planet)
//            placeCardTrigger = true
//        }
//    }
    
    private func planetQuestions(for planet: PlanetType) -> [Question] {

        switch planet {

        case .mercury:
            return [

                Question(question: "Which planet is closest to the Sun?",
                         options: ["Mercury", "Venus", "Earth", "Mars"],
                         correctAnswer: "Mercury", topic: "mercury"),

                Question(question: "How many moons does Mercury have?",
                         options: ["0", "1", "2", "4"],
                         correctAnswer: "0", topic: "mercury"),

                Question(question: "A year on Mercury lasts how many Earth days?",
                         options: ["88 days", "365 days", "30 days", "180 days"],
                         correctAnswer: "88 days", topic: "mercury"),

                Question(question: "Mercury experiences extreme temperature changes because it lacks what?",
                         options: ["Atmosphere", "Oceans", "Gravity", "Rings"],
                         correctAnswer: "Atmosphere", topic: "mercury"),

                Question(question: "What is Mercury primarily made of?",
                         options: ["Rock and metal", "Gas", "Ice", "Water"],
                         correctAnswer: "Rock and metal", topic: "mercury"),

                Question(question: "Mercury rotates how compared to Earth?",
                         options: ["Much slower", "Faster", "Same speed", "Does not rotate"],
                         correctAnswer: "Much slower", topic: "mercury"),

                Question(question: "What is the largest crater on Mercury?",
                         options: ["Caloris Basin", "Olympus Mons", "Valles Marineris", "Tycho"],
                         correctAnswer: "Caloris Basin", topic: "mercury"),

                Question(question: "Mercury has similarities to which celestial body?",
                         options: ["Moon", "Sun", "Saturn", "Neptune"],
                         correctAnswer: "Moon", topic: "mercury"),

                Question(question: "Mercury’s gravity is approximately what percent of Earth’s?",
                         options: ["38%", "100%", "80%", "10%"],
                         correctAnswer: "38%", topic: "mercury"),

                Question(question: "Mercury is classified as what type of planet?",
                         options: ["Terrestrial", "Gas giant", "Ice giant", "Dwarf"],
                         correctAnswer: "Terrestrial", topic: "mercury"),

                Question(question: "Mercury’s day (one full rotation) lasts about?",
                         options: ["59 Earth days", "24 hours", "7 days", "88 days"],
                         correctAnswer: "59 Earth days", topic: "mercury"),

                Question(question: "Which spacecraft first visited Mercury?",
                         options: ["Mariner 10", "Voyager 1", "Apollo 11", "Hubble"],
                         correctAnswer: "Mariner 10", topic: "mercury"),

                Question(question: "Mercury has visible what on its surface?",
                         options: ["Impact craters", "Oceans", "Forests", "Ice caps"],
                         correctAnswer: "Impact craters", topic: "mercury"),

                Question(question: "Mercury is visible from Earth during?",
                         options: ["Twilight", "Midnight only", "Noon only", "Never"],
                         correctAnswer: "Twilight", topic: "mercury"),

                Question(question: "Mercury’s orbit is highly what?",
                         options: ["Elliptical", "Circular", "Square", "Flat"],
                         correctAnswer: "Elliptical", topic: "mercury")
            ]

        case .venus:
            return [

                Question(question: "Which planet is known as Earth’s twin?",
                         options: ["Venus", "Mars", "Mercury", "Neptune"],
                         correctAnswer: "Venus", topic: "venus"),

                Question(question: "Venus rotates in which direction?",
                         options: ["Retrograde", "Prograde", "Both", "None"],
                         correctAnswer: "Retrograde", topic: "venus"),

                Question(question: "Venus is the hottest planet because of?",
                         options: ["Greenhouse effect", "Proximity to Sun", "Volcanoes", "Rings"],
                         correctAnswer: "Greenhouse effect", topic: "venus"),

                Question(question: "What gas dominates Venus’s atmosphere?",
                         options: ["Carbon Dioxide", "Oxygen", "Hydrogen", "Nitrogen"],
                         correctAnswer: "Carbon Dioxide", topic: "venus"),

                Question(question: "A day on Venus is longer than its?",
                         options: ["Year", "Rotation", "Orbit", "Axis"],
                         correctAnswer: "Year", topic: "venus"),

                Question(question: "Venus is classified as a?",
                         options: ["Terrestrial planet", "Gas giant", "Ice giant", "Comet"],
                         correctAnswer: "Terrestrial planet", topic: "venus"),

                Question(question: "Venus has thick clouds made of?",
                         options: ["Sulfuric acid", "Water", "Helium", "Nitrogen"],
                         correctAnswer: "Sulfuric acid", topic: "venus"),

                Question(question: "Venus is often called the?",
                         options: ["Morning Star", "Red Star", "Blue Giant", "Ice Queen"],
                         correctAnswer: "Morning Star", topic: "venus"),

                Question(question: "Surface temperature of Venus is about?",
                         options: ["460°C", "100°C", "0°C", "1000°C"],
                         correctAnswer: "460°C", topic: "venus"),

                Question(question: "Venus has how many moons?",
                         options: ["0", "1", "2", "5"],
                         correctAnswer: "0", topic: "venus"),

                Question(question: "Which spacecraft landed on Venus?",
                         options: ["Venera", "Apollo", "Voyager", "Curiosity"],
                         correctAnswer: "Venera", topic: "venus"),

                Question(question: "Venus shines brightly because it?",
                         options: ["Reflects sunlight strongly", "Emits its own light", "Has lava", "Has ice"],
                         correctAnswer: "Reflects sunlight strongly", topic: "venus"),

                Question(question: "Venus’ atmospheric pressure is how compared to Earth?",
                         options: ["Much higher", "Same", "Lower", "Zero"],
                         correctAnswer: "Much higher", topic: "venus"),

                Question(question: "Venus has evidence of?",
                         options: ["Volcanoes", "Oceans", "Forests", "Rings"],
                         correctAnswer: "Volcanoes", topic: "venus"),

                Question(question: "Venus is the ___ planet from the Sun.",
                         options: ["Second", "First", "Third", "Fourth"],
                         correctAnswer: "Second", topic: "venus")
            ]

        case .earth:
            return [

                Question(
                    question: "Which planet supports life?",
                    options: ["Earth", "Mars", "Venus", "Jupiter"],
                    correctAnswer: "Earth",
                    topic: "earth"
                ),

                Question(
                    question: "What percentage of Earth is covered by water?",
                    options: ["71%", "50%", "30%", "90%"],
                    correctAnswer: "71%",
                    topic: "earth"
                ),

                Question(
                    question: "What gas is most abundant in Earth's atmosphere?",
                    options: ["Nitrogen", "Oxygen", "Carbon Dioxide", "Hydrogen"],
                    correctAnswer: "Nitrogen",
                    topic: "earth"
                ),

                Question(
                    question: "What protects Earth from harmful solar radiation?",
                    options: ["Magnetic field", "Clouds", "Mountains", "Oceans"],
                    correctAnswer: "Magnetic field",
                    topic: "earth"
                ),

                Question(
                    question: "How long does Earth take to orbit the Sun?",
                    options: ["365 days", "30 days", "180 days", "500 days"],
                    correctAnswer: "365 days",
                    topic: "earth"
                ),

                Question(
                    question: "What layer protects Earth from meteors?",
                    options: ["Atmosphere", "Crust", "Core", "Mantle"],
                    correctAnswer: "Atmosphere",
                    topic: "earth"
                ),

                Question(
                    question: "Earth is classified as which type of planet?",
                    options: ["Terrestrial", "Gas giant", "Ice giant", "Dwarf"],
                    correctAnswer: "Terrestrial",
                    topic: "earth"
                ),

                Question(
                    question: "What is Earth’s only natural satellite?",
                    options: ["Moon", "Phobos", "Europa", "Titan"],
                    correctAnswer: "Moon",
                    topic: "earth"
                ),

                Question(
                    question: "Which layer of Earth is molten?",
                    options: ["Outer core", "Crust", "Troposphere", "Lithosphere"],
                    correctAnswer: "Outer core",
                    topic: "earth"
                ),

                Question(
                    question: "Earth’s atmosphere contains roughly how much oxygen?",
                    options: ["21%", "50%", "10%", "80%"],
                    correctAnswer: "21%",
                    topic: "earth"
                ),

                Question(
                    question: "Which force keeps us grounded on Earth?",
                    options: ["Gravity", "Magnetism", "Wind", "Friction"],
                    correctAnswer: "Gravity",
                    topic: "earth"
                ),

                Question(
                    question: "What causes day and night on Earth?",
                    options: ["Rotation", "Revolution", "Tilt", "Magnetism"],
                    correctAnswer: "Rotation",
                    topic: "earth"
                ),

                Question(
                    question: "What is the hottest layer of Earth?",
                    options: ["Inner core", "Crust", "Mantle", "Atmosphere"],
                    correctAnswer: "Inner core",
                    topic: "earth"
                ),

                Question(
                    question: "What major gas contributes to climate change?",
                    options: ["Carbon Dioxide", "Nitrogen", "Oxygen", "Helium"],
                    correctAnswer: "Carbon Dioxide",
                    topic: "earth"
                ),

                Question(
                    question: "Earth is located in which galaxy?",
                    options: ["Milky Way", "Andromeda", "Whirlpool", "Sombrero"],
                    correctAnswer: "Milky Way",
                    topic: "earth"
                )
            ]

        case .mars:
            return [

                Question(question: "Which planet is known as the Red Planet?",
                         options: ["Mars", "Venus", "Earth", "Jupiter"],
                         correctAnswer: "Mars", topic: "mars"),

                Question(question: "Mars gets its red color from?",
                         options: ["Iron oxide", "Lava", "Dust storms", "Sunlight"],
                         correctAnswer: "Iron oxide", topic: "mars"),

                Question(question: "Mars has how many moons?",
                         options: ["2", "1", "0", "5"],
                         correctAnswer: "2", topic: "mars"),

                Question(question: "The tallest volcano in the solar system is on Mars called?",
                         options: ["Olympus Mons", "Everest", "Mauna Kea", "Caloris"],
                         correctAnswer: "Olympus Mons", topic: "mars"),

                Question(question: "Mars is smaller than?",
                         options: ["Earth", "Mercury", "Moon", "Pluto"],
                         correctAnswer: "Earth", topic: "mars"),

                Question(question: "Mars atmosphere is mostly?",
                         options: ["Carbon Dioxide", "Oxygen", "Hydrogen", "Nitrogen"],
                         correctAnswer: "Carbon Dioxide", topic: "mars"),

                Question(question: "A Martian day is about?",
                         options: ["24.6 hours", "12 hours", "48 hours", "10 hours"],
                         correctAnswer: "24.6 hours", topic: "mars"),

                Question(question: "Which rover explored Mars?",
                         options: ["Perseverance", "Voyager", "Hubble", "Apollo"],
                         correctAnswer: "Perseverance", topic: "mars"),

                Question(question: "Mars has large dust what?",
                         options: ["Storms", "Oceans", "Rings", "Winds"],
                         correctAnswer: "Storms", topic: "mars"),

                Question(question: "Mars is the ___ planet from the Sun.",
                         options: ["Fourth", "Second", "Third", "Fifth"],
                         correctAnswer: "Fourth", topic: "mars"),

                Question(question: "Mars gravity is about what of Earth's?",
                         options: ["38%", "100%", "80%", "10%"],
                         correctAnswer: "38%", topic: "mars"),

                Question(question: "Evidence suggests Mars once had?",
                         options: ["Liquid water", "Forests", "Oceans today", "Rings"],
                         correctAnswer: "Liquid water", topic: "mars"),

                Question(question: "Mars surface features include?",
                         options: ["Canyons", "Coral reefs", "Ice rings", "Cloud cities"],
                         correctAnswer: "Canyons", topic: "mars"),

                Question(question: "The largest canyon on Mars is?",
                         options: ["Valles Marineris", "Grand Canyon", "Caloris", "Olympus"],
                         correctAnswer: "Valles Marineris", topic: "mars"),

                Question(question: "Mars is classified as?",
                         options: ["Terrestrial planet", "Gas giant", "Ice giant", "Comet"],
                         correctAnswer: "Terrestrial planet", topic: "mars")
            ]

        case .jupiter:
            return [

                Question(question: "Which is the largest planet in the Solar System?",
                         options: ["Jupiter", "Saturn", "Neptune", "Earth"],
                         correctAnswer: "Jupiter", topic: "jupiter"),

                Question(question: "Jupiter is primarily composed of?",
                         options: ["Hydrogen and Helium", "Rock", "Ice", "Iron"],
                         correctAnswer: "Hydrogen and Helium", topic: "jupiter"),

                Question(question: "The Great Red Spot on Jupiter is?",
                         options: ["A giant storm", "A volcano", "An ocean", "A crater"],
                         correctAnswer: "A giant storm", topic: "jupiter"),

                Question(question: "How long has the Great Red Spot existed?",
                         options: ["Over 350 years", "10 years", "50 years", "1000 years"],
                         correctAnswer: "Over 350 years", topic: "jupiter"),

                Question(question: "Jupiter has approximately how many known moons?",
                         options: ["95+", "10", "4", "1"],
                         correctAnswer: "95+", topic: "jupiter"),

                Question(question: "Which of these is NOT one of Jupiter’s largest moons?",
                         options: ["Titan", "Europa", "Io", "Ganymede"],
                         correctAnswer: "Titan", topic: "jupiter"),

                Question(question: "Jupiter completes one rotation in about?",
                         options: ["10 hours", "24 hours", "48 hours", "5 days"],
                         correctAnswer: "10 hours", topic: "jupiter"),

                Question(question: "Jupiter’s strong gravity helps protect Earth by?",
                         options: ["Deflecting comets", "Blocking sunlight", "Stopping asteroids entirely", "Cooling space"],
                         correctAnswer: "Deflecting comets", topic: "jupiter"),

                Question(question: "Jupiter is classified as a?",
                         options: ["Gas giant", "Ice giant", "Terrestrial planet", "Dwarf planet"],
                         correctAnswer: "Gas giant", topic: "jupiter"),

                Question(question: "The largest moon in the Solar System is?",
                         options: ["Ganymede", "Europa", "Titan", "Moon"],
                         correctAnswer: "Ganymede", topic: "jupiter"),

                Question(question: "Jupiter’s magnetic field is?",
                         options: ["The strongest of any planet", "Very weak", "Same as Earth", "Nonexistent"],
                         correctAnswer: "The strongest of any planet", topic: "jupiter"),

                Question(question: "A year on Jupiter lasts about?",
                         options: ["12 Earth years", "1 year", "2 years", "30 years"],
                         correctAnswer: "12 Earth years", topic: "jupiter"),

                Question(question: "Europa is interesting because it may have?",
                         options: ["An ocean beneath ice", "Volcanoes", "Forests", "Rings"],
                         correctAnswer: "An ocean beneath ice", topic: "jupiter"),

                Question(question: "Jupiter emits more energy than it?",
                         options: ["Receives from the Sun", "Produces", "Reflects", "Absorbs"],
                         correctAnswer: "Receives from the Sun", topic: "jupiter"),

                Question(question: "Jupiter’s atmosphere features colorful?",
                         options: ["Cloud bands", "Oceans", "Mountains", "Ice caps"],
                         correctAnswer: "Cloud bands", topic: "jupiter")
            ]

        case .saturn:
            return [

                Question(question: "Saturn is best known for its?",
                         options: ["Rings", "Volcanoes", "Oceans", "Mountains"],
                         correctAnswer: "Rings", topic: "saturn"),

                Question(question: "Saturn is classified as a?",
                         options: ["Gas giant", "Ice giant", "Rocky planet", "Dwarf planet"],
                         correctAnswer: "Gas giant", topic: "saturn"),

                Question(question: "Saturn is the ___ largest planet.",
                         options: ["Second", "First", "Third", "Fourth"],
                         correctAnswer: "Second", topic: "saturn"),

                Question(question: "Saturn’s rings are made mostly of?",
                         options: ["Ice and rock", "Gas", "Metal", "Dust only"],
                         correctAnswer: "Ice and rock", topic: "saturn"),

                Question(question: "Saturn is less dense than?",
                         options: ["Water", "Earth", "Mars", "Ice"],
                         correctAnswer: "Water", topic: "saturn"),

                Question(question: "Saturn’s largest moon is?",
                         options: ["Titan", "Europa", "Io", "Moon"],
                         correctAnswer: "Titan", topic: "saturn"),

                Question(question: "Titan has lakes of?",
                         options: ["Liquid methane", "Water", "Lava", "Oxygen"],
                         correctAnswer: "Liquid methane", topic: "saturn"),

                Question(question: "A year on Saturn lasts about?",
                         options: ["29 Earth years", "12 years", "1 year", "50 years"],
                         correctAnswer: "29 Earth years", topic: "saturn"),

                Question(question: "Saturn’s atmosphere is mainly?",
                         options: ["Hydrogen", "Oxygen", "Carbon dioxide", "Nitrogen"],
                         correctAnswer: "Hydrogen", topic: "saturn"),

                Question(question: "Saturn rotates once in about?",
                         options: ["10.7 hours", "24 hours", "50 hours", "5 days"],
                         correctAnswer: "10.7 hours", topic: "saturn"),

                Question(question: "Saturn’s rings extend thousands of kilometers but are?",
                         options: ["Very thin", "Very thick", "Solid", "Made of gas"],
                         correctAnswer: "Very thin", topic: "saturn"),

                Question(question: "Which spacecraft studied Saturn extensively?",
                         options: ["Cassini", "Apollo", "Curiosity", "Voyager 3"],
                         correctAnswer: "Cassini", topic: "saturn"),

                Question(question: "Saturn has how many known moons?",
                         options: ["140+", "2", "10", "30"],
                         correctAnswer: "140+", topic: "saturn"),

                Question(question: "Saturn appears yellowish due to?",
                         options: ["Cloud layers", "Lava", "Ice", "Dust only"],
                         correctAnswer: "Cloud layers", topic: "saturn"),

                Question(question: "Saturn’s gravity compared to Earth is?",
                         options: ["Slightly stronger", "Much weaker", "Zero", "Identical"],
                         correctAnswer: "Slightly stronger", topic: "saturn")
            ]

        case .uranus:
            return [

                Question(question: "Uranus rotates on its?",
                         options: ["Side", "North pole", "Equator", "Axis straight"],
                         correctAnswer: "Side", topic: "uranus"),

                Question(question: "Uranus is classified as an?",
                         options: ["Ice giant", "Gas giant", "Terrestrial", "Dwarf"],
                         correctAnswer: "Ice giant", topic: "uranus"),

                Question(question: "Uranus appears blue-green because of?",
                         options: ["Methane gas", "Water oceans", "Ice", "Cloud dust"],
                         correctAnswer: "Methane gas", topic: "uranus"),

                Question(question: "Uranus is the ___ planet from the Sun.",
                         options: ["Seventh", "Sixth", "Eighth", "Fifth"],
                         correctAnswer: "Seventh", topic: "uranus"),

                Question(question: "A year on Uranus lasts about?",
                         options: ["84 Earth years", "29 years", "12 years", "1 year"],
                         correctAnswer: "84 Earth years", topic: "uranus"),

                Question(question: "Uranus was discovered in?",
                         options: ["1781", "1900", "1600", "2000"],
                         correctAnswer: "1781", topic: "uranus"),

                Question(question: "Uranus has faint?",
                         options: ["Rings", "Volcanoes", "Oceans", "Ice caps"],
                         correctAnswer: "Rings", topic: "uranus"),

                Question(question: "Uranus atmosphere is composed mainly of?",
                         options: ["Hydrogen, Helium, Methane", "Oxygen", "Carbon monoxide", "Iron vapor"],
                         correctAnswer: "Hydrogen, Helium, Methane", topic: "uranus"),

                Question(question: "Uranus rotates once in about?",
                         options: ["17 hours", "24 hours", "10 hours", "2 days"],
                         correctAnswer: "17 hours", topic: "uranus"),

                Question(question: "The extreme tilt of Uranus likely resulted from?",
                         options: ["A massive collision", "Sun’s gravity", "Magnetic storms", "Comets"],
                         correctAnswer: "A massive collision", topic: "uranus"),

                Question(question: "Uranus has how many known moons?",
                         options: ["27+", "2", "95", "10"],
                         correctAnswer: "27+", topic: "uranus"),

                Question(question: "Uranus seasons last about?",
                         options: ["21 years each", "1 year", "3 months", "6 months"],
                         correctAnswer: "21 years each", topic: "uranus"),

                Question(question: "Uranus interior may contain?",
                         options: ["Icy water and ammonia", "Molten lava", "Solid rock only", "Air pockets"],
                         correctAnswer: "Icy water and ammonia", topic: "uranus"),

                Question(question: "Uranus magnetic field is?",
                         options: ["Tilted and irregular", "Perfectly aligned", "Weak only", "Nonexistent"],
                         correctAnswer: "Tilted and irregular", topic: "uranus"),

                Question(question: "Uranus is colder than?",
                         options: ["Neptune", "Saturn", "Pluto", "Mercury"],
                         correctAnswer: "Saturn", topic: "uranus")
            ]

        case .neptune:
            return [

                Question(question: "Neptune is the ___ planet from the Sun.",
                         options: ["Eighth", "Seventh", "Sixth", "Ninth"],
                         correctAnswer: "Eighth", topic: "neptune"),

                Question(question: "Neptune is classified as an?",
                         options: ["Ice giant", "Gas giant", "Terrestrial", "Dwarf"],
                         correctAnswer: "Ice giant", topic: "neptune"),

                Question(question: "Neptune appears blue because of?",
                         options: ["Methane", "Water oceans", "Ice caps", "Cloud dust"],
                         correctAnswer: "Methane", topic: "neptune"),

                Question(question: "Neptune has the?",
                         options: ["Strongest winds in Solar System", "Weakest winds", "No atmosphere", "No storms"],
                         correctAnswer: "Strongest winds in Solar System", topic: "neptune"),

                Question(question: "A year on Neptune lasts about?",
                         options: ["165 Earth years", "84 years", "29 years", "12 years"],
                         correctAnswer: "165 Earth years", topic: "neptune"),

                Question(question: "Neptune was discovered using?",
                         options: ["Mathematics predictions", "Telescope accident", "Satellite photos", "Apollo mission"],
                         correctAnswer: "Mathematics predictions", topic: "neptune"),

                Question(question: "Neptune’s largest moon is?",
                         options: ["Triton", "Europa", "Titan", "Io"],
                         correctAnswer: "Triton", topic: "neptune"),

                Question(question: "Neptune has faint?",
                         options: ["Rings", "Forests", "Lava oceans", "Mountains"],
                         correctAnswer: "Rings", topic: "neptune"),

                Question(question: "Neptune rotates once in about?",
                         options: ["16 hours", "24 hours", "10 hours", "3 days"],
                         correctAnswer: "16 hours", topic: "neptune"),

                Question(question: "Triton orbits Neptune in a?",
                         options: ["Retrograde direction", "Prograde only", "Circular orbit only", "Static orbit"],
                         correctAnswer: "Retrograde direction", topic: "neptune"),

                Question(question: "Neptune’s Great Dark Spot is?",
                         options: ["A storm", "A crater", "A moon shadow", "A ring"],
                         correctAnswer: "A storm", topic: "neptune"),

                Question(question: "Neptune’s atmosphere is mainly?",
                         options: ["Hydrogen and Helium", "Oxygen", "Carbon dioxide", "Nitrogen"],
                         correctAnswer: "Hydrogen and Helium", topic: "neptune"),

                Question(question: "Neptune is slightly smaller than?",
                         options: ["Uranus", "Saturn", "Jupiter", "Earth"],
                         correctAnswer: "Uranus", topic: "neptune"),

                Question(question: "Neptune emits?",
                         options: ["More heat than it receives", "No heat", "Only reflected light", "Cold radiation only"],
                         correctAnswer: "More heat than it receives", topic: "neptune"),

                Question(question: "Only one spacecraft has visited Neptune, which was?",
                         options: ["Voyager 2", "Cassini", "Hubble", "Apollo"],
                         correctAnswer: "Voyager 2", topic: "neptune")
            ]
        }
    }
    
    private func subjectQuestions(for subject: Subject) -> [Question] {

        switch subject {

        case .biology:
            return [
                Question(question: "What is the powerhouse of the cell?",
                         options: ["Mitochondria", "Nucleus", "Ribosome", "Chloroplast"],
                         correctAnswer: "Mitochondria", topic: "biology"),

                Question(question: "DNA stands for?",
                         options: ["Deoxyribonucleic Acid", "Dynamic Nucleic Acid", "Double Helix Acid", "Data Nucleic Acid"],
                         correctAnswer: "Deoxyribonucleic Acid", topic: "biology"),

                Question(question: "Which organ pumps blood throughout the body?",
                         options: ["Heart", "Liver", "Lungs", "Kidney"],
                         correctAnswer: "Heart", topic: "biology"),

                Question(question: "Photosynthesis occurs in?",
                         options: ["Chloroplast", "Mitochondria", "Nucleus", "Golgi body"],
                         correctAnswer: "Chloroplast", topic: "biology"),

                Question(question: "The basic unit of life is?",
                         options: ["Cell", "Atom", "Organ", "Tissue"],
                         correctAnswer: "Cell", topic: "biology"),

                Question(question: "Which blood cells fight infections?",
                         options: ["White blood cells", "Red blood cells", "Platelets", "Plasma"],
                         correctAnswer: "White blood cells", topic: "biology"),

                Question(question: "Human body has how many chromosomes?",
                         options: ["46", "44", "23", "48"],
                         correctAnswer: "46", topic: "biology"),

                Question(question: "Which organ filters blood?",
                         options: ["Kidney", "Heart", "Brain", "Lungs"],
                         correctAnswer: "Kidney", topic: "biology"),

                Question(question: "The largest organ in the human body is?",
                         options: ["Skin", "Liver", "Brain", "Lungs"],
                         correctAnswer: "Skin", topic: "biology"),

                Question(question: "Plants absorb water using?",
                         options: ["Roots", "Leaves", "Stem", "Flowers"],
                         correctAnswer: "Roots", topic: "biology"),

                Question(question: "Which molecule carries genetic information?",
                         options: ["DNA", "Protein", "Glucose", "Oxygen"],
                         correctAnswer: "DNA", topic: "biology"),

                Question(question: "The respiratory system exchanges?",
                         options: ["Oxygen and Carbon Dioxide", "Blood and Oxygen", "Water and Salt", "Glucose and Oxygen"],
                         correctAnswer: "Oxygen and Carbon Dioxide", topic: "biology"),

                Question(question: "Which organ controls the nervous system?",
                         options: ["Brain", "Heart", "Liver", "Kidney"],
                         correctAnswer: "Brain", topic: "biology"),

                Question(question: "Cell division in body cells is called?",
                         options: ["Mitosis", "Meiosis", "Fusion", "Replication"],
                         correctAnswer: "Mitosis", topic: "biology"),

                Question(question: "Proteins are made in?",
                         options: ["Ribosomes", "Nucleus", "Chloroplast", "Lysosome"],
                         correctAnswer: "Ribosomes", topic: "biology")
            ]
       
        case .computerScience:
            return [
                Question(question: "What does CPU stand for?",
                         options: ["Central Processing Unit", "Computer Processing Unit", "Core Programming Unit", "Central Program Utility"],
                         correctAnswer: "Central Processing Unit", topic: "computerScience"),

                Question(question: "Which language is primarily used for iOS development?",
                         options: ["Swift", "Java", "Python", "C#"],
                         correctAnswer: "Swift", topic: "computerScience"),

                Question(question: "Binary numbers use which digits?",
                         options: ["0 and 1", "1 and 2", "0–9", "A and B"],
                         correctAnswer: "0 and 1", topic: "computerScience"),

                Question(question: "Which data structure uses FIFO?",
                         options: ["Queue", "Stack", "Tree", "Graph"],
                         correctAnswer: "Queue", topic: "computerScience"),

                Question(question: "Which data structure uses LIFO?",
                         options: ["Stack", "Queue", "Array", "Graph"],
                         correctAnswer: "Stack", topic: "computerScience"),

                Question(question: "RAM is?",
                         options: ["Volatile memory", "Permanent storage", "CPU cache", "GPU memory"],
                         correctAnswer: "Volatile memory", topic: "computerScience"),

                Question(question: "Which protocol is used for websites?",
                         options: ["HTTP", "FTP", "SMTP", "SSH"],
                         correctAnswer: "HTTP", topic: "computerScience"),

                Question(question: "AI stands for?",
                         options: ["Artificial Intelligence", "Automated Input", "Advanced Internet", "Algorithmic Interface"],
                         correctAnswer: "Artificial Intelligence", topic: "computerScience"),

                Question(question: "Which company created Swift?",
                         options: ["Apple", "Google", "Microsoft", "IBM"],
                         correctAnswer: "Apple", topic: "computerScience"),

                Question(question: "Which sorting algorithm is fastest on average?",
                         options: ["QuickSort", "Bubble Sort", "Selection Sort", "Insertion Sort"],
                         correctAnswer: "QuickSort", topic: "computerScience"),

                Question(question: "Git is used for?",
                         options: ["Version Control", "Image Editing", "Video Processing", "Hardware Testing"],
                         correctAnswer: "Version Control", topic: "computerScience"),

                Question(question: "What does API stand for?",
                         options: ["Application Programming Interface", "Advanced Program Integration", "Applied Protocol Interface", "Automatic Programming Internet"],
                         correctAnswer: "Application Programming Interface", topic: "computerScience"),

                Question(question: "Which is NOT a programming paradigm?",
                         options: ["Parallel Gravity", "Object-Oriented", "Functional", "Procedural"],
                         correctAnswer: "Parallel Gravity", topic: "computerScience"),

                Question(question: "Machine Learning is a subset of?",
                         options: ["Artificial Intelligence", "Web Design", "Cybersecurity", "Databases"],
                         correctAnswer: "Artificial Intelligence", topic: "computerScience"),

                Question(question: "Which symbol is used for comments in Swift?",
                         options: ["//", "##", "--", "**"],
                         correctAnswer: "//", topic: "computerScience")
            ]
            
        case .solar:
            return [

                Question(
                    question: "Which planet is known as the Red Planet?",
                    options: ["Mars", "Venus", "Jupiter", "Mercury"],
                    correctAnswer: "Mars",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet is closest to the Sun?",
                    options: ["Mercury", "Venus", "Earth", "Mars"],
                    correctAnswer: "Mercury",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet is known for its prominent ring system?",
                    options: ["Saturn", "Uranus", "Neptune", "Jupiter"],
                    correctAnswer: "Saturn",
                    topic: "solar"
                ),

                Question(
                    question: "Which is the largest planet in our Solar System?",
                    options: ["Jupiter", "Saturn", "Neptune", "Earth"],
                    correctAnswer: "Jupiter",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet is known as Earth's twin due to similar size?",
                    options: ["Venus", "Mars", "Mercury", "Neptune"],
                    correctAnswer: "Venus",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet has the strongest winds in the Solar System?",
                    options: ["Neptune", "Jupiter", "Mars", "Saturn"],
                    correctAnswer: "Neptune",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet rotates on its side?",
                    options: ["Uranus", "Saturn", "Earth", "Mars"],
                    correctAnswer: "Uranus",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet has the Great Red Spot?",
                    options: ["Jupiter", "Saturn", "Mars", "Venus"],
                    correctAnswer: "Jupiter",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet has two small moons named Phobos and Deimos?",
                    options: ["Mars", "Earth", "Mercury", "Neptune"],
                    correctAnswer: "Mars",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet is farthest from the Sun?",
                    options: ["Neptune", "Uranus", "Saturn", "Pluto"],
                    correctAnswer: "Neptune",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet has the shortest year?",
                    options: ["Mercury", "Venus", "Earth", "Mars"],
                    correctAnswer: "Mercury",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet has the longest year?",
                    options: ["Neptune", "Uranus", "Saturn", "Jupiter"],
                    correctAnswer: "Neptune",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet is known for its extreme greenhouse effect?",
                    options: ["Venus", "Mars", "Earth", "Jupiter"],
                    correctAnswer: "Venus",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet has the largest moon in the Solar System (Ganymede)?",
                    options: ["Jupiter", "Saturn", "Neptune", "Earth"],
                    correctAnswer: "Jupiter",
                    topic: "solar"
                ),

                Question(
                    question: "Which planet is classified as an Ice Giant?",
                    options: ["Uranus", "Mars", "Mercury", "Earth"],
                    correctAnswer: "Uranus",
                    topic: "solar"
                )
            ]
        }
    }
    
    // MARK: - AR Answer Selection
    func selectARAnswer(_ option: String) {
        guard arQuestions.indices.contains(currentARQuestionIndex) else { return }
        
        selectedAnswer = option
        let correctAns = arQuestions[currentARQuestionIndex].correctAnswer
        let isCorrect = option == correctAns

        // ✅ Append so history button works
        let aq = AnsweredQuestion(
            question: arQuestions[currentARQuestionIndex],
            selectedAnswer: option,
            isCorrect: isCorrect
        )
        answeredQuestions.append(aq)
                allTimeAnsweredQuestions.append(aq)

                if isCorrect {
                    score += 20
                    totalCorrectAnswers += 1
                    streak += 1
                    bestStreak = max(bestStreak, streak)
                    saveStreak()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    streak = 0
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
                totalAnswered += 1
                saveHistory()
            }

    func advanceARQuestion() {
        if currentARQuestionIndex < arQuestions.count - 1 {
            currentARQuestionIndex += 1
            selectedAnswer = nil
        } else {
            // Quiz complete
            selectedAnswer = nil
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showConfetti = false
            }
        }
    }

    // Add this so ARPalaceView's onChange fires correctly
    var isARLastQuestion: Bool {
        currentARQuestionIndex >= arQuestions.count - 1
    }
    
    func checkARAnswer(_ planet: PlanetType) -> Bool {
        guard currentARQuestionIndex < arQuestions.count else { return false }

        let question = arQuestions[currentARQuestionIndex]
        let correct = question.correctAnswer.lowercased() == planet.rawValue.lowercased()

        if correct {
            score += 20
            streak += 1
            bestStreak = max(bestStreak, streak)
            saveStreak()
        } else {
            streak = 0
        }

        return correct
    }

    var currentARQuestionText: String {
        guard currentARQuestionIndex < arQuestions.count else { return "" }
        return arQuestions[currentARQuestionIndex].question
    }
    
    var currentSolarLevel: SolarLevel {
        SolarLevelManager.level(for: xp)
    }
    
    func loadPlanetQuestions() {
        guard let selected = selectedPlanet else { return }

        arQuestions = questions.filter {
            $0.question.lowercased().contains(selected.rawValue.lowercased())
        }

        if arQuestions.isEmpty {
            startSolarMode() // fallback default questions
        }

        currentARQuestionIndex = 0
    }
}

extension PlanetType {
    var subject: Subject {
        return .solar
    }
}
