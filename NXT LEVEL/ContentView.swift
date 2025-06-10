//
//  ContentView.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 31/1/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var workoutManager = WorkoutManager()
    
    init() {
            // Set the background color of the Tab Bar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
            
            // Apply the appearance to all tab bars
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    
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
            Tab("Stats", systemImage: "chart.line.text.clipboard") {
                    Text("Stats View")
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
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("In Progress - \(workoutManager.formattedDuration())")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Button(action: { 
                    workoutManager.endWorkout()
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 8)
                
                Button(action: { 
                    workoutManager.togglePause()
                }) {
                    Image(systemName: workoutManager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
            }
            .padding(12)
            .background(Color.buttonPrimary)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
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
