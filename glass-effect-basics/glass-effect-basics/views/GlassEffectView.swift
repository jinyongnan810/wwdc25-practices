//
//  GlassEffectView.swift
//  glass-effect-basics
//
//  Created by Yuunan kin on 2025/08/18.
//

import AVKit
import SwiftUI

enum WeatherType: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case sunny, rainy, foggy, cloudy

    var systemImage: String {
        switch self {
        case .sunny:
            "sun.max"
        case .rainy:
            "cloud.rain"
        case .foggy:
            "cloud.fog"
        case .cloudy:
            "cloud"
        }
    }
}

struct GlassEffectView: View {
    @State private var morph = false
    @Namespace var weatherNamespace
    @State private var currentWeather: WeatherType = .sunny
    var spacing: Double {
        morph ? -40 : 20
    }

    var size: Double {
        morph ? 180 : 100
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
            // Video background
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
                // Button glass effect
                HStack {
                    Spacer()
                    Button {} label: {
                        Text("Save")
                    }.buttonStyle(.glass)
                        .padding()
                }
                Spacer()
                // Glass effect container
                GlassEffectContainer(spacing: 20) {
                    HStack(spacing: spacing) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .frame(width: 80, height: 80)
                            .glassEffect(.regular.interactive())
                        Text("青池")
                            .padding()
                            .frame(width: size, height: 80)
                            .glassEffect(
                                .regular, // .interactive(),
                                in: morph ?
                                    .rect : .rect
//                                    .rect(cornerRadius: 20) : .rect
                            )
                        Image(systemName: "square.and.arrow.up")
                            .font(.largeTitle)
                            .frame(width: 80, height: 80)
                            .glassEffect(
                                .regular.interactive() // .tint(.cyan.opacity(0.4))
                            )
                    }.onTapGesture {
                        withAnimation(.bouncy) {
                            morph.toggle()
                        }
                    }
                }
                // Glass effect union
                GlassEffectContainer {
                    HStack {
                        ForEach(WeatherType.allCases) { weather in
                            Image(systemName: weather.systemImage)
                                .foregroundStyle(
                                    currentWeather == weather ? .blue : .secondary
                                )
                                .padding()
                                .glassEffect(
                                    .regular.interactive()
//                                    .tint(currentWeather == weather ? .blue : .clear)
                                )
                                .glassEffectUnion(
                                    id: "weather",
                                    namespace: weatherNamespace
                                )
                                .onTapGesture {
                                    withAnimation {
                                        currentWeather = weather
                                    }
                                }
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
