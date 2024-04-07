import Foundation
import HealthKit

enum HealthKitManagerError: Error {
    case invalidSamples
}

final class HealthKitManager: NSObject {

    static let shared = HealthKitManager()

    private override init() {
        super.init()
    }

    private let healthStore = HKHealthStore()

    func sleepData(forStartDate startDate: Date, endDate: Date) async throws -> [HKCategorySample] {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { (query, results, error) in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = results as? [HKCategorySample] else {
                    continuation.resume(throwing: HealthKitManagerError.invalidSamples)
                    return
                }

                continuation.resume(returning: samples)
            }

            healthStore.execute(query)
        }
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let typesToRead: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKCategoryType.categoryType(forIdentifier: .mindfulSession)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryProtein)!,
            HKQuantityType.quantityType(forIdentifier: .dietarySugar)!,
        ]

        healthStore.requestAuthorization(
            toShare: nil,
            read: typesToRead
        ) { (success, error) in
            completion(success)
        }
    }
}
