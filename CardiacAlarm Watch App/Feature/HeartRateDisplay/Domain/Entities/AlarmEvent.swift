//
//  AlarmEvent.swift
//  CardiacAlarm
//
//  Created by Rajeev TC on 2025/10/03.
//

import Foundation

struct AlarmEvent: Identifiable {
    let id: UUID
    let bpm: Double
    let date: Date
    let note: String?
}
