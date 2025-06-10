//
//  WorkoutManager.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 17/5/2025.
//

import SwiftUI
import Combine

class WorkoutManager: ObservableObject {
    // Current active workout
    @Published var currentWorkout: ActiveWorkout?
    @Published var currentScheduledDay: WorkoutDay?
    @Published var isWorkoutStarted = false
    @Published var totalDuration: TimeInterval = 0
    @Published var isPaused = false
    
    // Weekly schedule management
    @Published var savedWorkoutSchedules: [String: [String]] = [:]
    private let scheduleStorageKey = "savedWorkoutSchedules"
    
    // Timer publisher
    private var timer: AnyCancellable?
    
    init() {
        loadSavedSchedules()
    }
    
    // Is a workout in progress
    var isWorkoutInProgress: Bool {
        return currentWorkout != nil && isWorkoutStarted
    }
    
    // Start a new workout
    func startWorkout(workout: ActiveWorkout, scheduledDay: WorkoutDay) {
        self.currentWorkout = workout
        self.currentScheduledDay = scheduledDay
        self.totalDuration = 0
        self.isWorkoutStarted = true
        self.isPaused = false
        startTimer()
    }
    
    // Configure workout but don't start it yet
    func configureWorkout(workout: ActiveWorkout) {
        self.currentWorkout = workout
        self.totalDuration = 0
        self.isWorkoutStarted = false
        self.isPaused = false
    }
    
    // Start timer for workout
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.totalDuration += 1
            }
    }
    
    // End the current workout
    func endWorkout() {
        timer?.cancel()
        timer = nil
        currentWorkout = nil
        currentScheduledDay = nil
        isWorkoutStarted = false
        totalDuration = 0
        isPaused = false
    }
    
    // Format duration as string
    func formattedDuration() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: totalDuration) ?? "00:00:00"
    }
    
    // Resume timer if app comes back to foreground
    func resumeTimerIfNeeded() {
        if isWorkoutInProgress && timer == nil && !isPaused {
            startTimer()
        }
    }
    
    // Pause timer if app goes to background (optional)
    func pauseTimer() {
        if !isPaused {
            timer?.cancel()
            timer = nil
            isPaused = true
        }
    }
    
    // Resume a paused timer
    func resumeTimer() {
        if isPaused {
            startTimer()
            isPaused = false
        }
    }
    
    // Toggle pause state
    func togglePause() {
        if isPaused {
            resumeTimer()
        } else {
            pauseTimer()
        }
    }
    
    // Save current workout schedule
    func saveWorkoutSchedule(name: String, schedule: [WorkoutDay]) {
        // Extract workout names from the schedule
        let workoutNames = schedule.map { $0.workout.name }
        savedWorkoutSchedules[name] = workoutNames
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(savedWorkoutSchedules) {
            UserDefaults.standard.set(encoded, forKey: scheduleStorageKey)
        }
    }
    
    // Load saved workout schedules
    private func loadSavedSchedules() {
        if let savedData = UserDefaults.standard.data(forKey: scheduleStorageKey),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: savedData) {
            self.savedWorkoutSchedules = decoded
        }
    }
    
    // Get a specific saved schedule
    func getSavedSchedule(name: String) -> [String]? {
        return savedWorkoutSchedules[name]
    }
    
    // Delete a saved schedule
    func deleteSchedule(name: String) {
        savedWorkoutSchedules.removeValue(forKey: name)
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(savedWorkoutSchedules) {
            UserDefaults.standard.set(encoded, forKey: scheduleStorageKey)
        }
    }
} 