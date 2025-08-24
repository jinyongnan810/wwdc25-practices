//
//  GraphPoseListView.swift
//  3d-charts
//
//  Created by Yuunan kin on 2025/08/24.
//

import SwiftData
import SwiftUI

struct GraphPoseListView: View {
    @Environment(\.modelContext) private var context
    @Query
    var poses: [GraphPose]

    @Binding var azimuth: Double
    @Binding var inclination: Double
    @Binding var graphType: GraphType
    @Binding var displaySheet: Bool

    var body: some View {
        List {
            ForEach(poses) { pose in
                VStack(alignment: .leading) {
                    Text(pose.type.rawValue).foregroundStyle(.purple)
                        .font(.headline)
                    Text("\(pose.azimuth), \(pose.inclination)")
                }.onTapGesture {
                    withAnimation {
                        azimuth = pose.azimuth
                        inclination = pose.inclination
                        graphType = pose.type
                        displaySheet = false
                    }
                }
            }.onDelete { indexSet in
                for index in indexSet {
                    context.delete(poses[index])
                    try? context.save()
                }
            }
        }
    }
}

#Preview {
    GraphPoseListView(
        azimuth: .constant(10),
        inclination: .constant(100),
        graphType: .constant(.wave),
        displaySheet: .constant(true)
    )
    .modelContainer(for: GraphPose.self)
}
