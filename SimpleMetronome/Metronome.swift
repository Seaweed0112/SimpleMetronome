import Foundation
import AVFoundation
import Combine

extension Notification.Name {
    static let metronomeDidRestart = Notification.Name("metronomeDidRestart")
}

class Metronome: ObservableObject {
    @Published var bpm: Double = 180.0
    private var timer: DispatchSourceTimer?
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    private var bpmSubscriber: AnyCancellable?

    init() {
        prepareSound()
        setupBPMSubscriber()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil)
    }

    func start() {
        isPlaying = true
        updateTimer()
    }

    func stop() {
        isPlaying = false
        timer?.cancel()
        timer = nil
    }

    private func setupBPMSubscriber() {
           bpmSubscriber = $bpm
               .receive(on: DispatchQueue.main)
               .sink { [weak self] newBpm in
                   guard let self = self else { return }
                   if self.isPlaying {
                       self.updateTimer()
                       // Notify that the metronome has restarted
                       NotificationCenter.default.post(name: .metronomeDidRestart, object: nil)
                   }
               }
       }
    private func updateTimer() {
        timer?.cancel()
        timer = nil
        let interval = 60.0 / bpm

        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: interval)
        timer?.setEventHandler { [weak self] in
            self?.playTick()
        }
        timer?.resume()
    }

    private func prepareSound() {
        guard let url = Bundle.main.url(forResource: "tick", withExtension: "mp3") else {
            print("Tick sound file not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to initialize audio player: \(error.localizedDescription)")
        }
    }

    private func playTick() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }

    @objc private func handleInterruption(notification: Notification) {
        // Handle audio interruptions
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Interruption began, pause the metronome
            stop()
        } else if type == .ended {
            // Interruption ended, resume the metronome if needed
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    start()
                }
            }
        }
        
    }
}
