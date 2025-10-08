//
//  CriticalSlider.swift
//  CardiacAlarm Watch App
//
//  Created by Rajeev TC on 2025/10/07.
//

import SwiftUI

struct CriticalSlider: View {

    @EnvironmentObject var workoutManager: WorkoutManager

    @State private var dragOffset: CGFloat = 0
    @State private var activated = false

    let sliderWidth: CGFloat = 120
    let circleSize: CGFloat = 38

    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            RoundedRectangle(cornerRadius: circleSize / 2)
                .fill(Color.secondary.opacity(0.4))
                .frame(width: sliderWidth + circleSize, height: circleSize)

            // Label text
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 2) {
                    Text("EMERGENCY")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.leading, 20)
                    Text("CALL")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.leading, 25)
                }
                .foregroundColor(.white)
                .opacity(activated ? 0.3 : 1.0)
                Spacer()
            }
            .frame(width: sliderWidth + circleSize, height: circleSize)

            // Draggable SOS button
            Circle()
                .fill(activated ? Color.green : Color.red)
                .overlay(
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(.white)
                )
                .frame(width: circleSize, height: circleSize)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !activated {
                                dragOffset = max(0, min(value.translation.width, sliderWidth))
                            }
                        }
                        .onEnded { _ in
                            if dragOffset > sliderWidth * 0.6 {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    activated = true
                                    dragOffset = sliderWidth
                                }
                                // Trigger SOS action here
                                WKInterfaceDevice.current().play(.success)
                                CriticalAudioPlayer.shared.stop()
                                workoutManager.endSession()
                            } else {
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
        }
        .frame(height: circleSize)
        .padding()
        .background(Color.black)
        .cornerRadius(16)
        .animation(.easeInOut, value: activated)
    }
}

#Preview {
    CriticalSlider()
}
