//
//  WorkoutsView.swift
//  Next Level v2
//
//  Created by Chris Sanchez on 16/12/2024.
//

import SwiftUI

// Importing models from ActiveWorkoutView
struct ExerciseSet: Identifiable {
    let id = UUID()
    var setNumber: Int
    var weight: String = ""
    var reps: String = ""
    var isCompleted: Bool = false
}

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var sets: [ExerciseSet]
    var repRangeMinSuggestion: Int?
    var repRangeMaxSuggestion: Int?
    var restTime: String? // Format: "M:SS" e.g. "3:00", "1:30"
    var equipmentType: String // e.g., "Machine", "Cables", "Barbell", etc.
}

struct ActiveWorkout {
    var name: String
    var exercises: [Exercise]
}

// Add a Day model to represent a day of the week
struct WorkoutDay: Identifiable, Equatable {
    var id = UUID()
    var name: String // e.g., "MON", "TUES"
    var dayOfWeek: String // e.g., "Monday", "Tuesday"
    var workout: WorkoutPlan
    var isCurrentDay: Bool
    
    static func == (lhs: WorkoutDay, rhs: WorkoutDay) -> Bool {
        return lhs.id == rhs.id
    }
}

// Workout plan model
struct WorkoutPlan {
    var name: String
    var exercises: Int
    var image: String
    var isRestDay: Bool
    var completed: Bool
}

struct WorkoutsView: View {
    // State for navigation
    @State private var selectedWorkout: ActiveWorkout? = nil
    @State private var showingActiveWorkout = false
    @State private var selectedDay: WorkoutDay? = nil
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var isEditMode = false
    @State private var workoutDays: [WorkoutDay] = []
    @State private var showSaveDialog = false
    @State private var scheduleName = ""
    @State private var showScheduleOptions = false
    @State private var selectedSchedule = ""
    
    // Day abbreviations and full names
    private let dayAbbreviations = ["MON", "TUES", "WED", "THURS", "FRI", "SAT", "SUN"]
    private let dayFullNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    // Get the current day of week
    private var currentDayOfWeek: String {
        let today = Calendar.current.component(.weekday, from: Date())
        // Adjust index since Calendar.current.weekday has Sunday as 1, but our array starts with Monday
        let index = today == 1 ? 6 : today - 2 // Convert to 0-based index where 0 is Monday
        return dayAbbreviations[index]
    }
    
    // Workout data - now converted to a dictionary of WorkoutPlan
    private let workoutPlans: [String: WorkoutPlan] = [
        "Push": WorkoutPlan(name: "Push", exercises: 6, image: "chest-muscle", isRestDay: false, completed: false),
        "Pull": WorkoutPlan(name: "Pull", exercises: 6, image: "back-muscle", isRestDay: false, completed: false),
        "Legs": WorkoutPlan(name: "Legs", exercises: 6, image: "quadriceps", isRestDay: false, completed: false),
        "Upper Body": WorkoutPlan(name: "Upper Body", exercises: 6, image: "biceps-muscle", isRestDay: false, completed: false),
        "Lower Body": WorkoutPlan(name: "Lower Body", exercises: 6, image: "hamstrings", isRestDay: false, completed: false),
        "Rest Day": WorkoutPlan(name: "Rest Day", exercises: 0, image: "", isRestDay: true, completed: false)
    ]
    
    // Default weekly schedule
    private let defaultWeeklySchedule: [String: String] = [
        "MON": "Push",
        "TUES": "Pull",
        "WED": "Legs",
        "THURS": "Rest Day",
        "FRI": "Upper Body",
        "SAT": "Lower Body",
        "SUN": "Rest Day"
    ]
    
    // Get only workout days (non-rest days)
    private var activeWorkoutDays: [WorkoutDay] {
        return workoutDays.filter { !$0.workout.isRestDay }
    }
    
    // Total number of completed workouts
    private var completedWorkoutsCount: Int {
        return activeWorkoutDays.filter { $0.workout.completed }.count
    }
    
    // Sample exercises for each workout type
    private func getExercisesForWorkout(_ workoutName: String) -> [Exercise] {
        switch workoutName {
        case "Push":
            return [
                Exercise(name: "Bench Press", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, repRangeMaxSuggestion: 12, restTime: "3:00", equipmentType: "Barbell"),
                Exercise(name: "Incline Press", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, repRangeMaxSuggestion: 12, restTime: "2:30", equipmentType: "Dumbbells"),
                Exercise(name: "Shoulder Press", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 10, repRangeMaxSuggestion: 15, restTime: "2:00", equipmentType: "Machine"),
                Exercise(name: "Tricep Pushdowns", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 12, repRangeMaxSuggestion: 15, restTime: "1:30", equipmentType: "Cables")
            ]
        case "Pull":
            return [
                Exercise(name: "Lat Pulldowns", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, equipmentType: "Machine"),
                Exercise(name: "Seated Rows", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, equipmentType: "Cables"),
                Exercise(name: "Bicep Curls", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 10, equipmentType: "Dumbbells")
            ]
        case "Legs":
            return [
                Exercise(name: "Squats", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, repRangeMaxSuggestion: 12, equipmentType: "Barbell"),
                Exercise(name: "Leg Press", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 10, repRangeMaxSuggestion: 15, equipmentType: "Machine"),
                Exercise(name: "Leg Extensions", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 12, repRangeMaxSuggestion: 15, equipmentType: "Machine")
            ]
        case "Upper Body":
            return [
                Exercise(name: "Pull-Ups", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, repRangeMaxSuggestion: 12, equipmentType: "Bodyweight"),
                Exercise(name: "Push-Ups", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 10, repRangeMaxSuggestion: 15, equipmentType: "Bodyweight"),
                Exercise(name: "Lateral Raises", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 12, repRangeMaxSuggestion: 15, equipmentType: "Dumbbells")
            ]
        case "Lower Body":
            return [
                Exercise(name: "Romanian Deadlifts", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, repRangeMaxSuggestion: 12, equipmentType: "Dumbells"),
                Exercise(name: "Lunges", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 10, repRangeMaxSuggestion: 15, equipmentType: "Dumbbells"),
                Exercise(name: "Calf Raises", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 15, repRangeMaxSuggestion: 20, equipmentType: "Machine")
            ]
        default:
            return []
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Workouts")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if isEditMode {
                            // Save schedule button
                            Button(action: {
                                showSaveDialog = true
                            }) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 22))
                                    .foregroundColor(.primary)
                            }
                            .padding(.trailing, 8)
                        }
                        
                        Button(action: {
                            // Toggle edit mode
                            isEditMode.toggle()
                        }) {
                            Image(systemName: isEditMode ? "checkmark" : "pencil")
                                .font(.system(size: 22))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Schedule title with dropdown for saved schedules
                    HStack {
                        Menu {
                            Button("5-Day Plan") {
                                selectedSchedule = "5-Day Plan"
                                initializeWorkoutDays() // Reset to default
                            }
                            
                            if !workoutManager.savedWorkoutSchedules.isEmpty {
                                Divider()
                                
                                ForEach(Array(workoutManager.savedWorkoutSchedules.keys), id: \.self) { name in
                                    Button(name) {
                                        selectedSchedule = name
                                        applySchedule(name)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedSchedule.isEmpty ? "5-Day Plan" : selectedSchedule)
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Add save dialog
                .alert("Save Workout Schedule", isPresented: $showSaveDialog) {
                    TextField("Schedule Name", text: $scheduleName)
                    
                    Button("Cancel", role: .cancel) { }
                    
                    Button("Save") {
                        if !scheduleName.isEmpty {
                            workoutManager.saveWorkoutSchedule(name: scheduleName, schedule: workoutDays)
                            selectedSchedule = scheduleName
                            scheduleName = ""
                        }
                    }
                } message: {
                    Text("Enter a name for this workout schedule")
                }
                
                // Progress bar - only for actual workout days
                HStack(spacing: 4) {
                    ForEach(0..<activeWorkoutDays.count, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .frame(height: 6)
                            .foregroundColor(i < completedWorkoutsCount ? Color.buttonPrimary : Color.gray.opacity(0.3))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                
                // Weekly Calendar
                ScrollView {
                    VStack(spacing: 0) {
                        // Weekly workout card
                        if isEditMode {
                            // Reorderable list in edit mode
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    .background(Color(.systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                
                                VStack(spacing: 0) {
                                    ForEach(Array(workoutDays.enumerated()), id: \.element.id) { index, _ in
                                        if index > 0 {
                                            Divider().padding(.horizontal, 0)
                                        }
                                    }
                                    
                                    List {
                                        ForEach($workoutDays) { workoutDay in
                                            let index = workoutDays.firstIndex(of: workoutDay.wrappedValue) ?? 0
                                            WorkoutDayRow(
                                                workoutDay: workoutDay,
                                                isEditMode: isEditMode,
                                                isFirst: index == 0,
                                                isLast: index == workoutDays.count - 1,
                                                onTap: { },
                                                onWorkoutChange: { newWorkoutName in
                                                    // Update the workout for this day
                                                    if let workout = workoutPlans[newWorkoutName] {
                                                        workoutDay.workout.wrappedValue = workout
                                                    }
                                                }
                                            )
                                            .padding(.vertical, 0)
                                            .listRowInsets(EdgeInsets())
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                        }
                                        .onMove { fromOffsets, toOffset in
                                            workoutDays.move(fromOffsets: fromOffsets, toOffset: toOffset)
                                        }
                                    }
                                    .listStyle(.plain)
                                    .environment(\.editMode, .constant(.active))
                                }
                                .padding(.vertical, 1)
                            }
                            .padding(.horizontal)
                        } else {
                            // Regular view in normal mode
                            VStack(spacing: 0) {
                                ForEach($workoutDays) { workoutDay in
                                    if workoutDays.firstIndex(of: workoutDay.wrappedValue) != 0 {
                                        Divider().padding(.horizontal, 0)
                                    }
                                    
                                    let index = workoutDays.firstIndex(of: workoutDay.wrappedValue) ?? 0
                                    WorkoutDayRow(
                                        workoutDay: workoutDay,
                                        isEditMode: isEditMode,
                                        isFirst: index == 0,
                                        isLast: index == workoutDays.count - 1,
                                        onTap: {
                                            if !isEditMode {
                                                if !workoutDay.wrappedValue.workout.isRestDay {
                                                    selectedDay = workoutDay.wrappedValue
                                                    selectedWorkout = ActiveWorkout(
                                                        name: workoutDay.wrappedValue.workout.name,
                                                        exercises: getExercisesForWorkout(workoutDay.wrappedValue.workout.name)
                                                    )
                                                    showingActiveWorkout = true
                                                }
                                            }
                                        },
                                        onWorkoutChange: { newWorkoutName in
                                            // Update the workout for this day
                                            if let workout = workoutPlans[newWorkoutName] {
                                                workoutDay.workout.wrappedValue = workout
                                            }
                                        }
                                    )
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .padding(.horizontal)
                        }
                        
                        // Bottom Buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                // Quick workout action
                            }) {
                                Text("Quick Workout")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.buttonPrimary)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                                    .cornerRadius(15)
                            }
                            
                            Button(action: {
                                // Create routine action
                            }) {
                                Text("Create Routine")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.buttonPrimary)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                                    .cornerRadius(15)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showingActiveWorkout, content: {
                if let workout = selectedWorkout, let day = selectedDay {
                    if workoutManager.isWorkoutStarted {
                        ActiveWorkoutView(workout: workout, scheduledDay: day)
                            .environmentObject(workoutManager)
                    } else {
                        WorkoutConfigView(workout: workout, scheduledDay: day)
                            .environmentObject(workoutManager)
                    }
                }
            })
            .onAppear {
                initializeWorkoutDays()
            }
        }
    }
    
    // Add a new function to apply a saved schedule
    private func applySchedule(_ scheduleName: String) {
        guard let workoutNames = workoutManager.getSavedSchedule(name: scheduleName) else { return }
        
        // Update workout days with the saved schedule
        for (index, workoutName) in workoutNames.enumerated() {
            if index < workoutDays.count, let workout = workoutPlans[workoutName] {
                workoutDays[index].workout = workout
            }
        }
    }
    
    // Initialize workout days with selected schedule or default
    private func initializeWorkoutDays() {
        if !selectedSchedule.isEmpty, selectedSchedule != "Default 5-Day", 
           let savedSchedule = workoutManager.getSavedSchedule(name: selectedSchedule) {
            // Use saved schedule
            workoutDays = zip(dayAbbreviations, dayFullNames).enumerated().map { index, pair in
                let (dayName, fullDayName) = pair
                let workoutName = index < savedSchedule.count ? savedSchedule[index] : "Rest Day"
                let workout = workoutPlans[workoutName] ?? workoutPlans["Rest Day"]!
                
                // Simple logic for completed - just mark weekdays before today as completed
                let today = Calendar.current.component(.weekday, from: Date())
                let dayIndex = index + 2 // +2 because our index 0 (Monday) corresponds to weekday 2
                let adjustedDayIndex = dayIndex > 7 ? dayIndex - 7 : dayIndex
                let isCompleted = adjustedDayIndex < today && !workout.isRestDay
                
                var updatedWorkout = workout
                updatedWorkout.completed = isCompleted
                
                return WorkoutDay(
                    name: dayName,
                    dayOfWeek: fullDayName,
                    workout: updatedWorkout,
                    isCurrentDay: dayName == currentDayOfWeek
                )
            }
        } else {
            // Use default schedule
            workoutDays = zip(dayAbbreviations, dayFullNames).map { dayName, fullDayName in
                let workoutName = defaultWeeklySchedule[dayName] ?? "Rest Day"
                let workout = workoutPlans[workoutName] ?? workoutPlans["Rest Day"]!
                
                // Simple logic for completed - just mark weekdays before today as completed
                let today = Calendar.current.component(.weekday, from: Date())
                let dayIndex = dayAbbreviations.firstIndex(of: dayName)! + 2 // +2 because our index 0 (Monday) corresponds to weekday 2
                let adjustedDayIndex = dayIndex > 7 ? dayIndex - 7 : dayIndex
                let isCompleted = adjustedDayIndex < today && !workout.isRestDay
                
                var updatedWorkout = workout
                updatedWorkout.completed = isCompleted
                
                return WorkoutDay(
                    name: dayName,
                    dayOfWeek: fullDayName,
                    workout: updatedWorkout,
                    isCurrentDay: dayName == currentDayOfWeek
                )
            }
            selectedSchedule = "5 Day"
        }
    }
}

struct WorkoutDayRow: View {
    @Binding var workoutDay: WorkoutDay
    let isEditMode: Bool
    let isFirst: Bool
    let isLast: Bool
    let onTap: () -> Void
    let onWorkoutChange: (String) -> Void
    
    // Available workout plans for dropdown
    private let availableWorkouts = ["Push", "Pull", "Legs", "Upper Body", "Lower Body", "Rest Day"]
    
    var body: some View {
        HStack(spacing: 15) {
            // Day column with name
            VStack(spacing: 2) {
                Text(workoutDay.name)
                    .font(.system(size: 15, weight: .bold))
            }
            .frame(width: 60)
            
            if isEditMode {
                // Workout selection in edit mode
                Menu {
                    ForEach(availableWorkouts, id: \.self) { workoutName in
                        Button(workoutName) {
                            onWorkoutChange(workoutName)
                        }
                    }
                } label: {
                    HStack {
                        if workoutDay.workout.isRestDay {
                            Text("😴")
                                .font(.system(size: 24))
                                .padding(.leading, 5)
                        } else {
                            Image(workoutDay.workout.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .padding(.leading, 5)
                        }
                        
                        Text(workoutDay.workout.name)
                            .fontWeight(.semibold)
                            .font(.system(size: 15))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
                    .scaleEffect(0.9)
                }
            } else {
                // Normal workout display
                Button(action: onTap) {
                    WorkoutCardView(
                        workout: workoutDay.workout.name,
                        exercises: workoutDay.workout.exercises,
                        image: workoutDay.workout.image,
                        isRestDay: workoutDay.workout.isRestDay,
                        completed: workoutDay.workout.completed
                    )
                    .padding(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
                    .scaleEffect(0.9)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 80)
        .background(workoutDay.isCurrentDay ? Color(.systemGray6).opacity(0.5) : Color.white)
        .clipShape(
            RoundedCorner(
                radius: 20,
                corners: isFirst && isLast ? [.topLeft, .topRight, .bottomLeft, .bottomRight] :
                         isFirst ? [.topLeft, .topRight] :
                         isLast ? [.bottomLeft, .bottomRight] : []
            )
        )
    }
}

// Extension to add cornerRadius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    WorkoutsView()
        .environmentObject(WorkoutManager())
}
