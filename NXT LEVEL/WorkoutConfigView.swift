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
    
    // Available muscle groups based on workout type
    private var availableMuscleGroups: [String] {
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
    private func colorForMuscleGroup(_ group: String) -> Color {
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
        VStack(spacing: 0) {
            VStack{
                // Header
                HStack {
                    // Left side - Title
                    VStack(alignment: .leading, spacing: 5) {
                        Text(workout.name)
                            .font(Font.custom("Montserrat-Bold", size: 34))
                    }
                    
                    Spacer()
                    
                    // Right side - Actions
                    Button(action: {
                        //edit action
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                            .frame(width:35, height:35)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    Button(action: {
                        // Share action
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width:35, height:35)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                            .padding(8)
//                            .background(Color(.systemGray6))
//                            .clipShape(Circle())
                    }
                }
                HStack(spacing: 5) {
                    Text("Scheduled Day:")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("\(scheduledDay.dayOfWeek)")
                        .font(Font.custom("Montserrat-Bold", size: 16))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            
            
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
                    
                    // Start workout button
                    Button(action: {
                        // Start the workout and go to active tracking
                        workoutManager.startWorkout(workout: workout, scheduledDay: scheduledDay)
//                        dismiss() // Dismiss sheet to show minimized banner
                    }) {
                        Text("Start Workout")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.buttonPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    // Exercise previews - Using ConfigExercisePreviewCard that doesn't require binding
                    ForEach(workout.exercises) { exercise in
                        ConfigExercisePreviewCard(exercise: exercise)
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Initialize with first muscle group selected
            if let first = availableMuscleGroups.first {
                selectedMuscleGroups.insert(first)
            }
        }
        .padding(.vertical, 20)
    }
}

// Renamed to avoid conflict with the one in ActiveWorkoutView
struct ConfigExercisePreviewCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(exercise.equipmentType)
                    .font(.system(size: 11))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.buttonSecondary)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 5)
                    .background((Color.buttonSecondary).opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                Text(exercise.name)
                    .font(Font.custom("Montserrat-Bold", size: 18))
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    // Exercise options
                }) {
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Target reps
            HStack {
                Text("Target Reps:")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(exercise.repRangeMinSuggestion ?? 8)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                
                Text("-")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                
                Text("\(exercise.repRangeMaxSuggestion ?? 12)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            
            // Set Config
            HStack{
                Text("Sets:")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text("3")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                Text("Weight (kg):")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text("10")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            Divider()
                .frame(height: 1)
                .overlay(.outline)
                
            HStack {
                Button(action: {
                    // Timer action
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "timer")
                        HStack(spacing: 2) {
                            Text("Rest:")
                            Text("\(exercise.restTime ?? "3:00")")
                        }
                    }
                    .font(.system(size: 13, weight: .bold))
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.buttonSecondary)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                }
                Spacer()
                
                Button(action: {
                    // Show stats
                }) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.buttonSecondary)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .background((Color.buttonSecondary).opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay {
                RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color(.outline), lineWidth: 1)
            }
//        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
