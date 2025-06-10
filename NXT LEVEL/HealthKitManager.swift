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
    @Published var stepCount: String = "--"
    @Published var hydration: String = "--"
    @Published var calories: String = "--"

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
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
        fetchSteps()
        fetchHydration()
        fetchCalories()
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
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
}
