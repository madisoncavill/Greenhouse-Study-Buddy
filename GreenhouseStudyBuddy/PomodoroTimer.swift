//
//  PomodoroTimer.swift
//  GreenhouseStudyBuddy
//
//  Created by Madison Cavill on 2025-09-07.
//
import SwiftUI
import UserNotifications
import AppKit
import Foundation


@MainActor
final class PomodoroTimer: ObservableObject {
    @AppStorage("workMin") var workMin: Int = 25
    @AppStorage("breakMin") var breakMin: Int = 5
    
    @Published var isRunning = false
    
    @Published var isWork = true
    
    @Published var remaining = 25 * 60
    
    private var timer: DispatchSourceTimer?
    
    init() {
        reset()
    }
    
    func start() {
        guard !isRunning else {
            return
        }
        isRunning = true
        runTimer()
    }
    
    func stop() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func reset() {
        stop()
        remaining = (isWork ? workMin : breakMin) * 60
    }
    
    private func runTimer() {
        timer?.cancel() // cancel any previous timer instance
        let t = DispatchSource.makeTimerSource(queue: .global(qos: .userInitiated))
        
        t.schedule(deadline: .now() + 1, repeating: 1)
        // start firing 1 second from now and then every 1 second thereafter
        
        t.setEventHandler { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.remaining > 0 {
                    self.remaining -= 1 // if there is time left decrement by 1
                } else {
                    self.sessionDone() // helper func that finishes the session
                }
            }
        }
        
        t.resume() // start the timer
        timer = t // hold a reference so it doesnt deallocate
    }
    
    private func sessionDone() {
        stop() // stop ticking timer immediately once finished
        if isWork {
            // only will reward growth after WORK sessions (not breaks)
            NotificationCenter.default.post(name: .workSessionComplete, object: nil)
            // broadcast an event so greenhouse can react and grow a plant
            
        }
        
        let title = isWork ? "Work Session Done!" : "Break Over!"
        // title differs based on the phrase that just ended
        let body = isWork ? "Time for a break 🌿" : "Ready to focus? 🧘‍♀️"
        
        notify(title: title, body: body) // call helper func
        
        NSSound(named: .init("Glass"))?.play()
        
        isWork.toggle() // flip phase: work -> break or break -> work
        
        remaining = (isWork ? workMin : breakMin) * 60 // preload the next phases full duration so Start picks it up
    }
    
    private func notify(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let req = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(req)
        
    }
    
    func formatted() -> String {
        let m = remaining / 60 // whole minutes
        let s = remaining % 60 // remaining seconds (0-59)
        return String(format: "%02d:%02d", m, s)
    }
}


