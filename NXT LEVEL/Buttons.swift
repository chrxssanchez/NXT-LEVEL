//
//  Buttons.swift
//  NXT LEVEL
//
//  Created by Chris Sanchez on 10/6/2025.
//

import SwiftUI

struct LogWeight: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Log Weight", systemImage: "scalemass.fill")
        }
        .padding(10)
        .cornerRadius(10)
        .font(.system(size: 12))
        .fontWeight(.semibold)
        .glassEffect()
    }
}

struct LogHydration: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Log Hydration", systemImage: "waterbottle.fill")
        }
        .padding(10)
        .cornerRadius(10)
        .font(.system(size: 12))
        .fontWeight(.semibold)
        .glassEffect()
    }
}

struct AdjustGoals: View {
    @Binding var showGoalSheet: Bool
    
    var body: some View {
        Button(action: { showGoalSheet.toggle() }) {
            Label("Adjust Goals", systemImage: "figure.run.square.stack.fill")
        }
        .padding(10)
        .cornerRadius(10)
        .font(.system(size: 12))
        .fontWeight(.semibold)
        .glassEffect()
    }
}

#Preview {
    HStack {
        LogWeight(action: {})
        LogHydration(action: {})
        AdjustGoals(showGoalSheet: .constant(false))
    }
}
