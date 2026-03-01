//
//  SimpleModelARView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 24/02/26.
//


//
//  SimpleModelARView.swift
//  LociLearn
//
//  Created by Sameer Nikhil on 24/02/26.
//

import SwiftUI
import ARKit
import SceneKit
import RealityKit  // kept only for SubjectPreview3D (nonAR mode, no passthrough issue)

// ─────────────────────────────────────────────
// MARK: - ARSubject Model
// ─────────────────────────────────────────────

enum ARSubject: String, CaseIterable, Identifiable {
    case biology         = "biology"
    case computerScience = "computerScience"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .biology:         return "Animal Cell"
        case .computerScience: return "Motherboard"
        }
    }

    var subjectTitle: String {
        switch self {
        case .biology:         return "Biology"
        case .computerScience: return "Computer Science"
        }
    }

    var tagline: String {
        switch self {
        case .biology:         return "Explore the building block of life"
        case .computerScience: return "The brain of every computer"
        }
    }

    var icon: String {
        switch self {
        case .biology:         return "allergens"
        case .computerScience: return "cpu.fill"
        }
    }

    var color: Color {
        switch self {
        case .biology:         return Color(red: 0.18, green: 0.78, blue: 0.45)
        case .computerScience: return Color(red: 0.18, green: 0.60, blue: 0.96)
        }
    }

    var modelFileName: String {
        switch self {
        case .biology:         return "Animalcell"
        case .computerScience: return "MotherBoard"
        }
    }

    var scaleLabel: String {
        switch self {
        case .biology:         return "~10 µm"
        case .computerScience: return "~30 cm"
        }
    }

    var scaleSubLabel: String {
        switch self {
        case .biology:         return "avg size"
        case .computerScience: return "ATX board"
        }
    }

    var stats: [(label: String, value: String)] {
        switch self {
        case .biology:
            return [("Type","Eukaryotic"), ("Organelles","13+"), ("Questions","15")]
        case .computerScience:
            return [("Form","ATX"), ("Slots","PCIe + RAM"), ("Questions","15")]
        }
    }

    var keyFacts: [(icon: String, label: String, value: String)] {
        switch self {
        case .biology:
            return [
                ("bolt.fill",          "Powerhouse",   "Mitochondria"),
                ("atom",               "Genetic Info",  "Nucleus holds DNA"),
                ("square.3.layers.3d", "Membrane",     "Controls cell entry/exit"),
            ]
        case .computerScience:
            return [
                ("cpu.fill",           "Processor",    "Hosts the CPU socket"),
                ("memorychip",         "Memory",       "RAM slots for volatile data"),
                ("bolt.fill",          "Power",        "24-pin ATX connector"),
            ]
        }
    }

    var educationSections: [EducationSection] {
        switch self {
        case .biology:
            return [
                EducationSection(id: "bio_intro",    icon: "circle.fill",       title: "What is an Animal Cell?",        body: "Animal cells are the basic structural and functional units of animal life. Unlike plant cells, they have no cell wall or chloroplasts, making them flexible in shape."),
                EducationSection(id: "bio_mito",     icon: "bolt.fill",         title: "Mitochondria — The Powerhouse",  body: "Mitochondria generate ATP through cellular respiration. A single cell can contain up to 2,000 mitochondria. They carry their own DNA."),
                EducationSection(id: "bio_nucleus",  icon: "atom",              title: "The Nucleus — Control Centre",   body: "The nucleus stores the cell's genetic blueprint — 46 chromosomes containing roughly 3 billion base pairs of DNA."),
                EducationSection(id: "bio_membrane", icon: "square.3.layers.3d",title: "Cell Membrane",                  body: "The phospholipid bilayer acts as a selective gatekeeper, regulating what enters and exits the cell."),
                EducationSection(id: "bio_golgi",    icon: "shippingbox.fill",  title: "Golgi Apparatus",                body: "Often called the cell's post office, the Golgi apparatus processes, packages, and ships proteins and lipids to their final destinations."),
            ]
        case .computerScience:
            return [
                EducationSection(id: "cs_intro",    icon: "cpu.fill",                              title: "What is a Motherboard?",       body: "The motherboard is the central PCB inside a computer. It physically connects the CPU, RAM, GPU, storage, and all peripherals."),
                EducationSection(id: "cs_ram",      icon: "memorychip",                            title: "RAM — Volatile Memory",        body: "Random Access Memory is the computer's short-term workspace. Modern systems use DDR5 RAM operating above 4800 MHz."),
                EducationSection(id: "cs_power",    icon: "bolt.fill",                             title: "Power Delivery & VRM",         body: "The motherboard receives power via the 24-pin ATX connector. The VRM converts raw power into precise voltages."),
                EducationSection(id: "cs_pcie",     icon: "point.3.connected.trianglepath.dotted", title: "PCIe Slots",                   body: "PCIe slots connect GPUs, NVMe SSDs, and expansion cards. PCIe 5.0 offers 128 GB/s bandwidth on a x16 slot."),
                EducationSection(id: "cs_chipset",  icon: "arrow.triangle.branch",                 title: "Chipset & Bus Architecture",   body: "The chipset manages data flow between CPU, RAM, and I/O, determining which CPUs and RAM speeds are supported."),
            ]
        }
    }

    var questions: [ARQuizQuestion] {
        switch self {
        case .biology:
            return [
                ARQuizQuestion("What is the powerhouse of the cell?",           ["Mitochondria","Nucleus","Ribosome","Chloroplast"], "Mitochondria"),
                ARQuizQuestion("DNA is located in which organelle?",            ["Nucleus","Ribosome","Golgi body","Lysosome"], "Nucleus"),
                ARQuizQuestion("Which organelle carries out photosynthesis?",   ["Chloroplast","Mitochondria","Vacuole","Nucleus"], "Chloroplast"),
                ARQuizQuestion("Proteins are synthesised at?",                  ["Ribosomes","Nucleus","Golgi body","Cell membrane"], "Ribosomes"),
                ARQuizQuestion("The cell membrane is mainly made of?",          ["Phospholipids","Proteins only","Carbohydrates","DNA"], "Phospholipids"),
                ARQuizQuestion("Which organelle packages and ships proteins?",  ["Golgi apparatus","Ribosome","Vacuole","Nucleus"], "Golgi apparatus"),
                ARQuizQuestion("Lysosomes contain?",                            ["Digestive enzymes","Genetic material","Chlorophyll","Water"], "Digestive enzymes"),
                ARQuizQuestion("The largest organelle in an animal cell is?",   ["Nucleus","Mitochondria","Ribosome","Vacuole"], "Nucleus"),
                ARQuizQuestion("Animal cells lack?",                            ["Cell wall","Mitochondria","Nucleus","Ribosomes"], "Cell wall"),
                ARQuizQuestion("The fluid inside the cell is called?",          ["Cytoplasm","Blood","Plasma","Lymph"], "Cytoplasm"),
                ARQuizQuestion("Which organelle produces ATP?",                 ["Mitochondria","Chloroplast","Nucleus","Vacuole"], "Mitochondria"),
                ARQuizQuestion("Cell division in body cells is?",               ["Mitosis","Meiosis","Fusion","Replication"], "Mitosis"),
                ARQuizQuestion("Which structure controls what enters/exits the cell?", ["Cell membrane","Cell wall","Nucleus","Cytoplasm"], "Cell membrane"),
                ARQuizQuestion("The endoplasmic reticulum is involved in?",     ["Protein transport","Photosynthesis","DNA replication","Energy storage"], "Protein transport"),
                ARQuizQuestion("How many chromosomes do human cells have?",     ["46","23","44","48"], "46"),
            ]
        case .computerScience:
            return [
                ARQuizQuestion("What does CPU stand for?",                  ["Central Processing Unit","Core Program Utility","Computer Power Unit","Central Protocol Unit"], "Central Processing Unit"),
                ARQuizQuestion("Which language is primarily used for iOS?", ["Swift","Java","Python","C#"], "Swift"),
                ARQuizQuestion("Binary numbers use which digits?",          ["0 and 1","1 and 2","0–9","A and B"], "0 and 1"),
                ARQuizQuestion("RAM stands for?",                           ["Random Access Memory","Read All Memory","Run Active Module","Rapid Access Module"], "Random Access Memory"),
                ARQuizQuestion("Which data structure uses FIFO?",           ["Queue","Stack","Tree","Graph"], "Queue"),
                ARQuizQuestion("Which data structure uses LIFO?",           ["Stack","Queue","Array","Graph"], "Stack"),
                ARQuizQuestion("Which protocol is used for websites?",      ["HTTP","FTP","SMTP","SSH"], "HTTP"),
                ARQuizQuestion("AI stands for?",                            ["Artificial Intelligence","Automated Input","Advanced Internet","Algorithmic Interface"], "Artificial Intelligence"),
                ARQuizQuestion("Which company created Swift?",              ["Apple","Google","Microsoft","IBM"], "Apple"),
                ARQuizQuestion("Git is used for?",                          ["Version Control","Image Editing","Video Processing","Hardware Testing"], "Version Control"),
                ARQuizQuestion("What does API stand for?",                  ["Application Programming Interface","Applied Protocol Interface","Automated Program Input","Advanced Processor Interface"], "Application Programming Interface"),
                ARQuizQuestion("Machine Learning is a subset of?",          ["Artificial Intelligence","Web Design","Cybersecurity","Databases"], "Artificial Intelligence"),
                ARQuizQuestion("Which symbol starts a comment in Swift?",   ["//","##","--","**"], "//"),
                ARQuizQuestion("Which sorting algorithm is fastest on average?", ["QuickSort","Bubble Sort","Selection Sort","Insertion Sort"], "QuickSort"),
                ARQuizQuestion("The motherboard connects to storage via?",  ["SATA / NVMe","USB only","Bluetooth","Ethernet"], "SATA / NVMe"),
            ]
        }
    }
}

struct EducationSection: Identifiable {
    let id: String
    let icon: String
    let title: String
    let body: String
}

struct ARQuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: String
    init(_ q: String, _ opts: [String], _ ans: String) {
        question = q; options = opts; correctAnswer = ans
    }
}

// ─────────────────────────────────────────────
// MARK: - Subject Selection View
// ─────────────────────────────────────────────

struct SubjectSelectionView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            AppBackgroundView()
            StarFieldBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().fill(Color.brand.opacity(0.15)).frame(width: 76, height: 76)
                            Circle().strokeBorder(Color.brand.opacity(0.28), lineWidth: 1).frame(width: 76, height: 76)
                            Image(systemName: "arkit")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(Color.brand)
                        }
                        Text("Choose a Subject")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Select a model to begin your AR journey.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSub)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60).padding(.bottom, 4)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : -16)
                    .animation(.spring(response: 0.65, dampingFraction: 0.80).delay(0.05), value: appeared)

                    VStack(spacing: 12) {
                        ForEach(Array(ARSubject.allCases.enumerated()), id: \.element) { i, subject in
                            NavigationLink(destination: SubjectLearnView(subject: subject)) {
                                SubjectTile(subject: subject)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .opacity(appeared ? 1 : 0).offset(x: appeared ? 0 : 24)
                            .animation(.spring(response: 0.55, dampingFraction: 0.78)
                                .delay(0.20 + Double(i) * 0.09), value: appeared)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { appeared = true }
    }
}

struct SubjectTile: View {
    let subject: ARSubject

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(subject.color.opacity(0.18)).frame(width: 56, height: 56)
                Circle().strokeBorder(subject.color.opacity(0.40), lineWidth: 1).frame(width: 56, height: 56)
                Image(systemName: subject.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(subject.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.displayName)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subject.tagline)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSub)
                    .lineLimit(1)
            }
            Spacer()
            VStack(spacing: 2) {
                Text(subject.scaleLabel)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(subject.color)
                Text(subject.scaleSubLabel)
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
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(subject.color.opacity(0.20), lineWidth: 1))
        )
    }
}

// ─────────────────────────────────────────────
// MARK: - Subject Learn View
// ─────────────────────────────────────────────

struct SubjectLearnView: View {
    let subject: ARSubject
    @State private var appeared     = false
    @State private var navigateToAR = false
    @State private var expanded: Set<String> = []

    var body: some View {
        ZStack {
            AppBackgroundView()
            StarFieldBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    SubjectHeroCard(subject: subject)
                        .padding(.horizontal, 20).padding(.top, 20)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : -12)
                        .animation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.05), value: appeared)

                    VStack(spacing: 6) {
                        Text(subject.displayName)
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(subject.tagline)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSub)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20).padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 10)
                    .animation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.14), value: appeared)

                    HStack(spacing: 10) {
                        ForEach(subject.stats.indices, id: \.self) { i in
                            SubjectStatChip(label: subject.stats[i].label,
                                            value: subject.stats[i].value,
                                            color: subject.color)
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 18)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)
                    .animation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.22), value: appeared)

                    VStack(spacing: 0) {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 10, weight: .bold)).foregroundStyle(subject.color)
                            Text("KEY FACTS")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.textMuted).kerning(0.9)
                            Spacer()
                        }
                        .padding(.horizontal, 18).padding(.top, 16).padding(.bottom, 14)
                        RowDivider()
                        ForEach(subject.keyFacts.indices, id: \.self) { i in
                            SubjectFactRow(icon: subject.keyFacts[i].icon,
                                           label: subject.keyFacts[i].label,
                                           value: subject.keyFacts[i].value,
                                           color: subject.color, index: i, appeared: appeared)
                            if i < subject.keyFacts.count - 1 { RowDivider() }
                        }
                    }
                    .cardStyle(radius: 22)
                    .padding(.horizontal, 20).padding(.top, 20)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
                    .animation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.30), value: appeared)

                    VStack(spacing: 0) {
                        HStack(spacing: 6) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 10, weight: .bold)).foregroundStyle(subject.color)
                            Text("STUDY \(subject.displayName.uppercased())")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.textMuted).kerning(0.9)
                            Spacer()
                            Text("\(subject.educationSections.count) topics")
                                .font(.system(size: 10)).foregroundStyle(Color.textMuted)
                        }
                        .padding(.horizontal, 18).padding(.top, 16).padding(.bottom, 14)
                        RowDivider()
                        ForEach(subject.educationSections) { section in
                            EducationRow(section: section, color: subject.color,
                                         isExpanded: expanded.contains(section.id)) {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.80)) {
                                    if expanded.contains(section.id) { expanded.remove(section.id) }
                                    else { expanded.insert(section.id) }
                                }
                            }
                            if section.id != subject.educationSections.last?.id { RowDivider() }
                        }
                    }
                    .cardStyle(radius: 22)
                    .padding(.horizontal, 20).padding(.top, 16)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 18)
                    .animation(.spring(response: 0.60, dampingFraction: 0.80).delay(0.38), value: appeared)

                    Button { navigateToAR = true } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arkit").font(.system(size: 16, weight: .bold))
                            Text("View \(subject.displayName) in AR")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Spacer()
                            Image(systemName: "arrow.right").font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22).frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(subject.color)
                                .shadow(color: subject.color.opacity(0.45), radius: 16, y: 6)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 14)
                    .animation(.spring(response: 0.65, dampingFraction: 0.80).delay(0.46), value: appeared)

                    NavigationLink(destination: SubjectARScreen2(subject: subject),
                                   isActive: $navigateToAR) { EmptyView() }
                }
            }
        }
        .navigationTitle(subject.subjectTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { appeared = true }
    }
}

// ─────────────────────────────────────────────
// MARK: - Subject Hero Card
// ─────────────────────────────────────────────

struct SubjectHeroCard: View {
    let subject: ARSubject

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(
                    colors: [subject.color.opacity(0.35), subject.color.opacity(0.08)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 200)
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(subject.color.opacity(0.30), lineWidth: 1))

            Image(systemName: subject.icon)
                .font(.system(size: 110, weight: .thin))
                .foregroundStyle(subject.color.opacity(0.12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(.trailing, 24)

            SubjectPreview3D(subject: subject)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: subject.icon)
                        .font(.system(size: 11, weight: .bold)).foregroundStyle(subject.color)
                    Text(subject.displayName.uppercased())
                        .font(.system(size: 10, weight: .bold)).foregroundStyle(subject.color).kerning(0.8)
                }
                Text("Drag to rotate").font(.system(size: 10)).foregroundStyle(Color.textMuted)
            }
            .padding(14)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// ─────────────────────────────────────────────
// MARK: - Education Row
// ─────────────────────────────────────────────

struct EducationRow: View {
    let section: EducationSection
    let color: Color
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(0.15)).frame(width: 38, height: 38)
                    Image(systemName: section.icon)
                        .font(.system(size: 15, weight: .medium)).foregroundStyle(color)
                }
                Text(section.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white).multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .bold)).foregroundStyle(Color.textSub)
                    .animation(.spring(response: 0.3), value: isExpanded)
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            if isExpanded {
                Text(section.body)
                    .font(.system(size: 13)).foregroundStyle(Color.textSub).lineSpacing(5)
                    .padding(.horizontal, 18).padding(.bottom, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Subject Stat Chip
// ─────────────────────────────────────────────

struct SubjectStatChip: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 15, weight: .black, design: .rounded)).foregroundStyle(color)
            Text(label).font(.system(size: 10, weight: .medium)).foregroundStyle(Color.textMuted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.surface1)
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(color.opacity(0.20), lineWidth: 1))
        )
    }
}

// ─────────────────────────────────────────────
// MARK: - Subject Fact Row
// ─────────────────────────────────────────────

struct SubjectFactRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let index: Int
    let appeared: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.15)).frame(width: 38, height: 38)
                Image(systemName: icon).font(.system(size: 15, weight: .medium)).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.textMuted).kerning(0.5).textCase(.uppercase)
                Text(value)
                    .font(.system(size: 14, weight: .medium, design: .rounded)).foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
        .opacity(appeared ? 1 : 0).offset(x: appeared ? 0 : -16)
        .animation(.spring(response: 0.55, dampingFraction: 0.78)
            .delay(0.38 + Double(index) * 0.07), value: appeared)
    }
}

// ─────────────────────────────────────────────
// MARK: - Subject 3D Preview (nonAR — no passthrough, no black screen)
// ─────────────────────────────────────────────

struct SubjectPreview3D: UIViewRepresentable {
    let subject: ARSubject

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        arView.backgroundColor = .clear
        arView.environment.background = .color(.clear)

        let anchor = AnchorEntity(world: .zero)
        arView.scene.addAnchor(anchor)

        Task {
            do {
                let rawModel = try await ModelEntity(named: subject.modelFileName)
                rawModel.generateCollisionShapes(recursive: true)
                let container = Entity()
                container.addChild(rawModel)
                anchor.addChild(container)
                context.coordinator.container = container

                try? await Task.sleep(nanoseconds: 300_000_000)

                let bounds = container.visualBounds(relativeTo: anchor)
                let maxDim = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
                if maxDim > 0 {
                    let scale = Float(2.5) / maxDim
                    container.scale = SIMD3<Float>(repeating: scale)
                }
                let cb = container.visualBounds(relativeTo: anchor)
                container.position = -cb.center
            } catch {
                print("❌ Model load error:", error)
            }
        }

        let pan = UIPanGestureRecognizer(target: context.coordinator,
                                          action: #selector(Coordinator.handlePan(_:)))
        arView.addGestureRecognizer(pan)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    class Coordinator: NSObject {
        weak var container: Entity?
        private var rotationX: Float = 0
        private var rotationY: Float = 0

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let container = container else { return }
            let translation = gesture.translation(in: gesture.view)
            gesture.setTranslation(.zero, in: gesture.view)
            let sensitivity: Float = 0.005
            rotationY += Float(translation.x) * sensitivity
            rotationX += Float(translation.y) * sensitivity
            rotationX = max(-.pi/2, min(.pi/2, rotationX))
            let xQuat = simd_quatf(angle: rotationX, axis: [1, 0, 0])
            let yQuat = simd_quatf(angle: rotationY, axis: [0, 1, 0])
            container.transform.rotation = yQuat * xQuat
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Subject AR Screen (fixed — ARSCNView, same card style as ARPalaceView)
// ─────────────────────────────────────────────

struct SubjectARScreen2: View {
    let subject: ARSubject

    @State private var questions: [ARQuizQuestion] = []
    @State private var currentIndex    = 0
    @State private var selectedAnswer: String? = nil
    @State private var score           = 0
    @State private var appeared        = false
    @State private var showComplete    = false
    @State private var isCardFlipped   = false
    @State private var placeCardTrigger = false
    @State private var showHistory = false
    @State private var questionResults: [ARQuizResult] = []
    @State private var cardPlaced = false
    
    private var current: ARQuizQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var body: some View {
        ZStack {
            // ── AR Camera (ARSCNView — no RealityKit, no black screen) ──
            SubjectARSceneContainer(
                subject: subject,
                questions: questions,
                currentIndex: currentIndex,
                isCardFlipped: $isCardFlipped,
                placeCardTrigger: $placeCardTrigger
            )
            .ignoresSafeArea()

            // ── HUD ──
            VStack {
                HStack(alignment: .center, spacing: 12) {

                    // Place card button
                    Button {
                        placeCardTrigger.toggle()
                        cardPlaced = true
                    } label: {
                        ZStack {
                            Circle().fill(.ultraThinMaterial).frame(width: 52, height: 52)
                                .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold)).foregroundStyle(.white)
                        }
                    }

                    Spacer()

                    // History button
                    Button { showHistory = true } label: {
                        ZStack {
                            Circle().fill(.ultraThinMaterial).frame(width: 44, height: 44)
                                .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        }
                    }

                    // Score + Q pill
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill").font(.caption).foregroundStyle(.yellow)
                        Text("\(score) pts").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                        Text("·").foregroundStyle(.white.opacity(0.5))
                        Text("Q\(currentIndex+1)/\(max(1,questions.count))")
                            .font(.system(size: 12, weight: .semibold)).foregroundStyle(.white.opacity(0.80))
                    }
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(.ultraThinMaterial).clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
                }
                .padding(.horizontal, 20).padding(.top, 12)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(.white.opacity(0.20)).frame(height: 3)
                        Rectangle()
                            .fill(LinearGradient(colors: [subject.color, subject.color.opacity(0.60)],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * arProgress, height: 3)
                            .animation(.spring(response: 0.5), value: arProgress)
                    }
                }
                .frame(height: 3).padding(.horizontal, 20).padding(.top, 6)

                Spacer()

                // Bottom hint (before card is placed)
                if !isCardFlipped {
                    HStack(spacing: 8) {
                        Image(systemName: cardPlaced ? "hand.tap.fill" : "plus.circle.fill")
                            .font(.caption)
                        Text(cardPlaced ? "Tap the card to reveal answers" : "Tap + to place your question card")
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 16).padding(.vertical, 9)
                    .background(.ultraThinMaterial).clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 8)
                    .padding(.bottom, 28)
                    .animation(.easeInOut(duration: 0.3), value: cardPlaced)
                }
            }

            // ── Options sheet (same style as ARPalaceView's OptionsOverlay) ──
            if isCardFlipped, let question = current {
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 0) {
                        // Drag handle
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 38, height: 5)
                            .padding(.top, 10).padding(.bottom, 6)

                        // Subject label + score
                        HStack(spacing: 6) {
                            Image(systemName: subject.icon)
                                .font(.system(size: 11, weight: .bold)).foregroundStyle(subject.color)
                            Text(subject.displayName.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.textMuted).kerning(1.0)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill").font(.system(size: 9)).foregroundStyle(.yellow)
                                Text("\(score) pts").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 18).padding(.top, 8)

                        // Progress pills
                        HStack(spacing: 5) {
                            ForEach(0..<questions.count, id: \.self) { i in
                                Capsule()
                                    .fill(i < currentIndex
                                          ? subject.color
                                          : (i == currentIndex
                                             ? subject.color.opacity(0.60)
                                             : Color.white.opacity(0.12)))
                                    .frame(maxWidth: .infinity).frame(height: 3)
                            }
                        }
                        .padding(.horizontal, 18).padding(.top, 10).padding(.bottom, 14)

                        RowDivider()

                        // Question
                        Text(question.question)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white).multilineTextAlignment(.center).lineSpacing(3)
                            .padding(.horizontal, 20).padding(.vertical, 16)

                        RowDivider()

                        // Answer options
                        VStack(spacing: 8) {
                            ForEach(Array(question.options.enumerated()), id: \.offset) { i, option in
                                ARSubjectAnswerButton(
                                    option: option, index: i, color: subject.color,
                                    selectedAnswer: selectedAnswer,
                                    correctAnswer: question.correctAnswer,
                                    appeared: appeared
                                ) {
                                    guard selectedAnswer == nil else { return }
                                    selectedAnswer = option
                                    if option == question.correctAnswer {
                                        score += 20
                                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                                    } else {
                                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                                    }
                                    let result = ARQuizResult(
                                        id: UUID(),
                                        question: question.question,
                                        selectedAnswer: option,
                                        correctAnswer: question.correctAnswer
                                    )
                                    questionResults.append(result)
                                }
                            }
                        }
                        .padding(.horizontal, 16).padding(.top, 12)

                        // Next / Finish
                        Button {
                            if currentIndex < questions.count - 1 {
                                currentIndex += 1
                                selectedAnswer = nil
                                isCardFlipped = false
                                cardPlaced = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    placeCardTrigger.toggle()
                                    cardPlaced = true
                                }
                            } else {
                                saveHistory()
                                showComplete = true
                            }
                        } label: {                            HStack(spacing: 8) {
                                Text(currentIndex < questions.count - 1 ? "Next Question" : "Finish")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                Image(systemName: currentIndex < questions.count - 1 ? "arrow.right" : "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity).frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(subject.color)
                                    .shadow(color: subject.color.opacity(0.40), radius: 12, y: 4)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.horizontal, 16).padding(.top, 10)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                        Spacer().frame(height: 20)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.surface1)
                            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(subject.color.opacity(0.25), lineWidth: 1))
                            .shadow(color: .black.opacity(0.55), radius: 32, y: -10)
                    )
                    .padding(.horizontal, 16).padding(.bottom, 36)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCardFlipped)
            }
        }
        .navigationTitle(subject.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            questions = subject.questions.shuffled().map { q in
                ARQuizQuestion(q.question, q.options.shuffled(), q.correctAnswer)
            }
            currentIndex = 0
            selectedAnswer = nil
            score = 0
            questionResults = []
            cardPlaced = false
            withAnimation { appeared = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                placeCardTrigger.toggle()
                cardPlaced = true
            }
        }
        .sheet(isPresented: $showComplete) {
            ARQuizCompleteSheet(subject: subject, score: score, total: questions.count)
        }
        .sheet(isPresented: $showHistory) {
            ARHistoryView(accentColor: subject.color)
        }
    }

    private var arProgress: Double {
        let n = questions.count
        guard n > 0 else { return 0 }
        return Double(currentIndex) / Double(n)
    }
    
    private func saveHistory() {
        let entry = ARQuizHistoryEntry(
            id: UUID(),
            subjectName: subject.displayName,
            score: score,
            total: questions.count,
            date: Date(),
            questionResults: questionResults
        )
        ARHistoryView.save(entry: entry)
    }
}

// ─────────────────────────────────────────────
// MARK: - Subject AR Scene Container (ARSCNView)
// ─────────────────────────────────────────────

struct SubjectARSceneContainer: UIViewControllerRepresentable {

    let subject: ARSubject
    let questions: [ARQuizQuestion]
    let currentIndex: Int
    @Binding var isCardFlipped: Bool
    @Binding var placeCardTrigger: Bool

    func makeUIViewController(context: Context) -> SubjectARSceneVC {
        let vc = SubjectARSceneVC()
        vc.subject      = subject
        vc.onCardTapped = { isCardFlipped = true }
        return vc
    }

    func updateUIViewController(_ vc: SubjectARSceneVC, context: Context) {
        vc.questions     = questions
        vc.currentIndex  = currentIndex
        vc.onCardTapped  = { isCardFlipped = true }

        if placeCardTrigger != vc.lastPlaceTrigger {
            vc.lastPlaceTrigger = placeCardTrigger
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                vc.placeCard()
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    class Coordinator: NSObject {}
}

// ─────────────────────────────────────────────
// MARK: - Subject AR Scene VC
// ─────────────────────────────────────────────

class SubjectARSceneVC: UIViewController, ARSCNViewDelegate {

    var subject: ARSubject?
    var questions: [ARQuizQuestion] = []
    var currentIndex: Int = 0
    var onCardTapped: (() -> Void)?
    var lastPlaceTrigger: Bool = false

    private var sceneView: ARSCNView!
    private var cardNode: SCNNode?
    private var model3DNode: SCNNode?
    private var sessionStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !sessionStarted, view.bounds.width > 0 else { return }
        sessionStarted = true

        sceneView = ARSCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.antialiasingMode = .multisampling4X
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

    // MARK: - Place Card + 3D Model

    func placeCard() {
        guard let sceneView = sceneView,
              let frame = sceneView.session.currentFrame else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.placeCard() }
            return
        }

        // Remove old nodes
        cardNode?.removeFromParentNode()
        model3DNode?.removeFromParentNode()

        let camTransform = frame.camera.transform
        let camPos = SIMD3<Float>(camTransform.columns.3.x,
                                  camTransform.columns.3.y,
                                  camTransform.columns.3.z)
        let rawFwd = SIMD3<Float>(-camTransform.columns.2.x, 0, -camTransform.columns.2.z)
        let fwd    = simd_length(rawFwd) > 0.001 ? simd_normalize(rawFwd) : SIMD3<Float>(0, 0, -1)
        let yaw    = atan2(fwd.x, fwd.z)

        // ── Place question card ──
        if questions.indices.contains(currentIndex) {
            let q     = questions[currentIndex]
            let node  = makeCardNode(question: q.question, qNum: currentIndex + 1, total: questions.count)
            node.position = SCNVector3(camPos.x + fwd.x * 1.1,
                                       camPos.y + 0.05,
                                       camPos.z + fwd.z * 1.1)
            node.eulerAngles.y = yaw
            sceneView.scene.rootNode.addChildNode(node)
            cardNode = node
        }
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
        DispatchQueue.main.async { self.onCardTapped?() }
    }

    // MARK: - Build Card Node (same purple gradient design as ARPalaceView)

    private func makeCardNode(question: String, qNum: Int, total: Int) -> SCNNode {
        let W: CGFloat = 0.60
        let H: CGFloat = 0.42
        let image = renderCardImage(question: question, qNum: qNum, total: total)

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
            para.alignment = .center; para.lineSpacing = 6
            NSAttributedString(string: question, attributes: [
                .font: UIFont.systemFont(ofSize: 42, weight: .semibold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: para
            ]).draw(in: CGRect(x: 60, y: 110, width: size.width - 120, height: size.height - 200))

            let hint = NSAttributedString(
                string: "✦  tap to reveal answers  ✦",
                attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium),
                             .foregroundColor: UIColor(red:0.80,green:0.70,blue:1,alpha:0.60)])
            let hs = hint.size()
            hint.draw(at: CGPoint(x: (size.width - hs.width)/2, y: size.height - 60))
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Answer Button
// ─────────────────────────────────────────────

struct ARSubjectAnswerButton: View {
    let option: String
    let index: Int
    let color: Color
    let selectedAnswer: String?
    let correctAnswer: String
    let appeared: Bool
    let action: () -> Void

    private let labels = ["A","B","C","D"]
    private enum BState { case idle, correct, wrong, dimmed }

    private var state: BState {
        guard let sel = selectedAnswer else { return .idle }
        if option == correctAnswer { return .correct }
        if option == sel           { return .wrong }
        return .dimmed
    }
    private var bgColor: Color {
        switch state {
        case .idle:    return Color.surface2
        case .correct: return Color(red:0.18,green:0.78,blue:0.45).opacity(0.25)
        case .wrong:   return Color(red:0.90,green:0.30,blue:0.25).opacity(0.25)
        case .dimmed:  return Color.surface2.opacity(0.50)
        }
    }
    private var borderColor: Color {
        switch state {
        case .idle:    return Color.white.opacity(0.07)
        case .correct: return Color(red:0.18,green:0.78,blue:0.45).opacity(0.60)
        case .wrong:   return Color(red:0.90,green:0.30,blue:0.25).opacity(0.60)
        case .dimmed:  return Color.white.opacity(0.04)
        }
    }
    private var badgeColor: Color {
        switch state {
        case .idle:    return color
        case .correct: return Color(red:0.18,green:0.78,blue:0.45)
        case .wrong:   return Color(red:0.90,green:0.30,blue:0.25)
        case .dimmed:  return Color.textMuted
        }
    }

    var body: some View {
        Button(action: action) {
            // ✅ WITH:
            HStack(spacing: 12) {
                // Badge — fixed size, never grows
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(badgeColor.opacity(0.18))
                        .frame(width: 30, height: 30)
                    if state == .correct {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .black)).foregroundStyle(badgeColor)
                    } else if state == .wrong {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .black)).foregroundStyle(badgeColor)
                    } else {
                        Text(index < labels.count ? labels[index] : "")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(badgeColor)
                    }
                }
                .fixedSize()

                // Option text — takes remaining space, wraps naturally
                Text(option)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(state == .dimmed ? Color.textSub : .white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Chevron — fixed, never grows
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(state == .dimmed ? Color.textMuted : Color.textSub)
                    .fixedSize()
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius:14,style:.continuous)
                    .fill(bgColor)
                    .overlay(RoundedRectangle(cornerRadius:14,style:.continuous)
                        .strokeBorder(borderColor,lineWidth:1))
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(selectedAnswer != nil)
        .opacity(appeared ? 1 : 0).offset(x: appeared ? 0 : 20)
        .animation(.spring(response:0.50,dampingFraction:0.78)
            .delay(0.20 + Double(index) * 0.07), value: appeared)
    }
}

// ─────────────────────────────────────────────
// MARK: - Quiz Complete Sheet
// ─────────────────────────────────────────────

struct ARQuizCompleteSheet: View {
    @Environment(\.dismiss) var dismiss
    let subject: ARSubject
    let score: Int
    let total: Int

    private var percentage: Int { total > 0 ? Int((Double(score)/Double(total*20))*100) : 0 }
    private var emoji: String { percentage >= 80 ? "🏆" : percentage >= 50 ? "⭐️" : "💪" }

    var body: some View {
        ZStack {
            Color.surface0.ignoresSafeArea()
            StarFieldBackground()
            VStack(spacing: 28) {
                Spacer()
                Text(emoji).font(.system(size: 64))
                VStack(spacing: 8) {
                    Text("Quiz Complete!")
                        .font(.system(size:28,weight:.black,design:.rounded)).foregroundStyle(.white)
                    Text(subject.displayName).font(.system(size:14)).foregroundStyle(Color.textSub)
                }
                HStack {
                    VStack(spacing: 4) {
                        Text("\(score)")
                            .font(.system(size:36,weight:.black,design:.rounded)).foregroundStyle(subject.color)
                        Text("Points Earned").font(.system(size:11,weight:.medium)).foregroundStyle(Color.textMuted)
                    }.frame(maxWidth: .infinity)
                    Rectangle().fill(Color.white.opacity(0.07)).frame(width:1,height:50)
                    VStack(spacing: 4) {
                        Text("\(percentage)%")
                            .font(.system(size:36,weight:.black,design:.rounded)).foregroundStyle(subject.color)
                        Text("Accuracy").font(.system(size:11,weight:.medium)).foregroundStyle(Color.textMuted)
                    }.frame(maxWidth: .infinity)
                }
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius:22,style:.continuous).fill(Color.surface1)
                        .overlay(RoundedRectangle(cornerRadius:22,style:.continuous)
                            .strokeBorder(subject.color.opacity(0.22),lineWidth:1))
                )
                .padding(.horizontal, 24)
                Spacer()
                Button { dismiss() } label: {
                    Text("Done")
                        .font(.system(size:16,weight:.semibold,design:.rounded)).foregroundStyle(.white)
                        .frame(maxWidth:.infinity).frame(height:54)
                        .background(RoundedRectangle(cornerRadius:16,style:.continuous)
                            .fill(subject.color).shadow(color:subject.color.opacity(0.40),radius:16,y:6))
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal,24).padding(.bottom,40)
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Previews
// ─────────────────────────────────────────────

#Preview("Selection")     { NavigationStack { SubjectSelectionView() } }
#Preview("Biology Learn") { NavigationStack { SubjectLearnView(subject: .biology) } }
#Preview("CS Learn")      { NavigationStack { SubjectLearnView(subject: .computerScience) } }

// ─────────────────────────────────────────────
// MARK: - AR Quiz History
// ─────────────────────────────────────────────

struct ARQuizHistoryEntry: Identifiable, Codable {
    let id: UUID
    let subjectName: String
    let score: Int
    let total: Int
    let date: Date
    let questionResults: [ARQuizResult]

    var percentage: Int { total > 0 ? Int((Double(score) / Double(total * 20)) * 100) : 0 }
    var emoji: String { percentage >= 80 ? "🏆" : percentage >= 50 ? "⭐️" : "💪" }
}

struct ARQuizResult: Identifiable, Codable {
    let id: UUID
    let question: String
    let selectedAnswer: String
    let correctAnswer: String
    var isCorrect: Bool { selectedAnswer == correctAnswer }
}

struct ARHistoryView: View {
    @Environment(\.dismiss) var dismiss
    let accentColor: Color

    @State private var entries: [ARQuizHistoryEntry] = []
    @State private var expandedEntry: UUID? = nil

    var body: some View {
        ZStack {
            Color.surface0.ignoresSafeArea()
            StarFieldBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Quiz History")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.textSub)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

                if entries.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.textMuted)
                        Text("No history yet")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textMuted)
                        Text("Complete a quiz to see your results here.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(entries) { entry in
                                VStack(spacing: 0) {

                                    // ── Entry Header Row ──
                                    Button {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            expandedEntry = expandedEntry == entry.id ? nil : entry.id
                                        }
                                    } label: {
                                        HStack(spacing: 14) {
                                            Text(entry.emoji)
                                                .font(.system(size: 28))
                                                .frame(width: 48, height: 48)
                                                .background(accentColor.opacity(0.12))
                                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(entry.subjectName)
                                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.white)
                                                Text(entry.date, style: .date)
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(Color.textMuted)
                                            }

                                            Spacer()

                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("\(entry.score) pts")
                                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                                    .foregroundStyle(accentColor)
                                                Text("\(entry.percentage)%")
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundStyle(Color.textMuted)
                                            }

                                            Image(systemName: expandedEntry == entry.id ? "chevron.up" : "chevron.down")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundStyle(Color.textMuted)
                                        }
                                        .padding(14)
                                    }
                                    .buttonStyle(.plain)

                                    // ── Expanded Question Results ──
                                    if expandedEntry == entry.id {
                                        VStack(spacing: 0) {
                                            Rectangle()
                                                .fill(Color.white.opacity(0.06))
                                                .frame(height: 1)
                                                .padding(.horizontal, 14)

                                            VStack(spacing: 8) {
                                                ForEach(entry.questionResults) { result in
                                                    HStack(alignment: .top, spacing: 10) {
                                                        // Correct / Wrong icon
                                                        Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                            .font(.system(size: 16))
                                                            .foregroundStyle(result.isCorrect ? Color.success : Color.danger)
                                                            .frame(width: 20)
                                                            .padding(.top, 1)

                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(result.question)
                                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.white)
                                                                .fixedSize(horizontal: false, vertical: true)

                                                            if !result.isCorrect {
                                                                HStack(spacing: 4) {
                                                                    Text("Your answer:")
                                                                        .font(.system(size: 10))
                                                                        .foregroundStyle(Color.textMuted)
                                                                    Text(result.selectedAnswer)
                                                                        .font(.system(size: 10, weight: .semibold))
                                                                        .foregroundStyle(Color.danger)
                                                                }
                                                                HStack(spacing: 4) {
                                                                    Text("Correct:")
                                                                        .font(.system(size: 10))
                                                                        .foregroundStyle(Color.textMuted)
                                                                    Text(result.correctAnswer)
                                                                        .font(.system(size: 10, weight: .semibold))
                                                                        .foregroundStyle(Color.success)
                                                                }
                                                            } else {
                                                                Text(result.correctAnswer)
                                                                    .font(.system(size: 10, weight: .semibold))
                                                                    .foregroundStyle(Color.success)
                                                            }
                                                        }
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .fill(result.isCorrect ? Color.success.opacity(0.07) : Color.danger.opacity(0.07))
                                                    )
                                                }
                                            }
                                            .padding(12)
                                        }
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.surface1)
                                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(accentColor.opacity(0.18), lineWidth: 1))
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear { loadHistory() }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "arQuizHistory"),
           let decoded = try? JSONDecoder().decode([ARQuizHistoryEntry].self, from: data) {
            entries = decoded.sorted { $0.date > $1.date }
        }
    }

    static func save(entry: ARQuizHistoryEntry) {
        var all: [ARQuizHistoryEntry] = []
        if let data = UserDefaults.standard.data(forKey: "arQuizHistory"),
           let decoded = try? JSONDecoder().decode([ARQuizHistoryEntry].self, from: data) {
            all = decoded
        }
        all.append(entry)
        if let encoded = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(encoded, forKey: "arQuizHistory")
        }
    }
}
