//
//  CriticalAudioPlayer.swift
//  CardiacAlarm
//
//  Created by Rajeev TC on 2025/10/07.
//

import Foundation
import AVFoundation
import WatchKit

final class CriticalAudioPlayer: NSObject, ObservableObject {
    static let shared = CriticalAudioPlayer()

    private var audioPlayer: AVAudioPlayer?

    private override init() {}

    /// Plays a bundled sound file.
    /// - Parameters:
    ///   - name: File name (without extension)
    ///   - ext: File extension, e.g. "wav" or "m4a"
    ///   - loop: Whether to loop indefinitely
    func playSound(named name: String = "cardiacalarm-critical", ext: String = "wav", loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("❌ Sound file \(name).\(ext) not found in bundle.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = loop ? -1 : 0  // -1 = infinite loop
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            // Optional haptic feedback
            WKInterfaceDevice.current().play(.notification)

            print("🔊 Playing sound: \(name).\(ext)")
        } catch {
            print("❌ Failed to play sound: \(error.localizedDescription)")
        }
    }

    /// Stops any playing sound
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        print("⏹️ Sound stopped.")
    }
}

