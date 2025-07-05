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
    var url: URL?
    var isDone: Bool

    init(title: String, text: AttributedString, url: URL? = nil, isDone: Bool = false) {
        self.title = title
        self.text = text
        self.url = url
        self.isDone = isDone
        id = UUID()
    }

    func suggestedTitle() async throws -> String? {
        guard SystemLanguageModel.default.isAvailable else { return nil }
        let session = LanguageModelSession(model: SystemLanguageModel.default)
        let answer = try await session.respond(to: "Here is a children's story. Can you please return your very best suggested title for it, with no other text? The title should be descriptive of the story and include the main character's name. Story: \(text.characters)")
        return answer.content.trimmingCharacters(in: .punctuationCharacters)
    }
}

extension Story {
    static func blank() -> Story {
        .init(title: "New Story", text: AttributedString(""))
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
