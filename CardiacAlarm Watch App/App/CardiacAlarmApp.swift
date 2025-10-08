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
    @Environment(\.scenePhase) private var scenePhase

    @StateObject var workoutManager = WorkoutManager()
    var body: some Scene {
        WindowGroup {
            TopPagingView()
                .environmentObject(workoutManager)
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background:
                if !isWatchStillUnlocked() {
                    print("🔒 Watch removed from wrist — stopping tracking")
                    workoutManager.endSession()
                } else {
                    workoutManager.startLiveWorkoutMonitoring()
                }
            default:
                break
            }
        }
    }

    func isWatchStillUnlocked() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
}
