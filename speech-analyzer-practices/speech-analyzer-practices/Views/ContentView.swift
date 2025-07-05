//
//  ContentView.swift
//  speech-analyzer-practices
//
//  Created by Yuunan kin on 2025/07/05.
//

import SwiftUI

struct ContentView: View {
    @State var selection: Story?
    @State var currentStory: Story = .blank()
    @State var stories: [Story] = []
    var body: some View {
        NavigationSplitView {
            if stories.isEmpty {
                Text("No stories yet")
            }
            List(stories, selection: $selection) { story in
                NavigationLink(value: story) {
                    if let selection, selection.id == story.id {
                        Text(story.title)
                            .font(.headline)
                    } else {
                        Text(story.title)
                    }
                }

            }.navigationTitle("Stories")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            let newStory = Story.blank()
                            stories.append(newStory)
                            currentStory = newStory
                        } label: {
                            Label("Add Story", systemImage: "plus")
                        }
                    }
                }
        } detail: {
            if selection != nil {
                StoryView(story: $currentStory)
            } else {
                Text("Select a story from the list")
            }
        }.onChange(of: selection) {
            if let selection {
                withAnimation {
                    currentStory = selection
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
