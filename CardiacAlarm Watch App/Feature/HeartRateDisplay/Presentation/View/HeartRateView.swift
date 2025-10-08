//
//  HeartRateView.swift
//  CardiacAlarm Watch App
//
//  Created by Rajeev TC on 2025/09/24.
//

import SwiftUI

struct HeartRateView: View {

    @EnvironmentObject var workoutManager: WorkoutManager

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
                    Text(workoutManager.heartRate.formatted(
                        .number.precision(.fractionLength(0))
                    ))
                    .font(.system(size: 60))
                    .padding(.top, -10)
                    Text("BPM")
                        .foregroundStyle(.red)
                        .font(.caption2)
                }
                if workoutManager.triggerCriticalAlarm {
                    CriticalSlider()
                        .padding(.horizontal, 1)
                        .padding(.bottom, 20)
                }
                Spacer()
            }
            Spacer()
        }
        .padding([.leading, .top], 20)
        .ignoresSafeArea()
        .onChange(of: workoutManager.triggerCriticalAlarm) { _, newValue in
            playCriticalAlarm(isOn: newValue)
        }
        .onChange(of: workoutManager.isWorn) { _, newValue in
            handleUserWatchWornOnOff(isOn: newValue)
        }
        .onAppear(perform: {
            Task {
                workoutManager.requestAuthorization()
            }
        })
    }

    private func playCriticalAlarm(isOn: Bool) {
        if isOn {
            CriticalAudioPlayer.shared.playSound()
        } else {
            CriticalAudioPlayer.shared.stop()
        }
    }

    private func handleUserWatchWornOnOff(isOn: Bool) {
        if isOn {
            workoutManager.startLiveWorkoutMonitoring()
        } else {
            workoutManager.endWorkout()
        }
    }
}

#Preview {
    HeartRateView()
        .environmentObject(WorkoutManager())
}
