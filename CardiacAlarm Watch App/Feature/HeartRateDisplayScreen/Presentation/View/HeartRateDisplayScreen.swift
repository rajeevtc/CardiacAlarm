//
//  HeartRateDisplayScreen.swift
//  CardiacAlarm Watch App
//
//  Created by Rajeev TC on 2025/09/24.
//

import SwiftUI

struct HeartRateDisplayScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Heart Rate")
                .foregroundStyle(.red)
                .font(.caption)
            Image(systemName: "heart.fill")
                .imageScale(.large)
                .foregroundStyle(.red)
                .font(.title)
            HStack(alignment: .top) {
                Text("58")
                    .font(.system(size: 60))
                    .padding(.top, -10)
                Text("BPM")
                    .foregroundStyle(.red)
                    .font(.caption2)
            }
        }
        .padding()
    }
}

#Preview {
    HeartRateDisplayScreen()
}
