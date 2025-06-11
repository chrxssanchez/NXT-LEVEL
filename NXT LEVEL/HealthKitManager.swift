//
//  HealthKitManager.swift
//  Next Level v2
//
//  Created by Chris Sanchez on 21/1/2025.
//

import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var bodyWeight: String = "--"
    @Published var weeklyWeightChange: Double = 0.0
    @Published var stepCount: String = "--"
    @Published var stepGoal: Int = 12000
    @Published var hydration: String = "--"
    @Published var hydrationGoal: Int = 4000
    @Published var calories: String = "--"
    @Published var sleepHours: String = "--"
    @Published var sleepGoalMet: Bool = false
    @Published var protein: Double = 0
    @Published var carbs: Double = 0
    @Published var fats: Double = 0
    
    // Macro goals
    let proteinGoal: Double = 190
    let carbsGoal: Double = 260
    let fatsGoal: Double = 60

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
            if success {
                self?.fetchHealthData()
            } else {
                print("Authorization failed: \(String(describing: error))")
            }
        }
    }

    func fetchHealthData() {
        fetchBodyWeight()
        fetchWeeklyWeightChange()
        fetchSteps()
        fetchHydration()
        fetchCalories()
        fetchSleep()
        fetchMacronutrients()
    }

    private func fetchBodyWeight() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }

        let query = HKSampleQuery(
            sampleType: bodyMassType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { [weak self] _, results, _ in
            if let result = results?.first as? HKQuantitySample {
                let weight = result.quantity.doubleValue(for: .gramUnit(with: .kilo))
                DispatchQueue.main.async {
                    self?.bodyWeight = String(format: "%.1f", weight)
                }
            }
        }

        healthStore.execute(query)
    }

    private func fetchWeeklyWeightChange() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: oneWeekAgo, end: now, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(
            quantityType: bodyMassType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage,
            anchorDate: calendar.startOfDay(for: oneWeekAgo),
            intervalComponents: DateComponents(day: 7)
        )
        
        query.initialResultsHandler = { [weak self] _, results, _ in
            guard let results = results else { return }
            
            results.enumerateStatistics(from: oneWeekAgo, to: now) { statistics, _ in
                if let averageWeight = statistics.averageQuantity()?.doubleValue(for: .gramUnit(with: .kilo)) {
                    DispatchQueue.main.async {
                        self?.weeklyWeightChange = averageWeight
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }

    private func fetchSteps() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            if let sum = result?.sumQuantity() {
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                DispatchQueue.main.async {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    let formattedValue = formatter.string(from: NSNumber(value: steps)) ?? "0"
                    self?.stepCount = formattedValue
                }
            }
        }

        healthStore.execute(query)
    }
    
    private func fetchHydration() {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            if let sum = result?.sumQuantity() {
                let waterInML = sum.doubleValue(for: HKUnit.literUnit(with: .milli))
                DispatchQueue.main.async {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    let formattedValue = formatter.string(from: NSNumber(value: Int(waterInML))) ?? "0"
                    self?.hydration = formattedValue
                }
            }
        }

        healthStore.execute(query)
    }

    private func fetchCalories() {
        guard let calorieType = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            if let sum = result?.sumQuantity() {
                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                DispatchQueue.main.async {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    let formattedValue = formatter.string(from: NSNumber(value: Int(calories))) ?? "0"
                    self?.calories = formattedValue
                }
            }
        }

        healthStore.execute(query)
    }

    private func fetchSleep() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let now = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)
        // Look back to yesterday to capture full night's sleep
        let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: yesterday,
            end: now,
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                print("Error fetching sleep data: \(String(describing: error))")
                return
            }
            
            var totalSleepTime: TimeInterval = 0
            var lastSampleEndDate: Date?
            
            for sample in samples {
                // Check for all sleep states using non-deprecated values
                if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                    
                    // Calculate duration for this sleep sample
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    
                    // If this is a continuation of sleep (less than 30 minutes gap)
                    if let lastEnd = lastSampleEndDate,
                       sample.startDate.timeIntervalSince(lastEnd) < 1800 {
                        totalSleepTime += duration
                    } else if lastSampleEndDate == nil {
                        // First sleep sample
                        totalSleepTime += duration
                    } else {
                        // New sleep session
                        totalSleepTime += duration
                    }
                    lastSampleEndDate = sample.endDate
                }
            }
            
            let hours = totalSleepTime / 3600.0
            
            DispatchQueue.main.async {
                // Format as HH:MM
                let totalHours = Int(floor(hours))
                let minutes = Int((hours.truncatingRemainder(dividingBy: 1) * 60))
                self?.sleepHours = String(format: "%02d:%02d", totalHours, minutes)
                print("Sleep duration calculated: \(totalHours)h \(minutes)m from \(samples.count) samples")
                // Sleep goal: 7-9 hours is recommended for adults
                self?.sleepGoalMet = hours >= 7.0
            }
        }
        
        healthStore.execute(query)
    }

    private func fetchMacronutrients() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Fetch protein
        if let proteinType = HKObjectType.quantityType(forIdentifier: .dietaryProtein) {
            let proteinQuery = HKStatisticsQuery(quantityType: proteinType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
                if let sum = result?.sumQuantity() {
                    let proteinGrams = sum.doubleValue(for: .gram())
                    DispatchQueue.main.async {
                        self?.protein = proteinGrams
                    }
                }
            }
            healthStore.execute(proteinQuery)
        }
        
        // Fetch carbs
        if let carbsType = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates) {
            let carbsQuery = HKStatisticsQuery(quantityType: carbsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
                if let sum = result?.sumQuantity() {
                    let carbsGrams = sum.doubleValue(for: .gram())
                    DispatchQueue.main.async {
                        self?.carbs = carbsGrams
                    }
                }
            }
            healthStore.execute(carbsQuery)
        }
        
        // Fetch fats
        if let fatsType = HKObjectType.quantityType(forIdentifier: .dietaryFatTotal) {
            let fatsQuery = HKStatisticsQuery(quantityType: fatsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
                if let sum = result?.sumQuantity() {
                    let fatsGrams = sum.doubleValue(for: .gram())
                    DispatchQueue.main.async {
                        self?.fats = fatsGrams
                    }
                }
            }
            healthStore.execute(fatsQuery)
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
}
