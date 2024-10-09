import SwiftUI
import Combine
import AVFoundation
import Sliders

let url = Bundle.main.url(forResource: "metronome", withExtension: "mp3")

struct ContentView: View {
    @State private var bpm: Double = 120
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State private var isPlaying: Bool = false
    
    @State private var players: [AVAudioPlayer] = []
    
    var body: some View {
        VStack {
            Text("\(Int(bpm))")
                .font(.system(size: 108))
            +
            Text("BPM")
                .font(.title)
        }
        .safeAreaInset(edge: .bottom) {
            Slider(value: $bpm, in: 1...360, step: 1, label: {}) { isEditting in
                print(isEditting)
                guard !isEditting else { return }
                setTimer()
                isPlaying = true
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(timer ?? Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard isPlaying,
                  let url,
                  let player = try? AVAudioPlayer(contentsOf: url) else {
                print(isPlaying)
                return
            }
            players.append(player)
            
            player.prepareToPlay()
            player.play()
        }
        .background {
            Color.white
                .onTapGesture {
                    setTimer()
                    isPlaying.toggle()
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    
                    if isPlaying {}
                    else {
                        stopTimer()
                    }
                }
        }
    }
    
    private func setTimer() {
        let interval = 60.0 / bpm
        timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
    }
    
    private func stopTimer() {
        players = []
    }
}
