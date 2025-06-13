//
//  StatsView.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 10/6/2025.
//

import SwiftUI

struct StatsView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var showGoalSheet = false
    @State private var selectedTab = 0
    
    @State private var HydrationGoal = 4000
    @State private var StepsGoal = 10000
    @State private var CalorieGoal = 2300
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 10) {
                HStack() {
                    Text("Metrics")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    
                    HStack(spacing: 30) {
                        NavigationLink {
                            Text("Log Weight")
                        } label: {
                            Image(systemName: "scalemass.fill")
                        }
                        
                        NavigationLink {
                            Text("I'm Thirsty")
                        } label: {
                            Image(systemName: "waterbottle.fill")
                        }
                        
                        NavigationLink(destination: GoalAdjustmentView(
                            calorieGoal: .constant(2300),
                            hydrationGoal: .constant(4000),
                            stepGoal: .constant(10000)
                        )) {
                            Image(systemName: "figure.run.square.stack.fill")
                        }
                    }
                    .font(.system(size: 18))
                    .padding(10)
                    .fontWeight(.semibold)
                    .glassEffect()
                    .tint(Color.buttonSecondary)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Weight and Sleep Stats
                        HStack(spacing: 10) {
                            StatCard(
                                title: "Body Weight (kg)",
                                value: healthKitManager.bodyWeight,
                                icon: "scalemass.fill",
                                subtitle: String(format: "%+.1f kg weekly average", healthKitManager.weeklyWeightChange),
                                subtitleColor: healthKitManager.weeklyWeightChange > 0 ? .green : .red
                            )
                            
                            StatCard(
                                title: "Sleep",
                                value: healthKitManager.sleepHours,
                                icon: "bed.double.fill",
                                subtitle: healthKitManager.sleepGoalMet ? "Sleep Goal Achieved" : "Sleep Goal Not Met",
                                subtitleColor: healthKitManager.sleepGoalMet ? .green : .red
                            )
                        }
                        
                        // Calories Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Calories (kcal)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
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
                                
                                Spacer()
                                
                                Text(healthKitManager.calories)
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Consumed")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                                
                                
                            }
                            Divider()
                            
                            HStack(spacing: 20) {
                                MacroProgressView(
                                    title: "Protein",
                                    current: Int(healthKitManager.protein),
                                    goal: Int(healthKitManager.proteinGoal),
                                    color: .red
                                )
                                MacroProgressView(
                                    title: "Carbs",
                                    current: Int(healthKitManager.carbs),
                                    goal: Int(healthKitManager.carbsGoal),
                                    color: .blue
                                )
                                MacroProgressView(
                                    title: "Fats",
                                    current: Int(healthKitManager.fats),
                                    goal: Int(healthKitManager.fatsGoal),
                                    color: .purple
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .cornerRadius(20)
                        
                        // Hydration and Steps
                        HStack{
                            VStack(alignment: .leading) {
                                Text("Hydration (ml)")
                                    .font(.system(size: 13))
                                    .padding(.bottom, 5)
                                    .foregroundStyle(.textSecondary)
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
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .cornerRadius(20)
                            
                            VStack(alignment: .leading) {
                                Text("Steps")
                                    .font(.system(size: 13))
                                    .padding(.bottom, 5)
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
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .cornerRadius(20)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .onAppear {
                healthKitManager.fetchHealthData()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let subtitle: String
    var subtitleColor: Color = .secondary
    var progress: CGFloat? = nil
    var progressColor: Color = .blue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.bottom, 5)
            
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(progressColor)
                    .font(.system(size: 30))
                    .frame(width: 40, height: 40)
                    .padding(5)
                    .background(progressColor.opacity(0.2))
                    .cornerRadius(10)
                
                Text(value)
                    .font(.system(size: 28, weight: .semibold))
            }
            
            if let progress = progress {
                ProgressView(value: progress)
                    .tint(progressColor)
                    .padding(.vertical, 5)
            }
            
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(subtitleColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
        )
        .cornerRadius(20)
    }
}

struct MacroProgressView: View {
    let title: String
    let current: Int
    let goal: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            
            Text("\(current)/\(goal)g")
                .font(.system(size: 12))
            
            ProgressView(value: Double(current), total: Double(goal))
                .tint(color)
        }
    }
}

#Preview {
    StatsView()
}
