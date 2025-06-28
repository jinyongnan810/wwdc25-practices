//
//  GuidedGenerationView.swift
//  foundation-practices
//
//  Created by Yuunan kin on 2025/06/28.
//

import FoundationModels
import Playgrounds
import SwiftUI

struct GuidedGenerationView: View {
    @State private var promptText: String = ""
    @State private var showAlert: Bool = false
    @State private var responseText: String = ""
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            VStack {
                Spacer()
                TextField("Your Prompt", text: $promptText)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .padding()
                Spacer()
                Button(
                    action: {
                        if !SystemLanguageModel.default.isAvailable {
                            showAlert = true
                            responseText = "Language model is not available."
                            return
                        }
                        // Generate a list of search terms for an app about classical music.
                        Task {
                            let session = LanguageModelSession()
                            print("starting session...")
                            let response = try await session.respond(
                                to: promptText,
                                generating: SearchSuggestions.self
                            )
                            print("got response:", response.content)
                            responseText = response.content.terms
                                .joined(separator: ", ")
                            showAlert = true
                        }
                    }) {
                        Text("Submit")
                    }
                    .disabled(promptText.isEmpty)
                    .glassEffect()
                    .padding()
            }
            .alert("Response", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(responseText)
            }
        }
    }
}

#Preview {
    BasicPromptView()
}

#Playground {}
