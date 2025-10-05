//
//  HeartRateViewModel.swift
//  CardiacAlarm
//
//  Created by Rajeev TC on 2025/10/01.
//

import SwiftUICore
import Combine

class HeartRateViewModel: ObservableObject {
    @Published var currentBPM: Double = 0
    @Published var lastUpdated: Date = Date()

    private let useCase: HeartRateMonitoringUseCase
    private var cancellables = Set<AnyCancellable>()

    init(useCase: HeartRateMonitoringUseCase) {
        self.useCase = useCase

        useCase.heartRatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sample in
                self?.currentBPM = sample.bpm
                self?.lastUpdated = sample.date
            }
            .store(in: &cancellables)
    }


    @MainActor
    func startForegroundMonitoring() async {
        await useCase.startLiveMonitoring()
    }

    @MainActor
    func stopForegroundMonitoring() async {
        await useCase.stopLiveMonitoring()
    }
}
