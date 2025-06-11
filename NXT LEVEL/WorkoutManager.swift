//
//  WorkoutManager.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 17/5/2025.
//

import SwiftUI
import Combine
import Foundation

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
    
    private let exerciseService = ExerciseService()
    @Published var availableExercises: [APIExercise] = []
    
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
    
    // Convert API Exercise to App Exercise
    private func convertAPIExerciseToAppExercise(_ apiExercise: APIExercise) -> Exercise {
        return Exercise(
            name: apiExercise.name,
            sets: [
                ExerciseSet(setNumber: 1),
                ExerciseSet(setNumber: 2),
                ExerciseSet(setNumber: 3)
            ],
            repRangeMinSuggestion: getDefaultRepRange(for: apiExercise.type).min,
            repRangeMaxSuggestion: getDefaultRepRange(for: apiExercise.type).max,
            restTime: getDefaultRestTime(for: apiExercise.difficulty),
            equipmentType: apiExercise.equipment
        )
    }
    
    // Get default rep range based on exercise type
    private func getDefaultRepRange(for type: String) -> (min: Int, max: Int) {
        switch type.lowercased() {
        case "strength":
            return (6, 8)
        case "powerlifting":
            return (3, 5)
        case "olympic_weightlifting":
            return (2, 4)
        case "cardio":
            return (15, 20)
        default:
            return (8, 12)
        }
    }
    
    // Get default rest time based on difficulty
    private func getDefaultRestTime(for difficulty: String) -> String {
        switch difficulty.lowercased() {
        case "beginner":
            return "1:30"
        case "intermediate":
            return "2:00"
        case "expert":
            return "3:00"
        default:
            return "2:00"
        }
    }
    
    func loadExercisesForWorkout(_ workoutType: String) async {
        print("Loading exercises for workout type: \(workoutType)")
        do {
            switch workoutType.lowercased() {
            case "push":
                print("Fetching push exercises...")
                availableExercises = try await exerciseService.getExercisesForPushDay()
                print("Received \(availableExercises.count) push exercises")
            case "pull":
                print("Fetching pull exercises...")
                availableExercises = try await exerciseService.getExercisesForPullDay()
                print("Received \(availableExercises.count) pull exercises")
            case "legs":
                print("Fetching leg exercises...")
                availableExercises = try await exerciseService.getExercisesForLegDay()
                print("Received \(availableExercises.count) leg exercises")
            default:
                print("Unknown workout type: \(workoutType)")
            }
        } catch {
            print("Error loading exercises: \(error)")
            availableExercises = [] // Clear exercises on error
        }
    }
    
    // Add exercise to current workout
    func addExercise(_ apiExercise: APIExercise) {
        guard var workout = currentWorkout else { return }
        let appExercise = convertAPIExerciseToAppExercise(apiExercise)
        workout.exercises.append(appExercise)
        currentWorkout = workout
    }
    
    // Remove exercise from current workout
    func removeExercise(at index: Int) {
        guard var workout = currentWorkout else { return }
        guard index < workout.exercises.count else { return }
        workout.exercises.remove(at: index)
        currentWorkout = workout
    }
} 