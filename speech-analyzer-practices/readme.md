## Flows

User
│
│ 1. Tap "Record"
▼
Recorder.startRecording()
│
│──► Sets up AVAudioEngine
│──► Calls transcriber.setupTranscriber()
│ │
│ │──► Sets up SpeechTranscriber + SpeechAnalyzer
│ │──► Creates AsyncStream (inputSequence, inputBuilder)
│ │──► Starts listening for results in background task
│
│──► For each audio buffer:
│ │
│ │──► writeBufferToDisk(buffer)
│ │──► Calls transcriber.streamAudioToTranscriber(buffer)
│ │
│ │──► Converts buffer format
│ │──► Wraps in AnalyzerInput
│ │──► inputBuilder.yield(input)
│
│
▼
Transcriber
│
│──► SpeechAnalyzer consumes inputSequence
│──► SpeechTranscriber produces results
│──► For each result:
│ │
│ │──► If final:
│ │ Append to finalizedTranscript
│ │ Update Story
│ │ Else:
│ │ Update volatileTranscript
│
▼
[UI updates with transcript]
