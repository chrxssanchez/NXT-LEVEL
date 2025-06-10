//
//  Dashboard.swift
//  Next Level v2
//
//  Created by Chris Sanchez on 13/11/2024.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var workoutManager = WorkoutManager()
    
    @State private var showGoalSheet = false
    @State private var showingActiveWorkout = false
    @State private var selectedWorkout: ActiveWorkout? = nil
    @State private var selectedDay: WorkoutDay? = nil
    
    @State private var HydrationGoal = 4000
    @State private var StepsGoal = 10000
    @State private var CalorieGoal = 2300
    
    // Workout data
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
        "WED": "Rest Day",
        "THURS": "Legs",
        "FRI": "Upper Body",
        "SAT": "Rest Day",
        "SUN": "Rest Day"
    ]
    
    private var currentDayOfWeek: String {
        let today = Calendar.current.component(.weekday, from: Date())
        let dayAbbreviations = ["MON", "TUES", "WED", "THURS", "FRI", "SAT", "SUN"]
        let index = today == 1 ? 6 : today - 2 // Convert to 0-based index where 0 is Monday
        return dayAbbreviations[index]
    }
    
    private var todaysWorkout: WorkoutPlan {
        let workoutName = defaultWeeklySchedule[currentDayOfWeek] ?? "Rest Day"
        return workoutPlans[workoutName] ?? workoutPlans["Rest Day"]!
    }
    
    private var nextWorkouts: [WorkoutPlan] {
        let dayAbbreviations = ["MON", "TUES", "WED", "THURS", "FRI", "SAT", "SUN"]
        let today = Calendar.current.component(.weekday, from: Date())
        let startIndex = today == 1 ? 6 : today - 2
        
        var nextWorkoutPlans: [WorkoutPlan] = []
        for i in 1...2 { // Get next 2 workouts
            let nextIndex = (startIndex + i) % 7
            let nextDay = dayAbbreviations[nextIndex]
            let workoutName = defaultWeeklySchedule[nextDay] ?? "Rest Day"
            if let workout = workoutPlans[workoutName] {
                nextWorkoutPlans.append(workout)
            }
        }
        return nextWorkoutPlans
    }
    
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
                ], repRangeMinSuggestion: 10, repRangeMaxSuggestion: 15, restTime: "2:00", equipmentType: "Machine")
            ]
        case "Pull":
            return [
                Exercise(name: "Lat Pulldowns", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, equipmentType: "Machine"),
                Exercise(name: "Seated Rows", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, equipmentType: "Cables")
            ]
        case "Legs":
            return [
                Exercise(name: "Squats", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 8, repRangeMaxSuggestion: 12, equipmentType: "Barbell"),
                Exercise(name: "Leg Press", sets: [
                    ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3)
                ], repRangeMinSuggestion: 10, repRangeMaxSuggestion: 15, equipmentType: "Machine")
            ]
        default:
            return []
        }
    }
    
    var body: some View {
        let currentDate = Date()
        
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMMM"
            return formatter.string(from: currentDate)
        }
        
        ZStack {
            ScrollView {
                VStack(spacing: 10) {
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(formattedDate)
                                .fontWeight(.regular)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Chris Sanchez")
                                .fontWeight(.bold)
                                .font(Font.custom("Montserrat", size: 32))
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                    }
                    
                    HStack{
                        Button("Log Weight", systemImage: "scalemass.fill"){
                        }
                        .padding(10)
                        .background((Color.buttonSecondary).opacity(0.2))
                        .cornerRadius(10)
                        
                        Button("Log Hydration", systemImage: "waterbottle.fill"){
                        }
                        .padding(10)
                        .background((Color.buttonSecondary).opacity(0.2))
                        .cornerRadius(10)
                        
                        Button("Adjust Goals", systemImage: "figure.run.square.stack.fill"){
                            showGoalSheet.toggle()
                        }
                        .padding(10)
                        .background((Color.buttonSecondary).opacity(0.2))
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.buttonSecondary)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    
                    // STATS
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Body Weight (kg)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.textSecondary)
                                HStack {
                                    Image(systemName: "scalemass.fill")
                                        .foregroundStyle(Color.buttonSecondary)
                                        .font(.system(size: 35))
                                        .padding(5)
                                        .background((Color.buttonSecondary).opacity(0.2))
                                        .cornerRadius(10)
                                    Text(healthKitManager.bodyWeight)
                                        .font(Font.custom("Montserrat", size: 28))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.textPrimary)
                                        .animation(.bouncy)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Steps")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.textSecondary)
                                HStack {
                                    CircularProgressBar(progress: {
                                        let stepString = healthKitManager.stepCount.replacingOccurrences(of: ",", with: "")
                                        let steps = Double(stepString) ?? 0
                                        return min(steps / Double(StepsGoal), 1.0)
                                    }(),
                                                        strokeWidth: 5,
                                                        backgroundColor: Color.gray.opacity(0.2),
                                                        foregroundColor: .orange,
                                                        icon: Image( "stepIcon").renderingMode(.template),
                                                        iconColor: .orange)
                                        .padding(.trailing, 5)
                                    Text(healthKitManager.stepCount)
                                        .font(Font.custom("Montserrat", size: 28))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.textPrimary)
                                        .animation(.bouncy)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        HStack {
                            CircularProgressBar(progress: {
                                let hydrationString = healthKitManager.hydration.replacingOccurrences(of: ",", with: "")
                                let hydration = Double(hydrationString) ?? 0
                                return min(hydration / Double(HydrationGoal), 1.0)
                            }(),
                                                strokeWidth: 5,
                                                backgroundColor: Color.gray.opacity(0.2),
                                                foregroundColor: .hydration,
                                                icon: Image(systemName: "drop.fill"),
                                                iconColor: .hydration)
                                .padding(.trailing, 12)
                            
                            VStack(alignment: .leading) {
                                Text(healthKitManager.hydration)
                                    .font(Font.custom("Montserrat", size: 28))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.textPrimary)
                                    .animation(.bouncy)
                                Text("Hydration (ml)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.textSecondary)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        HStack {
                            CircularProgressBar(
                                progress: {
                                    let calorieString = healthKitManager.calories.replacingOccurrences(of: ",", with: "")
                                    let calories = Double(calorieString) ?? 0
                                    return min(calories / Double(CalorieGoal), 1.0)
                                }(),
                                strokeWidth: 5,
                                backgroundColor: Color.gray.opacity(0.2),
                                foregroundColor: .calories,
                                icon: Image(systemName: "fork.knife"),
                                iconColor: .calories
                            )
                                .padding(.trailing, 12)
                            
                            VStack(alignment: .leading) {
                                Text(healthKitManager.calories)
                                    .font(Font.custom("Montserrat", size: 28))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.textPrimary)
                                    .animation(.bouncy)
                                Text("Calories (kcal)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.textSecondary)
                        }
                        .padding(.bottom, 16)
                        .padding(.horizontal)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(20)
                    
                    // WORKOUTS SECTION
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Workouts")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Today's Workout")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        // Today's workout card
                        Button(action: {
                            if !todaysWorkout.isRestDay {
                                selectedWorkout = ActiveWorkout(
                                    name: todaysWorkout.name,
                                    exercises: getExercisesForWorkout(todaysWorkout.name)
                                )
                                selectedDay = WorkoutDay(
                                    name: currentDayOfWeek,
                                    dayOfWeek: formattedDate,
                                    workout: todaysWorkout,
                                    isCurrentDay: true
                                )
                                showingActiveWorkout = true
                            }
                        }) {
                            WorkoutCardView(
                                workout: todaysWorkout.name,
                                exercises: todaysWorkout.exercises,
                                image: todaysWorkout.image,
                                isRestDay: todaysWorkout.isRestDay,
                                completed: todaysWorkout.completed
                            )
                        }
//                        .frame(maxWidth: .infinity, height: 122)
                        .buttonStyle(PlainButtonStyle())
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        HStack{
                            Text("Other Workouts")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            NavigationLink(destination: WorkoutsView().environmentObject(workoutManager)) {
                                HStack {
                                    Text("See all")
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Next workouts
                        HStack(spacing: 15) {
                            ForEach(nextWorkouts, id: \.name) { workout in
                                WorkoutCardView(
                                    workout: workout.name,
                                    exercises: workout.exercises,
                                    image: workout.image,
                                    isRestDay: workout.isRestDay,
                                    completed: workout.completed
                                )
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        
                        
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 16)
            }
            .refreshable {
                healthKitManager.fetchHealthData()
            }
            .sheet(isPresented: $showGoalSheet) {
                GoalAdjustmentView(
                    calorieGoal: $CalorieGoal,
                    hydrationGoal: $HydrationGoal,
                    stepGoal: $StepsGoal
                )
            }
            .sheet(isPresented: $showingActiveWorkout) {
                if let workout = selectedWorkout, let day = selectedDay {
                    if workoutManager.isWorkoutStarted {
                        ActiveWorkoutView(workout: workout, scheduledDay: day)
                            .environmentObject(workoutManager)
                    } else {
                        WorkoutConfigView(workout: workout, scheduledDay: day)
                            .environmentObject(workoutManager)
                    }
                }
            }
        }
    }
}

struct CircularProgressBar: View {
    let progress: Double
    let strokeWidth: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let icon: Image
    let iconColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: strokeWidth)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(foregroundColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270))
                .frame(width: 50, height: 50)
            icon
                .foregroundColor(iconColor)
        }
    }
}

#Preview {
    DashboardView()
}
