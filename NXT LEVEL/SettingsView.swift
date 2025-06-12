//
//  SettingsView.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 31/1/2025.
//

import SwiftUI
import HealthKit

struct SettingsView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @AppStorage("weightUnit") private var weightUnit = "kg"
    @AppStorage("userName") private var userName = ""
    @AppStorage("userHeight") private var userHeight = ""
    @AppStorage("userAge") private var userAge = ""
    @State private var showHealthPermissions = false
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                Section(header: Text("Profile")) {
                    TextField("Name", text: $userName)
                        .textContentType(.name)
                        .fontWeight(.semibold)
                    
                    TextField("Height (cm)", text: $userHeight)
                        .keyboardType(.decimalPad)
                        .autocorrectionDisabled()
                        .fontWeight(.semibold)
                    
                    TextField("Age", text: $userAge)
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled()
                        .fontWeight(.semibold)
                }
                
                // Units & Preferences Section
                Section(header: Text("Units & Preferences")) {
                    Picker("Weight Unit", selection: $weightUnit) {
                        Text("Kilograms (kg)").tag("kg")
                        Text("Pounds (lbs)").tag("lbs")
                    }
                }
                
                // Health Data Section
                Section(header: Text("Health Data")) {
                    Button(action: {
                        showHealthPermissions = true
                    }) {
                        HStack {
                            Text("Health Permissions")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: GoalAdjustmentView(
                        calorieGoal: .constant(2300),
                        hydrationGoal: .constant(4000),
                        stepGoal: .constant(10000)
                    )) {
                        Text("Adjust Goals")
                    }
                }
                
                // App Settings Section
                Section(header: Text("App Settings")) {
                    NavigationLink(destination: Text("Notifications Settings")) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    NavigationLink(destination: Text("App Appearance")) {
                        Label("Appearance", systemImage: "paintbrush.fill")
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("Privacy Policy")) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink(destination: Text("Terms of Service")) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                    
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showHealthPermissions) {
                HealthPermissionsView()
            }
        }
    }
}

struct HealthPermissionsView: View {
    @Environment(\.dismiss) var dismiss
    let healthStore = HKHealthStore()
    @State private var isRequestingPermissions = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Required Permissions")) {
                    PermissionRow(title: "Weight", description: "Track your body weight progress", icon: "scalemass.fill")
                    PermissionRow(title: "Steps", description: "Monitor your daily activity", icon: "figure.walk")
                    PermissionRow(title: "Water", description: "Track your hydration", icon: "drop.fill")
                    PermissionRow(title: "Sleep", description: "Monitor your sleep patterns", icon: "bed.double.fill")
                    PermissionRow(title: "Nutrition", description: "Track your nutrition data", icon: "fork.knife")
                }
                
                Section {
                    Button(action: requestHealthPermissions) {
                        if isRequestingPermissions {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Request Permissions")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(isRequestingPermissions)
                }
            }
            .navigationTitle("Health Access")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func requestHealthPermissions() {
        isRequestingPermissions = true
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                isRequestingPermissions = false
                if success {
                    dismiss()
                }
            }
        }
    }
}

struct PermissionRow: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView()
}
