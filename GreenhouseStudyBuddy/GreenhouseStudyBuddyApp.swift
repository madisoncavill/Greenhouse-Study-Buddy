//
//  GreenhouseStudyBuddyApp.swift
//  GreenhouseStudyBuddy
//
//  Created by Madison Cavill on 2025-09-07.
//

import SwiftUI
import UserNotifications

@main
struct GreenhouseStudyBuddyApp: App {
    @StateObject private var timer = PomodoroTimer()
    @StateObject private var greenhouse = Greenhouse()
    
    init() {
        // Ask user once for permission to send local notifications (alert when timer ends)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {_, _ in}
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timer)
                .environmentObject(greenhouse)
                .frame(minWidth: 400, minHeight: 560)
        }
        .windowStyle(.titleBar)
    }
}
