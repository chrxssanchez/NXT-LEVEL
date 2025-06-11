//
//  WorkoutConfigView.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 17/5/2025.
//

import SwiftUI

struct WorkoutConfigView: View {
    var workout: ActiveWorkout
    var scheduledDay: WorkoutDay
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    
    // Selected muscle groups
    @State private var selectedMuscleGroups: Set<String> = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Available muscle groups based on workout type
    var availableMuscleGroups: [String] {
        switch workout.name {
        case "Push":
            return ["Chest", "Triceps", "Shoulders"]
        case "Pull":
            return ["Back", "Biceps", "Traps"]
        case "Legs":
            return ["Quads", "Hamstrings", "Calves"]
        case "Upper Body":
            return ["Chest", "Back", "Shoulders", "Arms"]
        default:
            return ["General"]
        }
    }
    
    // Get color for muscle group
    func colorForMuscleGroup(_ group: String) -> Color {
        switch group {
        case "Back":
            return Color(.back) // Light purple
        case "Biceps":
            return Color(.biceps) // Light pink
        case "Chest":
            return Color(.chest) // Light peach
        case "Glutes":
            return Color(.glutes) // Light cyan
        case "Hamstrings":
            return Color(.hamstrings) // Light mint
        case "Quads":
            return Color(.quads) // Light red
        case "Shoulders":
            return Color(.shoulders) // Light yellow
        case "Triceps":
            return Color(.triceps) // Light green
        default:
            return Color(white: 0.95)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack {
                    // Title
                    VStack(alignment: .leading, spacing: 5) {
                        Text(workout.name)
                            .font(Font.custom("Montserrat-Bold", size: 34))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(spacing: 5) {
                            Text("Scheduled Day:")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("\(scheduledDay.dayOfWeek)")
                                .font(Font.custom("Montserrat-Bold", size: 16))
                        }
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                
                // Pre-workout configuration
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Muscle group selection
                        HStack(spacing: 8) {
                            ForEach(availableMuscleGroups, id: \.self) { group in
                                Text(group)
                                    .font(.system(size: 15))
                                    .fontWeight(.bold)
                                    .foregroundStyle(colorForMuscleGroup(group))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(colorForMuscleGroup(group).opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Show loading state or exercises
                        if isLoading {
                            VStack(spacing: 10) {
                                ProgressView()
                                Text("Loading exercises...")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        } else if let error = errorMessage {
                            VStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                Button("Try Again") {
                                    Task {
                                        await loadExercises()
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        } else if workoutManager.availableExercises.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 24))
                                    .foregroundColor(.secondary)
                                Text("No exercises found")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                Button("Try Again") {
                                    Task {
                                        await loadExercises()
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        } else {
                            // Display available exercises
                            ForEach(workoutManager.availableExercises, id: \.name) { exercise in
                                ExercisePreviewCard(exercise: exercise)
                            }
                        }
                        
                        // Start workout button
                        Button(action: {
                            // Start the workout and go to active tracking
                            workoutManager.startWorkout(workout: workout, scheduledDay: scheduledDay)
//                            dismiss() // Dismiss sheet to show minimized banner
                        }) {
                            Text("Start Workout")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.buttonPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction){
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
//                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                ToolbarItem() {
                    HStack(spacing: 12) {
                        Button(action: {
                            // Edit action
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .frame(width: 32, height: 32)
//                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            // Share action
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .frame(width: 32, height: 32)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        
        .onAppear {
            // Initialize with first muscle group selected
            if let first = availableMuscleGroups.first {
                selectedMuscleGroups.insert(first)
            }
            
            // Load exercises for the workout type
            Task {
                await loadExercises()
            }
        }
        .padding(.vertical, 20)
    }
    
    private func loadExercises() async {
        isLoading = true
        errorMessage = nil
        
        do {
            await workoutManager.loadExercisesForWorkout(workout.name)
            if workoutManager.availableExercises.isEmpty {
                errorMessage = "No exercises found for this workout type"
            }
        } catch {
            errorMessage = "Failed to load exercises. Please check your internet connection and try again."
        }
        
        isLoading = false
    }
}

// Exercise preview card
struct ExercisePreviewCard: View {
    let exercise: APIExercise
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var isAdded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise name and type
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 18, weight: .semibold))
                    Text(exercise.type)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: {
                    if !isAdded {
                        workoutManager.addExercise(exercise)
                        isAdded = true
                    }
                }) {
                    Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                        .foregroundColor(isAdded ? .green : .accentColor)
                        .font(.system(size: 24))
                }
                
                Text(exercise.difficulty.capitalized)
                    .font(.system(size: 14))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(difficultyColor(exercise.difficulty))
                    )
            }
            
            // Equipment
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(.secondary)
                Text(exercise.equipment)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            // Expandable instructions
            DisclosureGroup("Instructions") {
                Text(exercise.instructions)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner":
            return Color.green.opacity(0.2)
        case "intermediate":
            return Color.yellow.opacity(0.2)
        case "expert":
            return Color.red.opacity(0.2)
        default:
            return Color.gray.opacity(0.2)
        }
    }
}

// Preview
struct WorkoutConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let previewWorkout = ActiveWorkout(
            name: "Push",
            exercises: [
                Exercise(name: "Incline Chest Press", sets: [
                    ExerciseSet(setNumber: 1, weight: "50", reps: "10", isCompleted: true),
                    ExerciseSet(setNumber: 2, weight: "50", reps: "10", isCompleted: false),
                    ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 10, repRangeMaxSuggestion: 12, restTime: "3:00", equipmentType: "Machine"),
                Exercise(name: "Front Raises", sets: [
                    ExerciseSet(setNumber: 1, weight: "50", reps: "12"),
                    ExerciseSet(setNumber: 2, weight: "50", reps: "12"),
                    ExerciseSet(setNumber: 3, weight: "50", reps: "12")
                ], repRangeMinSuggestion: 12, repRangeMaxSuggestion: 15, restTime: "2:00", equipmentType: "Dumbbells")
            ]
        )
        
        let previewDay = WorkoutDay(
            id: UUID(),
            name: "MON",
            dayOfWeek: "Monday",
            workout: WorkoutPlan(
                name: "Push",
                exercises: 6,
                image: "chest-muscle",
                isRestDay: false,
                completed: false
            ),
            isCurrentDay: true
        )
        
        return WorkoutConfigView(workout: previewWorkout, scheduledDay: previewDay)
            .environmentObject(WorkoutManager())
    }
} 
