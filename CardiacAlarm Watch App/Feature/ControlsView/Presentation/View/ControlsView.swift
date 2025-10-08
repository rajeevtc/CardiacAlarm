//
//  ControlsView.swift
//  CardiacAlarm Watch App
//
//  Created by Rajeev TC on 2025/10/05.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var selection: Tab

    var body: some View {
        HStack {
            VStack {
                Button {
                    workoutManager.endWorkout()
                    selection = .metrics
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(Color.red)
                .font(.title2)
                Text("End")
            }
//            VStack {
//                Button {
//                    workoutManager.togglePause()
//                } label: {
//                    Image(systemName: workoutManager.isActive ? "pause": "play")
//                }
//                .tint(Color.yellow)
//                .font(.title2)
//                Text(workoutManager.isActive ? "Pause": "Resume")
//            }
        }
    }
}

#Preview {
    ControlsView(selection: .constant(.controls))
        .environmentObject(WorkoutManager())
}
