//
//  AudioProcessor.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import Accelerate
import AVFoundation

class AudioProcessor: NSObject {
    private var audioEngine = AVAudioEngine()
    private var fftSetup: FFTSetup?
    private let fftSize = vDSP_Length(4096)
    var maxFrequency: Float = 0.0
    var frequencyMagnitudes: [Float] = []
    
    override init() {
        super.init()
        setupAudio()
    }

    deinit {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        if let fftSetup = fftSetup {
            vDSP_destroy_fftsetup(fftSetup)
        }
    }

    private func setupAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers, .allowBluetooth, .duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }

        guard audioSession.isInputAvailable else {
            print("Audio input not available.")
            return
        }

        configureAudioEngine()
    }

    private func configureAudioEngine() {
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Double(fftSize))), FFTRadix(kFFTRadix2))

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(fftSize), format: inputFormat) { [weak self] (buffer, _) in
            self?.processAudio(buffer: buffer, frameCount: buffer.frameLength, inputFormat: inputFormat)
        }

        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error)")
        }
    }

    private func processAudio(buffer: AVAudioPCMBuffer, frameCount: AVAudioFrameCount, inputFormat: AVAudioFormat) {
        var realp = [Float](repeating: 0, count: Int(frameCount / 2))
        var imagp = [Float](repeating: 0, count: Int(frameCount / 2))
        var splitComplex = DSPSplitComplex(realp: &realp, imagp: &imagp)

        let floatChannelData = buffer.floatChannelData![0]
        floatChannelData.withMemoryRebound(to: DSPComplex.self, capacity: Int(frameCount / 2)) { complexData in
            vDSP_ctoz(complexData, 2, &splitComplex, 1, vDSP_Length(frameCount / 2))
        }

        vDSP_fft_zrip(fftSetup!, &splitComplex, 1, vDSP_Length(log2(Float(frameCount))), FFTDirection(FFT_FORWARD))
        vDSP_zvmags(&splitComplex, 1, &realp, 1, vDSP_Length(frameCount / 2))

        let magnitudes = realp.map { sqrt($0) }
        let maxIndex = magnitudes.indices.max(by: { magnitudes[$0] < magnitudes[$1] }) ?? 0
        maxFrequency = Float(maxIndex) * Float(inputFormat.sampleRate) / Float(fftSize)
        frequencyMagnitudes = magnitudes
    }
}

