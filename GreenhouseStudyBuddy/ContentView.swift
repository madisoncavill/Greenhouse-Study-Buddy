//
//  ContentView.swift
//  GreenhouseStudyBuddy
//
//  Created by Madison Cavill on 2025-09-07.
//

import SwiftUI

struct ContentView: View {
    @State private var tab = 0
    // tracks which tab is selected
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $tab) {
                Text("Timer").tag(0)
                Text("Greenhouse").tag(1)
                Text("Settings").tag(2)
                
            }
            .pickerStyle(.segmented)
            .padding()
            
            Group {
                switch tab {
                case 0: TimerView()
                case 1: GreenhouseView()
                default: SettingsView()
                }
            }
            .frame(minWidth: 400, minHeight: 500)
        }
        .tint(.teal)
    }
}

#Preview {
    ContentView()
        .environmentObject(PomodoroTimer())
        .environmentObject(Greenhouse())

}
