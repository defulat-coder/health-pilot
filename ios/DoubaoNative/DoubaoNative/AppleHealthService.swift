import Foundation

#if canImport(HealthKit)
import HealthKit
#endif

protocol AppleHealthServicing {
    func authorizationState() async -> AppleHealthAuthorizationState
    func requestAuthorization() async throws -> AppleHealthAuthorizationState
    func collectSamples() async throws -> [AppleHealthSamplePayload]
}

struct AppleHealthService: AppleHealthServicing {
    #if canImport(HealthKit)
    private let store = HKHealthStore()
    #endif

    func authorizationState() async -> AppleHealthAuthorizationState {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return .unavailable }
        return .notDetermined
        #else
        return .unavailable
        #endif
    }

    func requestAuthorization() async throws -> AppleHealthAuthorizationState {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return .unavailable }
        let types = readTypes()
        return try await withCheckedThrowingContinuation { continuation in
            store.requestAuthorization(toShare: [], read: types) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success ? .authorized : .sharingDenied)
                }
            }
        }
        #else
        return .unavailable
        #endif
    }

    func collectSamples() async throws -> [AppleHealthSamplePayload] {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return [] }
        let now = Date()
        let start = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        var samples: [AppleHealthSamplePayload] = []

        for descriptor in quantityDescriptors() {
            samples += try await queryQuantitySamples(descriptor: descriptor, start: start, end: now)
        }
        samples += try await querySleepSamples(start: start, end: now)
        samples += try await queryWorkoutSamples(start: start, end: now)
        samples += profileSamples(date: now)
        return samples
        #else
        return []
        #endif
    }

    #if canImport(HealthKit)
    private func readTypes() -> Set<HKObjectType> {
        var types = Set<HKObjectType>()
        quantityDescriptors().compactMap { HKObjectType.quantityType(forIdentifier: $0.identifier) }.forEach {
            types.insert($0)
        }
        types.insert(HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!)
        types.insert(HKObjectType.workoutType())
        types.insert(HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!)
        types.insert(HKObjectType.characteristicType(forIdentifier: .biologicalSex)!)
        return types
    }

    private func quantityDescriptors() -> [QuantityDescriptor] {
        [
            QuantityDescriptor(identifier: .stepCount, type: "step_count", category: "activity", unit: .count(), unitLabel: "count"),
            QuantityDescriptor(identifier: .activeEnergyBurned, type: "active_energy_burned", category: "activity", unit: .kilocalorie(), unitLabel: "kcal"),
            QuantityDescriptor(identifier: .appleExerciseTime, type: "apple_exercise_time", category: "activity", unit: .minute(), unitLabel: "min"),
            QuantityDescriptor(identifier: .bodyMass, type: "body_mass", category: "body", unit: .gramUnit(with: .kilo), unitLabel: "kg"),
            QuantityDescriptor(identifier: .bodyFatPercentage, type: "body_fat_percentage", category: "body", unit: .percent(), unitLabel: "%"),
            QuantityDescriptor(identifier: .height, type: "height", category: "body", unit: .meterUnit(with: .centi), unitLabel: "cm"),
            QuantityDescriptor(identifier: .heartRate, type: "heart_rate", category: "vitals", unit: HKUnit.count().unitDivided(by: .minute()), unitLabel: "count/min"),
            QuantityDescriptor(identifier: .restingHeartRate, type: "resting_heart_rate", category: "vitals", unit: HKUnit.count().unitDivided(by: .minute()), unitLabel: "count/min")
        ]
    }

    private func queryQuantitySamples(descriptor: QuantityDescriptor, start: Date, end: Date) async throws -> [AppleHealthSamplePayload] {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: descriptor.identifier) else { return [] }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let payloads = (results as? [HKQuantitySample] ?? []).map { sample in
                    AppleHealthSamplePayload(
                        type: descriptor.type,
                        category: descriptor.category,
                        unit: descriptor.unitLabel,
                        value: sample.quantity.doubleValue(for: descriptor.unit),
                        source: sample.sourceRevision.source.bundleIdentifier,
                        startAt: sample.startDate,
                        endAt: sample.endDate,
                        metadata: [:]
                    )
                }
                continuation.resume(returning: payloads)
            }
            store.execute(query)
        }
    }

    private func querySleepSamples(start: Date, end: Date) async throws -> [AppleHealthSamplePayload] {
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return [] }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let payloads = (results as? [HKCategorySample] ?? []).compactMap { sample -> AppleHealthSamplePayload? in
                    guard sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                            sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                            sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                            sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue else {
                        return nil
                    }
                    return AppleHealthSamplePayload(
                        type: "sleep_analysis",
                        category: "sleep",
                        unit: "min",
                        value: sample.endDate.timeIntervalSince(sample.startDate) / 60,
                        source: sample.sourceRevision.source.bundleIdentifier,
                        startAt: sample.startDate,
                        endAt: sample.endDate,
                        metadata: ["stage": "\(sample.value)"]
                    )
                }
                continuation.resume(returning: payloads)
            }
            store.execute(query)
        }
    }

    private func queryWorkoutSamples(start: Date, end: Date) async throws -> [AppleHealthSamplePayload] {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let payloads = (results as? [HKWorkout] ?? []).map { workout in
                    AppleHealthSamplePayload(
                        type: "workout",
                        category: "activity",
                        unit: "min",
                        value: workout.duration / 60,
                        source: workout.sourceRevision.source.bundleIdentifier,
                        startAt: workout.startDate,
                        endAt: workout.endDate,
                        metadata: ["activity": "\(workout.workoutActivityType.rawValue)"]
                    )
                }
                continuation.resume(returning: payloads)
            }
            store.execute(query)
        }
    }

    private func profileSamples(date: Date) -> [AppleHealthSamplePayload] {
        var samples: [AppleHealthSamplePayload] = []
        if let birth = try? store.dateOfBirthComponents(),
           let year = birth.year {
            samples.append(AppleHealthSamplePayload(type: "date_of_birth_year", category: "profile", unit: "year", value: Double(year), source: "com.apple.Health", startAt: date, endAt: date, metadata: [:]))
        }
        if let sex = try? store.biologicalSex().biologicalSex.rawValue {
            samples.append(AppleHealthSamplePayload(type: "biological_sex", category: "profile", unit: "code", value: Double(sex), source: "com.apple.Health", startAt: date, endAt: date, metadata: [:]))
        }
        return samples
    }
    #endif
}

#if canImport(HealthKit)
private struct QuantityDescriptor {
    let identifier: HKQuantityTypeIdentifier
    let type: String
    let category: String
    let unit: HKUnit
    let unitLabel: String
}
#endif
