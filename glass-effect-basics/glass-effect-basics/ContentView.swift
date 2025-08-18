//
//  ContentView.swift
//  glass-effect-basics
//
//  Created by Yuunan kin on 2025/08/18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(".glassEffect()") {
                    GlassEffectView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
