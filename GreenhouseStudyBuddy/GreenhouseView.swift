//
//  GreenhouseView.swift
//  GreenhouseStudyBuddy
//
//  Created by Madison Cavill on 2025-09-07.
//

// NEW

import SwiftUI

struct GreenhouseView: View {
    @EnvironmentObject var greenhouse: Greenhouse
    @State var editingPlant: Plant?
    @State private var deleteMode = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Greenhouse").font(.title3).bold()
            Text("Flowers grown so far: \(greenhouse.flowersTotal)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if deleteMode {
                Text("Delete Mode: tap a plant to remove it")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.bottom, 2)
            }

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 12)), count: 3)) {
                    ForEach(greenhouse.plants) { plant in
                        PlantTile(plant: plant, deleteMode: deleteMode)
                            .onTapGesture {
                                if deleteMode {
                                    delete(plant)
                                } else {
                                    editingPlant = plant
                                }
                            }
                            .contextMenu {
                                // keep context actions, but they won't be used in delete mode
                                Button("Reset to seed") {
                                    greenhouse.change(plant, to: plant.type)
                                }
                                Menu("Change plant type") {
                                    ForEach(PlantType.allCases, id: \.self) { type in
                                        Button(type.displayName) {
                                            greenhouse.change(plant, to: type)
                                        }
                                    }
                                }
                            }
                    }
                }
                .padding(.top, 6)

                // big buttons row
                HStack(spacing: 12) {
                    Button(deleteMode ? "Done Deleting" : "Delete Mode") {
                        deleteMode.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.red)

                    Button("Reset all to seeds") {
                        greenhouse.resetAll()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Spacer(minLength: 8)

                    Button {
                        greenhouse.plants.append(Plant()) // add new pot
                    } label: {
                        Label("Add pot", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding()
            .sheet(item: $editingPlant) { plant in
                PlantPicker(plant: plant)
                    .environmentObject(greenhouse)
            }
        }
        .padding()
    }

    // straightforward delete so you don't need to change your model API
    private func delete(_ plant: Plant) {
        if let idx = greenhouse.plants.firstIndex(where: { $0.id == plant.id }) {
            greenhouse.plants.remove(at: idx)
        }
    }
}

struct PlantTile: View {
    let plant: Plant
    var deleteMode: Bool = false
    @State private var bounce = false

    var body: some View {
        ZStack {
            VStack(spacing: 6) {
                Text(emojiForStage)
                    .font(.system(size: 48))
                    .scaleEffect(bounce ? 1.06 : 1.0)
                    .onChange(of: plant.stage) { _, _ in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { bounce = true }
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
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.background)
                    .shadow(radius: 2)
            )

            if deleteMode {
                // visual warning: red dashed border + trash overlay
                RoundedRectangle(cornerRadius: 14)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundColor(.red)
                    .padding(8)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "trash.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                            .padding(10)
                    }
                }
            }
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
                            Text(icon(for: type)).font(.title2)
                            Text(type.displayName)
                            Spacer()
                            if type == plant.type { Image(systemName: "checkmark") }
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
        case .cactus:    return "🌵"
        case .vine:      return "🪴"
        case .herb:      return "🌿"
        }
    }
}

// OLD

//import SwiftUI
//
//struct GreenhouseView: View {
//    @EnvironmentObject var greenhouse: Greenhouse
//    @State var editingPlant: Plant?
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Your Greenhouse").font(.title3).bold()
//            Text("Flowers grown so far: \(greenhouse.flowersTotal)")
//                .font(.footnote).foregroundStyle(.secondary)
//            
//            ScrollView {
//                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 12)), count: 3)) {
//                    ForEach(greenhouse.plants) { plant in
//                        PlantTile(plant: plant).onTapGesture { editingPlant = plant } // open picker
//                                .contextMenu { // right-click options
//                                    Button("Reset to seed") {
//                                        greenhouse.change(plant, to: plant.type)
//                                    }
//                                    Menu("Change plant type") {
//                                        ForEach(PlantType.allCases, id: \.self) { type in
//                                            Button(type.displayName) { greenhouse.change(plant, to: type)}
//                                        }
//                                    }
//                                }
//                            }
//                        
//                    }
//                    .padding(.top, 6)
//                }
//                
//                // buttons below
//                HStack {
//                    Button("Reset all to seeds") { greenhouse.resetAll()}
//                    Spacer()
//                    Button {
//                        greenhouse.plants.append(Plant()) // add new pot
//                    } label: { Label("Add pot", systemImage: "plus.circle.fill")}
//                }
//            }
//            .padding()
//            .sheet(item: $editingPlant) { plant in
//                PlantPicker(plant: plant)}
//        }
//    }
//
//
//struct PlantTile: View {
//    let plant: Plant
//    @State private var bounce = false
//    
//    var body: some View {
//        ZStack {
//            VStack(spacing: 6) {
//                // emoji grows as stage increases
//                Text(emojiForStage)
//                    .font(.system(size: 48))
//                    .scaleEffect(bounce ? 1.06 : 1.0)
//                    .onChange(of :plant.stage) { _, _ in
//                        
//                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {bounce = true}
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            withAnimation(.spring()) { bounce = false }
//                        }
//                    }
//                Text(plant.type.displayName)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            .frame(maxWidth: .infinity, minHeight: 100)
//            .padding(10)
//            .background(RoundedRectangle(cornerRadius: 14).fill(.background).shadow(radius: 2))
//        }
//        
//        
//    }
//    private var emojiForStage: String {
//        let arr = plant.type.emojiStages
//        return arr[min(plant.stage, arr.count - 1)]
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
//                ForEach(PlantType.allCases, id: \.self) { type in
//                    Button {
//                        greenhouse.change(plant, to: type)
//                        dismiss()
//                        
//                    } label: {
//                        HStack {
//                            Text(icon(for: type))
//                            Text(type.displayName)
//                            Spacer()
//                            if type == plant.type { Image(systemName: "checkmark")}
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Choose Plant")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) { Button("Done"){ dismiss() } }
//            }
//        }
//        .frame(minWidth: 360, minHeight: 420)
//    }
//    
//    private func icon(for t: PlantType) -> String {
//        switch t {
//        case .sunflower: return "🌻"
//        case .cactus: return "🌵"
//        case .vine: return "🪴"
//        case .herb: return "🌿"
//        }
//    }
//}


