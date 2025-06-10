//
//  WorkoutCardView.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 8/5/2025.
//

import SwiftUI

struct WorkoutCardView: View {
    let workout: String
    let exercises: Int
    let image: String
    let isRestDay: Bool
    let completed: Bool
    
    init(workout: String, exercises: Int, image: String, isRestDay: Bool = false, completed: Bool = false) {
        self.workout = workout
        self.exercises = exercises
        self.image = image
        self.isRestDay = isRestDay
        self.completed = completed
    }
    
    var body: some View {
        HStack {
            if isRestDay {
                Text("😴")
                    .font(.system(size: 24))
                    .padding(.leading, 5)
            } else {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .padding(.leading, 5)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout)
                    .fontWeight(.semibold)
                    .font(Font.custom("Montserrat", size: 15))
                
                if !isRestDay {
                    Text("\(exercises) Exercises")
                        .font(.system(size: 12))
                        .foregroundStyle(.textSecondary)
                }
            }
            .padding(.leading, 5)
            
            Spacer()
            
            if !isRestDay && completed {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
                    .foregroundColor(.black).opacity(0.5)
                    .frame(width: 35, height: 35)
                    .background(Color(.completedSet))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
    }
}

struct WorkoutCardHomeView: View {
    let workout: String
    let exercises: Int
    let image: String
    let isRestDay: Bool
    let completed: Bool
    
    init(workout: String, exercises: Int, image: String, isRestDay: Bool = false, completed: Bool = false) {
        self.workout = workout
        self.exercises = exercises
        self.image = image
        self.isRestDay = isRestDay
        self.completed = completed
    }
    
    // Available muscle groups based on workout type
    var muscleGroups: [String] {
        switch workout {
        case "Push":
            return ["Chest", "Triceps", "Shoulders"]
        case "Pull":
            return ["Back", "Biceps"]
        case "Legs":
            return ["Quads", "Hamstrings"]
        case "Upper Body":
            return ["Chest", "Back", "Shoulders"]
        case "Lower Body":
            return ["Quads", "Hamstrings", "Glutes"]
        default:
            return []
        }
    }
    
    // Get color for muscle group
    func colorForMuscleGroup(_ group: String) -> Color {
        switch group {
        case "Back":
            return Color(.back)
        case "Biceps":
            return Color(.biceps)
        case "Chest":
            return Color(.chest)
        case "Glutes":
            return Color(.glutes)
        case "Hamstrings":
            return Color(.hamstrings)
        case "Quads":
            return Color(.quads)
        case "Shoulders":
            return Color(.shoulders)
        case "Triceps":
            return Color(.triceps)
        default:
            return Color(white: 0.95)
        }
    }
    
    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding(.leading, 5)
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout)
                    .fontWeight(.semibold)
                    .font(Font.custom("Montserrat", size: 15))
                
                HStack(spacing: 8) {
                    ForEach(muscleGroups, id: \.self) { group in
                        Text(group)
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundStyle(colorForMuscleGroup(group))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(colorForMuscleGroup(group).opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                Text("\(exercises) Exercises")
                    .font(.system(size: 12))
                    .foregroundStyle(.textSecondary)
            }
            
            .padding(.leading, 5)
            
            Spacer()
            
            if completed {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
                    .foregroundColor(.black).opacity(0.5)
                    .frame(width: 35, height: 35)
                    .background(Color(.completedSet))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
    }
}

#Preview {
    VStack(spacing: 10) {
        WorkoutCardView(workout: "Push", exercises: 6, image: "chest-muscle", completed: true)
        WorkoutCardView(workout: "Pull", exercises: 6, image: "back-muscle")
        WorkoutCardView(workout: "Rest Day", exercises: 0, image: "", isRestDay: true)
    }
    .padding()
    .background(Color(.systemGray6))
    
    VStack(spacing: 10) {
        WorkoutCardHomeView(workout: "Push", exercises: 6, image: "chest-muscle")
        WorkoutCardHomeView(workout: "Pull", exercises: 7, image: "back-muscle")
        WorkoutCardHomeView(workout: "Legs", exercises: 6, image: "quadriceps")
    }
}
