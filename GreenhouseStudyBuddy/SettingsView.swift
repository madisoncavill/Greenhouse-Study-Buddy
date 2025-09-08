//
//  SettingsView.swift
//  GreenhouseStudyBuddy
//
//  Created by Madison Cavill on 2025-09-07.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timer: PomodoroTimer
    
    var body: some View {
        Form {
            Section("Session Lengths") {
                Stepper("Work: \(timer.workMin) min", value: $timer.workMin, in: 1...180, step: 1)
                Stepper("Break: \(timer.breakMin) min", value: $timer.breakMin, in: 1...60, step: 1)
                Button("Apply") { timer.reset() }
                    .buttonStyle(.bordered)
            }
            
            Section("About") {
                Text("Complete work sessions to grow plants in your cozy greenhouse").foregroundStyle(.secondary)
            }
        }
        
        #if os(macos)
        .frame(minWidth: 360, idealWidth: 420)
        #endif
        .navigationTitle("Settings")
        .padding(.top, 1)
    }
}
