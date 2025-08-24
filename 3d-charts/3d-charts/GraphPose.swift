//
//  GraphPose.swift
//  3d-charts
//
//  Created by Yuunan kin on 2025/08/24.
//

import SwiftData

@Model
class GraphPose {
    var type: GraphType
    var azimuth: Double
    var inclination: Double

    init(type: GraphType, azimuth: Double, inclination: Double) {
        self.type = type
        self.azimuth = azimuth
        self.inclination = inclination
    }

    var description: String {
        "\(type), \(azimuth), \(inclination)"
    }
}

enum GraphType: String, CaseIterable, Identifiable, Codable {
    case wave = "Wave"
    case parabola = "Parabola"
    case saddle = "Saddle"

    var id: String { rawValue }
}
