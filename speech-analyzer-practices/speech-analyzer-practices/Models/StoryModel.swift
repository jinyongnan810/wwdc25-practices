//
//  StoryModel.swift
//  speech-analyzer-practices
//
//  Created by Yuunan kin on 2025/07/05.
//

import AVFoundation
import Foundation
import FoundationModels

@Observable
class Story: Identifiable {
    typealias StartTime = CMTime

    let id: UUID
    var title: String
    var text: AttributedString
    var filePath: URL?
    var isDone: Bool

    init(title: String, text: AttributedString, url: URL? = nil, isDone: Bool = false) {
        self.title = title
        self.text = text
        filePath = url
        self.isDone = isDone
        id = UUID()
    }

    func suggestedTitle() async throws -> String? {
        guard SystemLanguageModel.default.isAvailable else { return nil }
        let session = LanguageModelSession(model: SystemLanguageModel.default)
        let answer = try await session.respond(to: "この物語のタイトルを考えてください。タイトルには主人公の名前を含む必要があります。日本語で、タイトルのみ返答してください。 物語は以下です: \(text.characters)")
        return answer.content.trimmingCharacters(in: .punctuationCharacters)
    }
}

extension Story {
    static func blank() -> Story {
        .init(title: "New Story", text: AttributedString(""))
    }

    func storyBrokenUpByLines() -> AttributedString {
        print(String(text.characters))
        if filePath == nil {
            print("path was nil")
            return text
        } else {
            var final = AttributedString("")
            var working = AttributedString("")
            let copy = text
            for run in copy.runs {
                if copy[run.range].characters.contains(".") {
                    working.append(copy[run.range])
                    final.append(working)
                    final.append(AttributedString("\n\n"))
                    working = AttributedString("")
                } else {
                    if working.characters.isEmpty {
                        let newText = copy[run.range].characters
                        let attributes = run.attributes
                        let trimmed = newText.trimmingPrefix(" ")
                        let newAttributed = AttributedString(trimmed, attributes: attributes)
                        working.append(newAttributed)
                    } else {
                        working.append(copy[run.range])
                    }
                }
            }

            if final.characters.isEmpty {
                return working
            }

            return final
        }
    }
}

extension Story: Equatable {
    static func == (lhs: Story, rhs: Story) -> Bool {
        lhs.id == rhs.id
    }
}

extension Story: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
