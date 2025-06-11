//
//  ContentView.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 31/1/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some View {
        ZStack(alignment: .bottom) {
        TabView {
            Tab("Home", systemImage: "house") {
                DashboardView()
            }
            Tab("Workouts", systemImage: "dumbbell") {
                WorkoutsView()
                        .environmentObject(workoutManager)
            }
            Tab("Mertics", systemImage: "chart.line.text.clipboard") {
                StatsView()
            }
            Tab("Settings", systemImage: "person.circle") {
                SettingsView()
                }
            }
            
            // Minimized workout banner
            if workoutManager.isWorkoutInProgress {
                MinimizedWorkoutBanner(workoutManager: workoutManager)
                    .padding(.bottom, 60) // Position above tab bar
                    .transition(.move(edge: .bottom))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            workoutManager.resumeTimerIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            workoutManager.pauseTimer()
        }
    }
}

// Minimized workout banner shown when a workout is in progress
struct MinimizedWorkoutBanner: View {
    @ObservedObject var workoutManager: WorkoutManager
    @State private var showWorkout = false
    
    var body: some View {
        Button(action: {
            showWorkout = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(workoutManager.currentWorkout?.name ?? "Workout")
                        .font(Font.custom("Montserrat-Bold", size: 20))
                    
                    Text("In Progress - \(workoutManager.formattedDuration())")
                        .font(.system(size: 16).weight(.semibold))
                }
                
                Spacer()
                
                Button(action: { 
                    workoutManager.endWorkout()
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 30))
                }
                .padding(.trailing, 8)
                
                Button(action: { 
                    workoutManager.togglePause()
                }) {
                    Image(systemName: workoutManager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 30))
//                        .foregroundColor(.white)
                }
            }
            .padding()
            .foregroundStyle(Color.buttonPrimary)
        }
        .buttonStyle(PlainButtonStyle())
        .glassEffect()
        .padding(.horizontal)
        .sheet(isPresented: $showWorkout) {
            if let workout = workoutManager.currentWorkout, let scheduledDay = workoutManager.currentScheduledDay {
                ActiveWorkoutView(workout: workout, scheduledDay: scheduledDay)
                    .environmentObject(workoutManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
