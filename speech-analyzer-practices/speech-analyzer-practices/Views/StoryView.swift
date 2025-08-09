//
//  StoryView.swift
//  speech-analyzer-practices
//
//  Created by Yuunan kin on 2025/07/05.
//

import SwiftUI
internal import CoreMedia

 User
 │
 │ 1. Tap "Record"
 ▼
 Recorder.startRecording()
 │
 │──► Sets up AVAudioEngine
 │──► Calls transcriber.setupTranscriber()
 │        │
 │        │──► Sets up SpeechTranscriber + SpeechAnalyzer
 │        │──► Creates AsyncStream (inputSequence, inputBuilder)
 │        │──► Starts listening for results in background task
                                    │
                                    │──► For each audio buffer:
                                        │       │
                                    │       │──► writeBufferToDisk(buffer)
                                    │       │──► Calls transcriber.streamAudioToTranscriber(buffer)
                                    │                │
                                    │                │──► Converts buffer format
                                    │                │──► Wraps in AnalyzerInput
                                    │                │──► inputBuilder.yield(input)
                                    │
                                    │
                                    ▼
                                    Transcriber
                                    │
                                    │──► SpeechAnalyzer consumes inputSequence
                                    │──► SpeechTranscriber produces results
                                    │──► For each result:
                                        │        │
                                    │        │──► If final:
                                        │        │      Append to finalizedTranscript
                                    │        │      Update Story
                                    │        │   Else:
                                        │        │      Update volatileTranscript
                                    │
                                    ▼
                                    [UI updates with transcript]

struct StoryView: View {
    @Binding var story: Story
    @State var recorder: Recorder
    @State var transcriber: Transcriber
    @State var isRecording: Bool = false

    @State var isPlaying = false
    @State var currentPlaybackTime = 0.0
    @State var timer: Timer?

    init(story: Binding<Story>) {
        let transcriber = Transcriber(story: story)
        _story = story
        self.transcriber = transcriber
        recorder = Recorder(story: story, transcriber: transcriber)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if !story.isDone {
                    Text(transcriber.finalizedTranscript + transcriber.volatileTranscript)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(attributedStringWithCurrentValueHighlighted(attributedString: story.storyBrokenUpByLines()))
                        .font(.title)
                }
                Spacer()
            }.padding()
        }

        .navigationTitle(Text(story.title))
        .toolbar {
            ToolbarItem {
                Button {
                    isRecording.toggle()
                } label: {
                    if recorder.isSettingUp {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .symbolEffect(
                                .rotate,
                                options: .repeat(.continuous),
                            )
                    } else if isRecording {
                        Label("Stop", systemImage: "pause.fill").tint(.red)
                    } else {
                        Label("Record", systemImage: "record.circle").tint(.red)
                    }
                }
                .disabled(story.isDone || recorder.isSettingUp)
            }
            ToolbarItem {
                Button {
                    isPlaying.toggle()
                    if isPlaying {
                        recorder.playRecording()
                        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                            currentPlaybackTime = recorder.playerNode?.currentTime ?? 0.0
                        }
                    } else {
                        recorder.stopPlaying()
                        currentPlaybackTime = 0.0
                        timer = nil
                    }
                } label: {
                    Label("Play", systemImage: isPlaying ? "pause.fill" : "play").foregroundStyle(.blue).font(.title)
                }
                .disabled(!story.isDone)
            }
        }
        .onChange(of: isRecording) { _, newValue in
            Task {
                if newValue {
                    try? await recorder.startRecording()
                } else {
                    try? await recorder.stopRecording()
                }
            }
        }
    }

    func attributedStringWithCurrentValueHighlighted(attributedString: AttributedString) -> AttributedString {
        var copy = attributedString
        for run in copy.runs {
            if shouldBeHighlighted(attributedStringRun: run) {
                let range = run.range
                copy[range].backgroundColor = .mint.opacity(0.2)
            }
        }
        return copy
    }

    func shouldBeHighlighted(attributedStringRun: AttributedString.Runs.Run) -> Bool {
        guard isPlaying else { return false }
        let start = attributedStringRun.audioTimeRange?.start.seconds
        let end = attributedStringRun.audioTimeRange?.end.seconds
        guard let start, let end else {
            return false
        }

        if end < currentPlaybackTime { return false }

        if start < currentPlaybackTime, currentPlaybackTime < end {
            return true
        }

        return false
    }
}

#Preview {
    StoryView(story: .constant(Story.blank()))
}
