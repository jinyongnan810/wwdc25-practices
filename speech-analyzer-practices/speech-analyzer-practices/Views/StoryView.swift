//
//  StoryView.swift
//  speech-analyzer-practices
//
//  Created by Yuunan kin on 2025/07/05.
//

import SwiftUI
internal import CoreMedia

struct StoryView: View {
    @Binding var story: Story
    @State var recorder: Recorder
    @State var transcriber: Transcriber
    @State var isRecording: Bool = false

    @State var isPlaying = false
    @State var currentPlaybackTime = 0.0
    init(story: Binding<Story>) {
        let transcriber = Transcriber(story: story)
        _story = story
        self.transcriber = transcriber
        recorder = Recorder(story: story, transcriber: transcriber)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if !story.isDone {
                Text(transcriber.finalizedTranscript + transcriber.volatileTranscript)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                textScrollView(attributedString: story.storyBrokenUpByLines())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle(Text(story.title))
        .toolbar {
            ToolbarItem {
                Button {
                    isRecording.toggle()
                } label: {
                    if isRecording {
                        Label("Stop", systemImage: "pause.fill").tint(.red)
                    } else {
                        Label("Record", systemImage: "record.circle").tint(.red)
                    }
                }
                .disabled(story.isDone)
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

    @ViewBuilder func textScrollView(attributedString: AttributedString) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                textWithHighlighting(attributedString: attributedString)
                Spacer()
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

    @ViewBuilder func textWithHighlighting(attributedString: AttributedString) -> some View {
        Group {
            Text(attributedStringWithCurrentValueHighlighted(attributedString: attributedString))
                .font(.title)
        }
    }
}

#Preview {
    StoryView(story: .constant(Story.blank()))
}
