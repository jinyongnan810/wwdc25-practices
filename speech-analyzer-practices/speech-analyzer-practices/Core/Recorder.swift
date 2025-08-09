//
//  Recorder.swift
//  speech-analyzer-practices
//
//  Created by Yuunan kin on 2025/07/06.
//

import AVFoundation
import SwiftUI

enum RecorderError: Error {
    case notAuthorized
}

@Observable
class Recorder {
    private let audioEngine: AVAudioEngine
    private let transcriber: Transcriber
    private var outputContinuation: AsyncStream<AVAudioPCMBuffer>.Continuation?
    var story: Binding<Story>
    private let filePath: URL
    var file: AVAudioFile?
    var isSettingUp = false
    var playerNode: AVAudioPlayerNode?

    init(
        story: Binding<Story>,
        transcriber: Transcriber
    ) {
        audioEngine = AVAudioEngine()
        self.transcriber = transcriber
        self.story = story
        filePath = FileManager.default.temporaryDirectory
            .appending(component: UUID().uuidString)
            .appendingPathExtension(for: .wav)
    }

    // Recording
    func startRecording() async throws {
        print("startRecording")
        isSettingUp = true
//        guard await isAuthorized() else {
//            print("unauthorized")
        ////            throw RecorderError.notAuthorized
//        }
        print("authorized")
        story.filePath.wrappedValue = filePath
        print("filePath: \(filePath)")
        #if os(iOS)
            try setUpAudioSession()
            print("set up Audio Session Done")
        #endif
        try await transcriber.setupTranscriber()
        print("set up transcriber done")
        for await input in try await audioStream() {
            if isSettingUp {
                isSettingUp = false
            }
            if story.isDone.wrappedValue {
                break
            }
            print("received audio input: \(input)")
            // Step 3. receive buffer from stream
            try await transcriber.streamAudioToTranscriber(input)
        }
    }

    func pauseRecording() {
        audioEngine.pause()
        print("paused recording")
    }

    func resumeRecording() throws {
        try audioEngine.start()
        print("resumed recording")
    }

    func stopRecording() async throws {
        audioEngine.stop()
        story.isDone.wrappedValue = true

        try await transcriber.finishTranscribing()

        Task {
            self.story.title.wrappedValue = try await story.wrappedValue.suggestedTitle() ?? "Apple Intelligence not available."
        }
        print("stopped recording. title: \(story.title.wrappedValue)")
    }

    // Audio Session
    #if os(iOS)
        func setUpAudioSession() throws {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
    #endif
    func isAuthorized() async -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            return true
        }
        return await AVCaptureDevice.requestAccess(for: .audio)
    }

    // Audio Engine
    private func setupAudioEngine() throws {
        print("set up audio engine, filepath: \(filePath)")
        let inputSettings = audioEngine.inputNode.inputFormat(forBus: 0).settings
        file = try AVAudioFile(forWriting: filePath,
                               settings: inputSettings)

        audioEngine.inputNode.removeTap(onBus: 0)
    }

    private func audioStream() async throws -> AsyncStream<AVAudioPCMBuffer> {
        print("audioStream")

        return AsyncStream(AVAudioPCMBuffer.self, bufferingPolicy: .unbounded) {
            continuation in
            print("outputContinuation set")
            outputContinuation = continuation
            try? setupAudioEngine()
            print("set up audio engine done")
            // Step 1. Intercept raw audio from microphone
            // Fires Closure everytime buffer is full.
            audioEngine.inputNode.installTap(onBus: 0,
                                             bufferSize: 4096,
                                             format: audioEngine.inputNode.outputFormat(forBus: 0))
            { [weak self] buffer, _ in
                guard let self else { return }
                if story.isDone.wrappedValue {
                    return
                }
                // Step 2-1. write buffer to disk
                writeBufferToDisk(buffer: buffer)
                // Step 2-2. streams buffer for further processing
                outputContinuation?.yield(buffer)
                print("write buffer to disk and yield. outputContiuation: \(String(describing: outputContinuation))")
            }

            audioEngine.prepare()
            try? audioEngine.start()
            print("started audio engine")
        }
    }

    func writeBufferToDisk(buffer: AVAudioPCMBuffer) {
        do {
            try file?.write(from: buffer)
        } catch {
            print("file writing error: \(error)")
        }
    }

    /// For playback
    func playRecording() {
        guard let file else {
            return
        }

        playerNode = AVAudioPlayerNode()
        guard let playerNode else {
            return
        }

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode,
                            to: audioEngine.outputNode,
                            format: file.processingFormat)

        playerNode.scheduleFile(file,
                                at: nil,
                                completionCallbackType: .dataPlayedBack)
        { _ in
        }

        do {
            try audioEngine.start()
            playerNode.play()
        } catch {
            print("error")
        }
    }

    func stopPlaying() {
        audioEngine.stop()
    }
}

extension AVAudioPlayerNode {
    var currentTime: TimeInterval {
        guard let nodeTime: AVAudioTime = lastRenderTime, let playerTime: AVAudioTime = playerTime(forNodeTime: nodeTime) else { return 0 }

        return Double(playerTime.sampleTime) / playerTime.sampleRate
    }
}
