//
//  Greenhouse.swift
//  GreenhouseStudyBuddy
//
//  Created by Madison Cavill on 2025-09-07.
//

import SwiftUI
import Foundation


struct Plant: Identifiable, Codable, Equatable {
    let id: UUID
    var type: PlantType // which kind of plant
    var stage: Int // growth stage
    
    init(id: UUID = UUID(), type: PlantType = .random, stage: Int = 0) {
        self.id = id
        self.type = type
        self.stage = stage
    }
}

enum PlantType: String, CaseIterable, Codable {
    case sunflower, cactus, vine, herb
    static var random: PlantType {PlantType.allCases.randomElement()!}
    
    var displayName: String {
        switch self {
        case .sunflower: return "SunFlower"
        case .cactus: return "Cactus"
        case .vine: return "Vine"
        case .herb: return "Herb"
        }
    }
    
    var emojiStages: [String] {
        switch self {
        case .sunflower: return ["🌱", "🌿", "🌻", "🌻"]
        case .cactus: return ["🌵", "🌵", "🌵", "🌵"]
        case .vine: return ["🌱", "🌿", "🪴", "🌺"]
        case .herb: return ["🌿", "🌿", "🌿", "🪴"]
        }
    }
}

final class Greenhouse: ObservableObject {
    @Published var plants: [Plant] = [] {didSet { save() }}
    @AppStorage("flowersTotal") var flowersTotal: Int = 0
    
    private let saveURL: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("GreenhouseStudyBuddy", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("greenhouse.json")
    }()
    
    init() {
        load()
        if plants.isEmpty {
            plants = [Plant(), Plant(), Plant()]
        }
        
        NotificationCenter.default.addObserver(
            forName: .workSessionComplete,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            self?.growOne()}
    }
    
    func growOne() {
        if let i = plants.firstIndex(where: {$0.stage < 3}) {
            plants[i].stage += 1
            if plants[i].stage == 3 {flowersTotal += 1} //count bloom achievement
        } else {
            plants.append(Plant())
        }
    }
    
    func resetAll() {
        plants = plants.map { Plant(type: $0.type, stage: 0)}
    }
    
    func change(_ plant: Plant, to type: PlantType) {
        if let i = plants.firstIndex(of: plant) {
            plants[i].type = type
            plants[i].stage = 0
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(plants) {
            try? data.write(to: saveURL, options: .atomic)
        }
    }
    
    private func load() {
        guard
            let data = try? Data(contentsOf: saveURL),
            let decoded = try? JSONDecoder().decode([Plant].self, from: data)
        else { return }
        plants = decoded
    }
}
