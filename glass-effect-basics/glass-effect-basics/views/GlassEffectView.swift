//
//  GlassEffectView.swift
//  glass-effect-basics
//
//  Created by Yuunan kin on 2025/08/18.
//

import SwiftUI
import AVKit

struct GlassEffectView: View {
    private let player: AVPlayer
    init() {
        if let url = Bundle.main.url(forResource: "aoike", withExtension: "mp4") {
            player = AVPlayer(url: url)
            player.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem, queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        } else {
            player = AVPlayer()
        }
    }
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text("青池")
                    .padding()
                    .frame(width: 300)
                    .glassEffect()
                    .padding()
            }
        }
            .task {
                player.volume = 0
                player.play()
            }

    }
}

#Preview {
    GlassEffectView()
}
