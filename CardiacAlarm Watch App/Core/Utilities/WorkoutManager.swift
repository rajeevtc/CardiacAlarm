//
//  WorkoutManager.swift
//  CardiacAlarm Watch App
//
//  Created by Rajeev TC on 2025/10/05.
//

import Foundation
import HealthKit
import WatchKit
import SwiftUI

final class WorkoutManager: NSObject, ObservableObject {

    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    @Published var heartRate: Double = 0
    @Published var isActive = false
    @Published var isAuthorized = false
    @Published var sessionState: HKWorkoutSessionState = .notStarted
    @Published var triggerCriticalAlarm = false

    // Critical HeartRate Threshold
    private let criticalHeartRateThreshold: Double = 60.0 // The threshold for the critical alarm

    // MARK: - Requests necessary HealthKit authorization.

    @MainActor
    func requestAuthorization() {

        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
                isAuthorized = true
                startLiveWorkoutMonitoring()
            } catch {
                isAuthorized = false
            }
        }
    }

    // MARK: - Live Workout Monitoring (foreground, per-second)

    @MainActor
    func startLiveWorkoutMonitoring() {

        guard isAuthorized else {
            requestAuthorization()
            return
        }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other // Use .other for general monitoring
        configuration.locationType = .unknown // No GPS needed

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = workoutSession?.associatedWorkoutBuilder()
        } catch {
            print("Could not create workout session: \(error.localizedDescription)")
            return
        }

        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )

        // Set delegates
        workoutSession?.delegate = self
        builder?.delegate = self

        // Start the workout session and begin data collection
        let start = Date()
        workoutSession?.startActivity(with: start)
        builder?.beginCollection(withStart: start) { [weak self] success, error in
            guard success, let self = self else {
                print("Error beginning collection: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("Started Activity collection")
            DispatchQueue.main.async {
                self.sessionState = .running
            }
        }
    }

    /// Ends the workout session and saves the data.
    func endSession() {
        guard
            let session = workoutSession,
            let builder = builder,
            sessionState == .running
        else {
            return
        }

        session.stopActivity(with: Date())
        session.end()

        triggerCriticalAlarm = false
        heartRate = 0

        // End collection and save the workout
        builder.endCollection(withEnd: Date()) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.builder?.finishWorkout { _, error in
                    self?.sessionState = .ended
//                    self?.heartRate = 0
//                    self?.triggerCriticalAlarm = false
                    self?.builder = nil
                    self?.workoutSession = nil
                }
            }
        }
    }

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
//                let averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.triggerCriticalAlarm = self.heartRate <= self.criticalHeartRateThreshold && self.heartRate != 0
            default:
                return
            }
        }
    }
}

// Mark: - State Control
extension WorkoutManager {

    func pause() {
        isActive = false
        workoutSession?.pause()
    }

    func resume() {
        isActive = true
        workoutSession?.resume()
    }

    func togglePause() {
        if isActive {
            pause()
        } else {
            resume()
        }
    }

    @MainActor
    func endWorkout() {
        endSession()
    }
}

// Mark: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async { [weak self] in
            print("Is Active \(toState == .running)")
            self?.isActive = toState == .running
        }

        if toState == .ended {
            print("Is Ended workout")
            builder?.endCollection(withEnd: date, completion: { [weak self] success, error in
                self?.builder?.finishWorkout(completion: { workout, error in
                })
                self?.builder = nil
                self?.workoutSession = nil
            })
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
        DispatchQueue.main.async {
            self.sessionState = .notStarted
            self.heartRate = 0
            self.builder = nil
            self.workoutSession = nil
        }
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }
            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
}
