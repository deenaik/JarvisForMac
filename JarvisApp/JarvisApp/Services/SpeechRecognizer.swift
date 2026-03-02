import Foundation
import Speech
import AVFoundation

/// Push-to-talk speech recognizer using SFSpeechRecognizer + AVAudioEngine.
@MainActor
final class SpeechRecognizer: ObservableObject {
    @Published var transcript = ""
    @Published var isListening = false
    @Published var audioLevel: Float = 0

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?
    private let silenceTimeout: TimeInterval = 2.0

    var onTranscriptionComplete: ((String) -> Void)?

    func requestPermissions() async -> Bool {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        guard speechStatus == .authorized else { return false }

        let audioStatus: Bool
        if #available(macOS 14.0, *) {
            audioStatus = await AVAudioApplication.requestRecordPermission()
        } else {
            audioStatus = true // pre-14, permission is handled by entitlement
        }

        return audioStatus
    }

    func startListening() {
        guard let speechRecognizer, speechRecognizer.isAvailable else { return }
        guard !isListening else { return }

        transcript = ""

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        // Prefer on-device recognition
        if speechRecognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }

                if let result {
                    self.transcript = result.bestTranscription.formattedString
                    self.resetSilenceTimer()
                }

                if error != nil || (result?.isFinal ?? false) {
                    self.stopListening()
                    if !self.transcript.isEmpty {
                        self.onTranscriptionComplete?(self.transcript)
                    }
                }
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            request.append(buffer)

            // Calculate audio level for waveform
            let channelData = buffer.floatChannelData?[0]
            let frames = buffer.frameLength
            if let data = channelData {
                var sum: Float = 0
                for i in 0..<Int(frames) {
                    sum += abs(data[i])
                }
                let avg = sum / Float(frames)
                Task { @MainActor in
                    self?.audioLevel = min(avg * 25, 1.0) // Normalize
                }
            }
        }

        recognitionRequest = request

        do {
            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
        } catch {
            NSLog("Audio engine failed to start: \(error)")
        }
    }

    func stopListening() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
        audioLevel = 0
    }

    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceTimeout, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.stopListening()
                if let self, !self.transcript.isEmpty {
                    self.onTranscriptionComplete?(self.transcript)
                }
            }
        }
    }
}
