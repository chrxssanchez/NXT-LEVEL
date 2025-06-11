//
//  ActiveWorkoutView.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 10/5/2025.
//

import SwiftUI

// Define WorkoutDay here if not already imported
/*
struct WorkoutDay: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var date: Date
    var workout: WorkoutPlan
    var isCurrentDay: Bool
    
    static func == (lhs: WorkoutDay, rhs: WorkoutDay) -> Bool {
        return lhs.id == rhs.id
    }
}
*/

struct ActiveWorkoutView: View {
    @State var workout: ActiveWorkout
    var scheduledDay: WorkoutDay
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                // Left side - Title
                VStack(alignment: .leading, spacing: 5) {
                    Text(workout.name)
                        .font(Font.custom("Montserrat-Bold", size: 34))
                    
                    Text("\(workoutManager.formattedDuration())")
                        .font(Font.custom("Montserrat-Bold", size: 16))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Right side - Actions
                Button("Finish") {
                    workoutManager.endWorkout()
                    dismiss()
                }
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.buttonPrimary)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button(action: {
                    // More options
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 24))
                        .foregroundColor(Color(.systemGray2))
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Progress bar indicators
            HStack(spacing: 4) {
                ForEach(0..<workout.exercises.count, id: \.self) { index in
                    Capsule()
                        .frame(height: 4)
                        .foregroundColor(index == 0 ? Color.buttonPrimary : Color(.systemGray4))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            // Workout in progress view
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach($workout.exercises) { $exercise in
                        WorkoutExerciseCard(exercise: $exercise)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Check if this workout is already in progress
            if let currentWorkout = workoutManager.currentWorkout, currentWorkout.name == workout.name {
                workout = currentWorkout // Use the workout from manager
            }
        }
    }
}

//// Exercise preview card for the pre-workout screen
//struct ExercisePreviewCard: View {
//    @Binding var exercise: Exercise
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            // Header
//            HStack {
//                Text(exercise.name)
//                    .font(.system(size: 20, weight: .semibold))
//                
//                Spacer()
//                
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.gray)
//                
//                Button(action: {
//                    // Exercise options
//                }) {
//                    Image(systemName: "ellipsis")
//                        .padding(8)
//                        .foregroundColor(.gray)
//                        .background(Color(.systemGray5))
//                        .clipShape(Circle())
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 16)
//            .padding(.bottom, 8)
//            
//            // Target reps
//            HStack {
//                Text("Target Reps:")
//                    .foregroundColor(.secondary)
//                
//                Spacer()
//                
//                Text("\(exercise.repRangeMinSuggestion ?? 0)")
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 8)
//                    .background(Color(.systemGray5))
//                    .cornerRadius(8)
//            }
//            .padding(.horizontal, 16)
//            
//            // Set rows
//            HStack {
//                Text("Set")
//                    .frame(width: 50, alignment: .center)
//                    .font(.system(size: 15))
//                    .foregroundColor(.secondary)
//                
//                Text("Weight (kg)")
//                    .frame(maxWidth: .infinity)
//                    .font(.system(size: 15))
//                    .foregroundColor(.secondary)
//                
//                Text("Reps")
//                    .frame(maxWidth: .infinity)
//                    .font(.system(size: 15))
//                    .foregroundColor(.secondary)
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 16)
//            
//            // Set data rows
//            ForEach(exercise.sets.prefix(3)) { set in
//                HStack(spacing: 16) {
//                    Text("\(set.setNumber)")
//                        .font(.system(size: 16))
//                        .frame(width: 50, alignment: .center)
//                    
//                    Text("50")
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 8)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(8)
//                    
//                    Text("10")
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 8)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(8)
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 8)
//            }
//            
//            // Add set button
//            Button(action: {
//                // Add set action
//                exercise.sets.append(ExerciseSet(setNumber: exercise.sets.count + 1))
//            }) {
//                HStack {
//                    Image(systemName: "plus")
//                    Text("Add Set")
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 12)
//                .foregroundColor(.secondary)
//                .background(Color(.systemGray6))
//                .cornerRadius(8)
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//            
//            // Timer button
//            HStack {
//                Button(action: {
//                    // Timer action
//                }) {
//                    HStack {
//                        Image(systemName: "timer")
//                        Text("\(exercise.restTime ?? "3:00")")
//                    }
//                    .font(.system(size: 16, weight: .bold))
//                    .padding(.vertical, 5)
//                    .padding(.horizontal, 5)
//                    .background(Color.buttonSecondary)
//                    .foregroundColor(.white)
//                    .cornerRadius(5)
//                }
//                
//                Spacer()
//                
//                Button(action: {
//                    // Show stats
//                }) {
//                    Image(systemName: "chart.xyaxis.line")
//                        .padding(8)
//                        .background(Color.buttonPrimary)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.bottom, 16)
//        }
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//    }
//}

// Exercise card for the workout in progress
struct WorkoutExerciseCard: View {
    @Binding var exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading) {
            // Exercise header
            HStack {
                Text(exercise.name)
                    .font(Font.custom("Montserrat-Bold", size: 20))
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    // More options
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            .padding(.horizontal, 16)
            
            // Column headers
            HStack(spacing: 40) {
                Text("Set")
                    .frame(width: 35, alignment: .center)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("Weight (kg)")
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("Reps")
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Image(systemName: "checkmark")
                    .frame(width: 35)
                    .font(.system(size: 14))
                    .foregroundColor(.clear) // Just for layout
            }
            .padding(.horizontal, 10)
            
            // Sets
            List {
                ForEach($exercise.sets) { $set in
                    // Separate background content and interactive button
                    ZStack {
                        // Background content with allowsHitTesting(false)
                        HStack(spacing: 40) {
                            Text("\(set.setNumber)")
                                .font(.system(size: 18))
                                .frame(width: 35, height: 35, alignment: .center)
                                .background(set.isCompleted ? Color(.completedSet): Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            
                            TextField("50", text: $set.weight)
                                .font(.system(size: 18))
                                .multilineTextAlignment(.center)
                                .frame(height: 35)
                                .background(set.isCompleted ? Color(.completedSet): Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .keyboardType(.decimalPad)
                            
                            TextField("10", text: $set.reps)
                                .font(.system(size: 18))
                                .multilineTextAlignment(.center)
                                .frame(height: 35)
                                .background(set.isCompleted ? Color(.completedSet): Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .keyboardType(.numberPad)
                            
                            Color.clear
                                .frame(width: 35, height: 35)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .background(set.isCompleted ? Color(.completedSet).opacity(0.25): Color.clear)
                        .allowsHitTesting(false)
                        
                        // Checkmark button on top, interactive
                        HStack {
                            Spacer()
                            Button(action: {
                                if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
                                    exercise.sets[index].isCompleted.toggle()
                                }
                            }) {
                                Image(systemName: set.isCompleted ? "checkmark" : "checkmark")
                                    .fontWeight(.bold)
                                    .foregroundColor(.black).opacity(0.5)
                                    .frame(width: 35, height: 35)
                                    .background(set.isCompleted ? Color(.completedSet): Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .frame(width: 35, height: 35)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
                                exercise.sets.remove(at: index)
                                // Renumber remaining sets
                                for i in index..<exercise.sets.count {
                                    exercise.sets[i].setNumber = i + 1
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    //Swipe to complete the set
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button() {
                            if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
                                exercise.sets[index].isCompleted.toggle()
                            }
                        } label: {
                            Image(systemName: "checkmark")
                        }
                        .tint(.completedSet)
                    }
                    
                }
                .onDelete { _ in } // Empty implementation to prevent default swipe
            }
            .listStyle(PlainListStyle())
            .environment(\.defaultMinListRowHeight, 0)
            .scrollContentBackground(.hidden)
            .frame(height: CGFloat(exercise.sets.count * 45))  // Adjust height based on number of sets
            
            Divider()
                .overlay {
                        RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color(.outline), lineWidth: 1)
                    }
            
            // Action buttons
            HStack {
                // Rep range pill
//                if let repRange = (exercise.repRangeMinSuggestion +
//                   exercise.repRangeMaxSuggestion) {
                Text("\(exercise.repRangeMinSuggestion ?? 10)-\(exercise.repRangeMaxSuggestion ?? 12) Reps")
                        .font(.system(size: 16) .weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        .background(Color(.black).opacity(0.5))
                        .cornerRadius(5)
                
                
                Spacer()
                
                HStack(spacing: 10){
                    // Timer button
                    Button(action: {
                        // Timer action
                    }) {
                        if #available(iOS 26.0, *) {
                            HStack {
                                Image(systemName: "timer")
                                    .imageScale(.medium)
                                Text("\(exercise.restTime ?? "3:00")")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 5)
                            .glassEffect()
//                            .background(Color.buttonSecondary)
                            .foregroundStyle(Color.buttonSecondary)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        } else {
                            // Fallback on earlier versions
                            HStack {
                                Image(systemName: "timer")
                                    .imageScale(.medium)
                                Text("\(exercise.restTime ?? "3:00")")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 5)
                            .background(Color.buttonSecondary)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        }
                    }
                    
                    // History button
                    Button(action: {
                        // History action
                    }) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.buttonSecondary)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 5)
                            .background((Color.buttonSecondary).opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    
                    // Add set button
                    Button(action: {
                        exercise.sets.append(ExerciseSet(setNumber: exercise.sets.count + 1))
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle((Color.black).opacity(0.5))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 5)
                            .background((Color.black).opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding(.vertical, 10)
        .overlay {
                RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color(.outline), lineWidth: 1)
            }
    }
}

// Preview
struct ActiveWorkoutView_Previews: PreviewProvider {
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
                ], repRangeMinSuggestion: 12, repRangeMaxSuggestion: 15, restTime: "2:00", equipmentType: "Dumbbells"),
                Exercise(name: "Seated Fly", sets: [
                    ExerciseSet(setNumber: 1, weight: "50", reps: "12"),
                    ExerciseSet(setNumber: 2, weight: "50", reps: "12")
                ], repRangeMinSuggestion: 10, repRangeMaxSuggestion: 12, restTime: "1:30", equipmentType: "Cables")
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
        
        return ActiveWorkoutView(workout: previewWorkout, scheduledDay: previewDay)
            .environmentObject(WorkoutManager())
    }
} 

