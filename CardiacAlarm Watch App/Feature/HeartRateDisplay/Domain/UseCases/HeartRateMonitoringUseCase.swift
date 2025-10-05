//
//  HeartRateMonitoringUseCase.swift
//  CardiacAlarm
//
//  Created by Rajeev TC on 2025/10/01.
//

import Combine

class HeartRateMonitoringUseCase {

    private let heartRateRepo: HeartRateRealTimeRepositoryType
    private let threshold: Double = 25.0
    private var cancellables = Set<AnyCancellable>()

    // public publisher for UI/other modules
    let heartRatePublisher = PassthroughSubject<HeartRateSample, Never>()

    init(heartRateRepo: HeartRateRealTimeRepositoryType) {
        self.heartRateRepo = heartRateRepo

        heartRateRepo.heartRatePublisher
            .sink { [weak self] sample in
                self?.evaluate(sample)
                self?.heartRatePublisher.send(sample)
            }
            .store(in: &cancellables)
    }

    private func evaluate(_ sample: HeartRateSample) {
        // trigger alarm for critical low HR
        if sample.bpm <= threshold {
            Task {
                await self.triggerCriticalAlarm(sample: sample)
            }
        }
    }

    func triggerCriticalAlarm(sample: HeartRateSample) async {

    }

    // Foreground control
    func startLiveMonitoring() async {
        do {
            try await heartRateRepo.startLiveWorkoutMonitoring()
        } catch {
            print("Failed to start workout monitoring: \(error)")
        }
    }

    func stopLiveMonitoring() async {
        await heartRateRepo.stopLiveWorkoutMonitoring()
    }
}
