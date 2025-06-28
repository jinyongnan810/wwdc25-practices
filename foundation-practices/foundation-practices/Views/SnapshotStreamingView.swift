//
//  SnapshotStreamingView.swift
//  foundation-practices
//
//  Created by Yuunan kin on 2025/06/28.
//

import FoundationModels
import Playgrounds
import SwiftUI

struct SnapshotStreamingView: View {
    @State private var promptText: String = ""
    @State private var showAlert: Bool = false
    @State private var response: SearchSuggestions.PartiallyGenerated?
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
                if response != nil {
                    List {
                        ForEach(response!.terms!, id: \.self) { term in
                            Text(term)
                        }
                    }.animation(.easeInOut, value: response?.terms ?? [])
                }
                Button(
                    action: {
                        if !SystemLanguageModel.default.isAvailable {
                            showAlert = true
                            return
                        }
                        // Generate a list of search terms for an app about classical music.
                        Task {
                            let session = LanguageModelSession()
                            print("starting session...")
                            let stream = session.streamResponse(
                                to: promptText,
                                generating: SearchSuggestions.self
                            )
                            for try await partial in stream {
                                print(partial)
                                withAnimation {
                                    response = partial
                                }
                            }
                        }
                    }) {
                        Text("Submit")
                    }
                    .disabled(promptText.isEmpty)
                    .glassEffect()
                    .padding()
            }.alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("No Apple Intelligence enabled.")
            }
        }
    }
}

#Preview {
    BasicPromptView()
}

#Playground {}
