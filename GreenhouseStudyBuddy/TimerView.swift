//
//  TimerView.swift
//  GreenhouseStudyBuddy
//
//  Created by Madison Cavill on 2025-09-07.
//
import SwiftUI


struct TimerView: View {
    @EnvironmentObject var timer: PomodoroTimer
    
    var body: some View {
        VStack(spacing: 16) {
            Text("🌱 Greenhouse Study Buddy")
                .font(.title3).bold()
            
            
            PhaseChip(isWork: timer.isWork)
                // shows focus session or break time chip
            
            ZStack {
                ProgressRing(progress: progress, accent: .teal)
                    .frame(width: 200, height: 200)
                
                Text(timer.formatted())
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            
            HStack {
                Button(timer.isRunning ? "Stop" : "Start") {
                    timer.isRunning ? timer.stop() : timer.start()
                }
                
                Text("Finish work sessions to grow your plants 🪴")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
                
            }
            .padding()
        }
        
        
    }
    private var progress: CGFloat {
        let total = CGFloat((timer.isWork ? timer.workMin : timer.breakMin) * 60)
        return total > 0 ? 1 - CGFloat(timer.remaining) / total : 0
    }
    struct PhaseChip: View {
        let isWork: Bool
        var body: some View {
            Label(isWork ? "Focus Session" : "Break TIme",
                  systemImage: isWork ? "book.fill" : "cup.and.saucer.fill")
            .font(.caption.weight(.semibold))
            .padding(.vertical, 6).padding(.horizontal, 10)
            .background(Capsule().fill(Color.teal))
            .foregroundStyle(.white)
        }
    }
    
    struct ProgressRing: View {
        let progress: CGFloat // 0 -> 1
        let accent: Color
        
        var body: some View {
            ZStack {
                Circle()
                    .stroke(accent.opacity(0.15), lineWidth: 14) // faint background ring
                Circle()
                    .trim(from: 0, to: max(0.001, progress)) // draw arc up to progress
                    .stroke(accent, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))   // start at top (12)
                    .animation(.easeInOut(duration: 0.25), value: progress) // smooth updates
            }
        }
    }
}
