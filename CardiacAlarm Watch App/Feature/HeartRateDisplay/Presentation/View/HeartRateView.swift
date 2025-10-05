//
//  HeartRateView.swift
//  CardiacAlarm Watch App
//
//  Created by Rajeev TC on 2025/09/24.
//

import SwiftUI

struct HeartRateView: View {

    @StateObject var vm: HeartRateViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Heart Rate")
                    .foregroundStyle(.red)
                    .font(.caption)
                Image(systemName: "heart.fill")
                    .imageScale(.large)
                    .foregroundStyle(.red)
                    .font(.title)
                HStack(alignment: .top) {
                    Text("\(Int(vm.currentBPM))")
                        .font(.system(size: 60))
                        .padding(.top, -10)
                    Text("BPM")
                        .foregroundStyle(.red)
                        .font(.caption2)
                }
                Spacer()
            }
            Spacer()
        }
        .padding([.leading, .top], 20)
        .ignoresSafeArea()
        .onAppear(perform: {
            Task {
                await vm.startForegroundMonitoring()
            }
        })
    }
}

#Preview {
    HeartRateView(
        vm: HeartRateViewModel(
            useCase: HeartRateMonitoringUseCase(heartRateRepo: HeartRateRealTimeRepository()))
    )}
