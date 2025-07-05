//
//  StoryView.swift
//  speech-analyzer-practices
//
//  Created by Yuunan kin on 2025/07/05.
//

import SwiftUI

struct StoryView: View {
    @Binding var story: Story
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    StoryView(story: .constant(Story.blank()))
}
