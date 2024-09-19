//
//  MetronomeApp.swift
//  My Metronome
//
//  Created by Cedric Zheng on 2024/9/13.
//


import SwiftUI
import AVFoundation

@main
struct MetronomeApp: App {
    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    func configureAudioSession() {
        do {
            // Set the audio session category to playback with the mixWithOthers option
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers )
            // Activate the audio session
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
    }
}
