import Foundation
import AVFoundation
import Combine

@MainActor
final class VoiceRecorder: NSObject, ObservableObject {
    enum State: Equatable {
        case idle
        case recording
        case recorded
        case playing
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var durationSeconds: Double = 0
    @Published private(set) var errorMessage: String?

    private let maxDurationSeconds: Double

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?

    private(set) var recordedTempURL: URL?

    init(maxDurationSeconds: Double = 30) {
        self.maxDurationSeconds = maxDurationSeconds
        super.init()
    }

    func reset() {
        stopAll()
        if let url = recordedTempURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordedTempURL = nil
        durationSeconds = 0
        errorMessage = nil
        state = .idle
    }

    func startRecording() {
        errorMessage = nil
        stopAll()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try session.setActive(true)

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("sj_voice_\(UUID().uuidString)")
                .appendingPathExtension("m4a")

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let rec = try AVAudioRecorder(url: url, settings: settings)
            rec.delegate = self
            rec.isMeteringEnabled = false
            rec.prepareToRecord()

            recorder = rec
            recordedTempURL = url
            durationSeconds = 0

            // Graba y auto-corta a los 30s.
            rec.record(forDuration: maxDurationSeconds)
            state = .recording
        } catch {
            errorMessage = String(describing: error)
            state = .idle
        }
    }

    func stopRecording() {
        guard state == .recording else { return }
        recorder?.stop()
        recorder = nil
        state = .recorded
        updateDurationFromFile()

        // Liberamos sesión (best-effort)
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    func togglePlayback() {
        errorMessage = nil

        switch state {
        case .playing:
            player?.stop()
            player = nil
            state = .recorded
        case .recorded:
            guard let url = recordedTempURL else { return }
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetoothHFP])
                try session.setActive(true)

                let p = try AVAudioPlayer(contentsOf: url)
                p.delegate = self
                p.prepareToPlay()
                player = p
                p.play()
                state = .playing
            } catch {
                errorMessage = String(describing: error)
                state = .recorded
            }
        default:
            return
        }
    }

    private func stopAll() {
        if state == .recording {
            recorder?.stop()
        }
        recorder = nil

        if state == .playing {
            player?.stop()
        }
        player = nil

        // No forzamos state aquí; quien llame decide.
    }

    private func updateDurationFromFile() {
        guard let url = recordedTempURL else { return }
        do {
            let file = try AVAudioFile(forReading: url)
            let frames = Double(file.length)
            let rate = file.processingFormat.sampleRate
            if rate > 0 {
                durationSeconds = frames / rate
            }
        } catch {
            // best-effort
        }
    }
}

extension VoiceRecorder: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            self.recorder = nil
            self.state = .recorded
            self.updateDurationFromFile()
        }
    }
}

extension VoiceRecorder: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.player = nil
            self.state = .recorded
            try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        }
    }
}
