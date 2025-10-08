//
//  CardiacAlarmApp.swift
//  CardiacAlarm Watch App
//
//  Created by Rajeev TC on 2025/09/24.
//

import SwiftUI
import LocalAuthentication

@main
struct CardiacAlarm_Watch_AppApp: App {
    @StateObject var workoutManager = WorkoutManager()
    var body: some Scene {
        WindowGroup {
            TopPagingView()
                .environmentObject(workoutManager)
        }
    }
}
