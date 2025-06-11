//
//  GoalAdjustmentView.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 5/2/2025.
//

import SwiftUI

struct GoalAdjustmentView: View {
    @Binding var calorieGoal: Int
    @Binding var hydrationGoal: Int
    @Binding var stepGoal: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Steps Goal
                GoalAdjustmentCard(title: "Steps", value: $stepGoal, min: 1000, max: 20000, icon: "shoeprints.fill", color: .steps)
                
                // Hydration Goal
                GoalAdjustmentCard(title: "Hydration (ml)", value: $hydrationGoal, min: 500, max: 5000, icon: "drop.fill", color: .hydration)
                
                // Calories Goal
                GoalAdjustmentCard(title: "Calories", value: $calorieGoal, min: 1000, max: 5000, icon: "fork.knife", color: .calories)
                
                Spacer()
                
                // Save Button
                Button(action: {
                    dismiss()  // Close sheet
                }) {
                    Text("Save Goals")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding()
            }
            .padding()
            .navigationTitle("Adjust Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GoalAdjustmentCard: View {
    var title: String
    @Binding var value: Int
    var min: Int
    var max: Int
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Text("\(value)")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: Double(min)...Double(max), step: 50)
                .accentColor(color)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


struct GoalAdjustmentPreviewWrapper: View {
    @State private var calorieGoal = 2350
    @State private var hydrationGoal = 4000
    @State private var stepGoal = 10000

    var body: some View {
        GoalAdjustmentView(
            calorieGoal: $calorieGoal,
            hydrationGoal: $hydrationGoal,
            stepGoal: $stepGoal
        )
    }
}

#Preview {
    GoalAdjustmentPreviewWrapper()
}

