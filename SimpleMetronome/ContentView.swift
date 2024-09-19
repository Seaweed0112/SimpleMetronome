import SwiftUI

struct ContentView: View {
    @StateObject var metronome = Metronome()
    @State private var isPlaying = false

    // Variables for elapsed time
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 40) {
            Text("Metronome")
                .font(.largeTitle)
                .padding()

            VStack {
                // Display the elapsed time
                Text("Time Elapsed: \(formattedTime(elapsedTime))")
                    .font(.title2)
                    .padding()

                Text("BPM: \(Int(metronome.bpm))")
                    .font(.title2)
                Slider(value: $metronome.bpm, in: 40...240, step: 1)
                    .padding(.horizontal)
            }

            Button(action: {
                if isPlaying {
                    metronome.stop()
                    stopTimer()
                } else {
                    metronome.start()
                    startTimer()
                }
                isPlaying.toggle()
            }) {
                Text(isPlaying ? "Stop" : "Start")
                    .font(.title2)
                    .frame(width: 150, height: 50)
                    .background(isPlaying ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: .metronomeDidRestart)) { _ in
            // Reset the elapsed time when the metronome restarts
            resetTimer()
        }
        .onDisappear {
            // Ensure the timer is stopped when the view disappears
            stopTimer()
        }
    }

    // Function to format time interval into mm:ss
    func formattedTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Start the elapsed time timer
    func startTimer() {
        elapsedTime = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    // Stop the elapsed time timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Reset the timer
    func resetTimer() {
        stopTimer()
        elapsedTime = 0
        if isPlaying {
            startTimer()
        }
    }
}
