//
//  ContentView.swift
//  foundation-practices
//
//  Created by Yuunan kin on 2025/06/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Basic Prompt", destination: BasicPromptView())
                NavigationLink(
                    "Guided Generation",
                    destination: GuidedGenerationView()
                )
                NavigationLink(
                    "Snapshot Streaming",
                    destination: SnapshotStreamingView()
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
