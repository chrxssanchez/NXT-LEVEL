//
//  Buttons.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 10/6/2025.
//

import SwiftUI

struct LogWeight: View {
    var action: () -> Void
    var iconOnly: Bool = false
    
    var body: some View {
        Button(action: action) {
            if iconOnly {
                Image(systemName: "scalemass.fill")
            } else {
                Label("Log Weight", systemImage: "scalemass.fill")
            }
        }
        .padding(10)
        .cornerRadius(10)
        .fontWeight(.semibold)
        .tint(.buttonSecondary)
    }
}

struct LogHydration: View {
    var action: () -> Void
    var iconOnly: Bool = false
    
    var body: some View {
        Button(action: action) {
            if iconOnly {
                Image(systemName: "waterbottle.fill")
            } else {
                Label("Log Hydration", systemImage: "waterbottle.fill")
            }
        }
        .padding(10)
        .cornerRadius(10)
        .fontWeight(.semibold)
        .tint(.buttonSecondary)
    }
}

struct AdjustGoals: View {
    @Binding var showGoalSheet: Bool
    var iconOnly: Bool = false
    
    var body: some View {
        Button(action: { showGoalSheet.toggle() }) {
            if iconOnly {
                Image(systemName: "figure.run.square.stack.fill")
            } else {
                Label("Adjust Goals", systemImage: "figure.run.square.stack.fill")
            }
        }
        .padding(10)
        .cornerRadius(10)
        .fontWeight(.semibold)
        .tint(.buttonSecondary)
    }
}

#Preview {
    VStack {
        HStack {
            LogWeight(action: {})
            LogHydration(action: {})
            AdjustGoals(showGoalSheet: .constant(false))
        }
        HStack {
            LogWeight(action: {}, iconOnly: true)
            LogHydration(action: {}, iconOnly: true)
            AdjustGoals(showGoalSheet: .constant(false), iconOnly: true)
        }
        .glassEffect()
    }
}
