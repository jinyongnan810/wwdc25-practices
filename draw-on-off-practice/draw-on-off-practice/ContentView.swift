//
//  ContentView.swift
//  draw-on-off-practice
//
//  Created by Yuunan kin on 2025/08/23.
//

import SwiftUI

struct DrawToggleView: View {
    @Binding var isOn: Bool
    let drawOnEffect: DrawOnSymbolEffect
    let systemImageName: String
    let speed: Double
    let withShadow: Bool

    var body: some View {
        ZStack {
            if withShadow {
                Image(systemName: systemImageName)
                    .font(.system(size: 100))
                    .foregroundStyle(.white.opacity(0.2))
            }
            Image(systemName: systemImageName)
                .font(.system(size: 100))
                .foregroundStyle(.white)
                .symbolEffect(drawOnEffect, options: .speed(speed), isActive: isOn)
        }
    }
}

struct ContentView: View {
    @State private var isOn: Bool = false
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.cyan, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            VStack {
                DrawToggleView(
                    isOn: $isOn,
                    drawOnEffect: .drawOn.individually,
                    systemImageName: "signature",
                    speed: 1,
                    withShadow: true
                )
                DrawToggleView(
                    isOn: $isOn,
                    drawOnEffect: .drawOn.byLayer,
                    systemImageName: "sun.max",
                    speed: 1,
                    withShadow: false
                )
                DrawToggleView(
                    isOn: $isOn,
                    drawOnEffect: .drawOn,
                    systemImageName: "scribble.variable",
                    speed: 1,
                    withShadow: true
                )
            }
            .onTapGesture {
                withAnimation {
                    isOn.toggle()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
