//
//  GlassEffectView.swift
//  glass-effect-basics
//
//  Created by Yuunan kin on 2025/08/18.
//

import AVKit
import SwiftUI

struct GlassEffectView: View {
    @State private var morph = false
    var spacing: Double {
        morph ? -20 : 20
    }

    var size: Double {
        morph ? 160 : 100
    }

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
            GeometryReader { geometry in
                VideoPlayer(player: player)
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
            VStack {
                Spacer()

                GlassEffectContainer(spacing: 20) {
                    HStack(spacing: spacing) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .frame(width: 80, height: 80)
                            .glassEffect()
                        Text("青池")
                            .padding()
                            .frame(width: size, height: 80)
                            .glassEffect()
                        Image(systemName: "square.and.arrow.up")
                            .font(.largeTitle)
                            .frame(width: 80, height: 80)
                            .glassEffect()
                    }.onTapGesture {
                        withAnimation(.bouncy) {
                            morph.toggle()
                        }
                    }
                }
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
