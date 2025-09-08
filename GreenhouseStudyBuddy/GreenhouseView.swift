//
//  GreenhouseView.swift
//  GreenhouseStudyBuddy
//
//  Created by Madison Cavill on 2025-09-07.
//


import SwiftUI

//// MARK: - Cross-platform helper
//private var tileFillColor: Color {
//    #if canImport(UIKit)
//    return Color(UIColor.secondarySystemBackground)
//    #elseif canImport(AppKit)
//    return Color(NSColor.windowBackgroundColor)
//    #else
//    return Color.gray.opacity(0.12)
//    #endif
//}
//
//struct GreenhouseView: View {
//    @EnvironmentObject var greenhouse: Greenhouse
//    @State private var showPickerFor: Plant?
//
//    // Split columns out so the compiler breathes easier
//    private let gridCols = Array(repeating: GridItem(.flexible(minimum: 12)), count: 3)
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Your Greenhouse")
//                .font(.title3).bold()
//
//            Text("Flowers grown so far: \(greenhouse.flowersTotal)")
//                .font(.footnote)
//                .foregroundStyle(.secondary)
//
//            ScrollView {
//                LazyVGrid(columns: gridCols) {
//                    ForEach(greenhouse.plants) { plant in
//                        PlantTile(plant: plant)
//                            .onTapGesture {
//                                showPickerFor = plant
//                            }
//                            .contextMenu {
//                                Button("Reset to seed") {
//                                    greenhouse.change(plant, to: plant.type)
//                                }
//                                Menu("Change plant type") {
//                                    ForEach(PlantType.allCases, id: \.self) { t in
//                                        Button(t.displayName) {
//                                            greenhouse.change(plant, to: t)
//                                        }
//                                    }
//                                }
//                            }
//                    }
//                }
//                .padding(.top, 6)
//
//                // buttons below
//                HStack {
//                    Button("Reset all to seeds") {
//                        greenhouse.resetPlants()
//                    }
//                    Spacer()
//                    Button {
//                        greenhouse.plants.append(Plant())
//                    } label: {
//                        Label("Add pot", systemImage: "plus.circle.fill")
//                    }
//                }
//            }
//            .padding()
//            .sheet(item: $showPickerFor) { plant in
//                PlantPicker(plant: plant)
//                    .environmentObject(greenhouse)
//            }
//        }
//        .padding()
//    }
//}
//
//struct PlantTile: View {
//    let plant: Plant
//    @State private var bounce = false
//
//    // Pull the emoji computation out (helps type-checker)
//    private var emojiForStage: String {
//        let arr = plant.type.emojiStages
//        return arr[min(plant.stage, arr.count - 1)]
//    }
//
//    var body: some View {
//        let tile = RoundedRectangle(cornerRadius: 14)
//
//        VStack(spacing: 6) {
//            Text(emojiForStage)
//                .font(.system(size: 48))
//                .scaleEffect(bounce ? 1.06 : 1.0)
//                .onChange(of: plant.stage) { _ in
//                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
//                        bounce = true
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                        withAnimation(.spring()) { bounce = false }
//                    }
//                }
//
//            Text(plant.type.displayName)
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity, minHeight: 100)
//        .padding(10)
//        .background(tile.fill(tileFillColor)) // no UIKit dependency leaks
//        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1) // disambiguate overload
//    }
//}
//
//struct PlantPicker: View {
//    let plant: Plant
//    @Environment(\.dismiss) private var dismiss
//    @EnvironmentObject var greenhouse: Greenhouse
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(PlantType.allCases, id: \.self) { t in
//                    Button {
//                        greenhouse.replacePlant(plant, with: t)
//                        dismiss()
//                    } label: {
//                        HStack {
//                            Text(icon(for: t)).font(.title2)
//                            Text(t.displayName)
//                            Spacer()
//                            if t == plant.type { Image(systemName: "checkmark") }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Choose Plant")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Done") { dismiss() }
//                }
//            }
//        }
//        .frame(minWidth: 360, minHeight: 420)
//    }
//
//    private func icon(for t: PlantType) -> String {
//        switch t {
//        case .sunflower: return "🌻"
//        case .cactus:    return "🌵"
//        case .vine:      return "🪴"
//        case .herb:      return "🌿"
//        }
//    }
//}


import SwiftUI

struct GreenhouseView: View {
    @EnvironmentObject var greenhouse: Greenhouse
    @State var editingPlant: Plant?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Greenhouse").font(.title3).bold()
            Text("Flowers grown so far: \(greenhouse.flowersTotal)")
                .font(.footnote).foregroundStyle(.secondary)
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 12)), count: 3)) {
                    ForEach(greenhouse.plants) { plant in
                        PlantTile(plant: plant).onTapGesture { editingPlant = plant } // open picker
                                .contextMenu { // right-click options
                                    Button("Reset to seed") {
                                        greenhouse.change(plant, to: plant.type)
                                    }
                                    Menu("Change plant type") {
                                        ForEach(PlantType.allCases, id: \.self) { type in
                                            Button(type.displayName) { greenhouse.change(plant, to: type)}
                                        }
                                    }
                                }
                            }
                        
                    }
                    .padding(.top, 6)
                }
                
                // buttons below
                HStack {
                    Button("Reset all to seeds") { greenhouse.resetAll()}
                    Spacer()
                    Button {
                        greenhouse.plants.append(Plant()) // add new pot
                    } label: { Label("Add pot", systemImage: "plus.circle.fill")}
                }
            }
            .padding()
            .sheet(item: $editingPlant) { plant in
                PlantPicker(plant: plant)}
        }
    }


struct PlantTile: View {
    let plant: Plant
    @State private var bounce = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 6) {
                // emoji grows as stage increases
                Text(emojiForStage)
                    .font(.system(size: 48))
                    .scaleEffect(bounce ? 1.06 : 1.0)
                    .onChange(of :plant.stage) { _, _ in
                        
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {bounce = true}
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring()) { bounce = false }
                        }
                    }
                Text(plant.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 14).fill(.background).shadow(radius: 2))
        }
        
        
    }
    private var emojiForStage: String {
        let arr = plant.type.emojiStages
        return arr[min(plant.stage, arr.count - 1)]
    }
}

struct PlantPicker: View {
    let plant: Plant
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var greenhouse: Greenhouse
    
    var body: some View {
        NavigationView {
            List {
                ForEach(PlantType.allCases, id: \.self) { type in
                    Button {
                        greenhouse.change(plant, to: type)
                        dismiss()
                        
                    } label: {
                        HStack {
                            Text(icon(for: type))
                            Text(type.displayName)
                            Spacer()
                            if type == plant.type { Image(systemName: "checkmark")}
                        }
                    }
                }
            }
            .navigationTitle("Choose Plant")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done"){ dismiss() } }
            }
        }
        .frame(minWidth: 360, minHeight: 420)
    }
    
    private func icon(for t: PlantType) -> String {
        switch t {
        case .sunflower: return "🌻"
        case .cactus: return "🌵"
        case .vine: return "🪴"
        case .herb: return "🌿"
        }
    }
}


