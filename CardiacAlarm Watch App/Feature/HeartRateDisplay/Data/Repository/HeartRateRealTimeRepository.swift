//
//  HeartRateRealTimeRepository.swift
//  CardiacAlarm
//
//  Created by Rajeev TC on 2025/10/01.
//

import HealthKit
import Combine

protocol HeartRateRealTimeRepositoryType {
    // publishers produce HeartRateSample when new HR arrives
    var heartRatePublisher: AnyPublisher<HeartRateSample, Never> { get }

    // start continuous (workout) monitoring
    func startLiveWorkoutMonitoring() async throws
    func stopLiveWorkoutMonitoring() async
}

final class HeartRateRealTimeRepository: NSObject, HeartRateRealTimeRepositoryType {
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    private let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    private let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())

    private var observerQuery: HKObserverQuery?

    // subject to send HR samples
    private let hrSubject = PassthroughSubject<HeartRateSample, Never>()
    var heartRatePublisher: AnyPublisher<HeartRateSample, Never> {
        hrSubject.eraseToAnyPublisher()
    }

    // MARK: - Permissions
    func requestAuthorization() async throws {
        let types: Set = [heartRateType]
        let _: Void = try await withCheckedThrowingContinuation(
            // This ensures the block runs on the main thread, satisfying HealthKit's requirement.
            isolation: MainActor.shared
        ) { continuation in
            healthStore.requestAuthorization(toShare: [], read: types) { success, error in
                // The rest of your logic is correct:
                // 2. You resume the continuation exactly once on all paths.
                if let e = error {
                    print("Failure start HR 1st")
                    continuation.resume(throwing: e)
                    return
                }

                if success {
                    print("success start HR")
                    continuation.resume(returning: ())
                } else {
                    print("Failure start HR 2nd")
                    continuation.resume(throwing: NSError(domain: "HKAuth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authorization denied."]))
                }
            }
        }
    }

    // MARK: - Live Workout Monitoring (foreground, per-second)

    func startLiveWorkoutMonitoring() async throws {
        // ensure permission
        try await requestAuthorization()

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor

        workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        guard let session = workoutSession else { return }

        builder = session.associatedWorkoutBuilder()
        guard let builder = builder else { return }

        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        session.delegate = self
        builder.delegate = self

        let start = Date()
        builder.beginCollection(withStart: start) { [weak self] success, error in
            if success {
                print("Builder startActivity start: \(start)")
                session.startActivity(with: start)
                // request frequent statistics
            } else if let e = error {
                print("Builder beginCollection error: \(e)")
            }
        }
    }

    func stopLiveWorkoutMonitoring() async {
        guard let session = workoutSession, let builder = builder else { return }
        session.stopActivity(with: Date())
        session.end()
        builder.endCollection(withEnd: Date()) { _, _ in
            builder.finishWorkout { _,_  in }
        }
        workoutSession = nil
        self.builder = nil
    }
}

// MARK: - HKWorkoutSessionDelegate + HKLiveWorkoutBuilderDelegate

extension HeartRateRealTimeRepository: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // handle state change
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error)")
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // not needed here
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        if types.contains(heartRateType) {
            // read the most recent quantity from builder
            if let stats = workoutBuilder.statistics(for: heartRateType),
               let quantity = stats.mostRecentQuantity() {
                let bpm = quantity.doubleValue(for: heartRateUnit)
                let sample = HeartRateSample(bpm: bpm, date: Date())
                hrSubject.send(sample)
            }
        }
    }
}
