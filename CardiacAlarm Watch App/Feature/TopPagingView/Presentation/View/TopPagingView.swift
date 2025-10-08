//
//  TopPagingView.swift
//  CardiacAlarm Watch App
//
//  Created by Rajeev TC on 2025/10/05.
//

import SwiftUI

enum Tab {
    case controls, metrics
}

struct TopPagingView: View {
    @State private var selection: Tab = .metrics

    var body: some View {
        TabView(selection: $selection) {
            ControlsView(selection: $selection)
                .tag(Tab.controls)
            HeartRateView()
                .tag(Tab.metrics)
        }
    }
}

#Preview {
    TopPagingView()
        .environmentObject(WorkoutManager())
}
