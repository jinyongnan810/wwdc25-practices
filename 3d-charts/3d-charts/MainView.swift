//
//  MainView.swift
//  3d-charts
//
//  Created by Yuunan kin on 2025/08/24.
//

import SwiftData
import SwiftUI

@main
struct MainView: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: GraphPose.self)
        }
    }
}
