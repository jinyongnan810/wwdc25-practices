//
//  ContentView.swift
//  3d-charts
//
//  Created by Yuunan kin on 2025/08/24.
//

import Charts
import Spatial
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context

    @State private var azimuth: Double = 45
    @State private var inclination: Double = 30
    @State private var graphType: GraphType = .wave
    func fn(_ x: Double, _ z: Double) -> Double {
        switch graphType {
        case .wave:
            sin(x) * cos(x)
        case .parabola:
            x * x - z * z
        case .saddle:
            x * x + z * z
        }
    }

    @State private var displaySheet: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                VStack {
                    Chart3D { [fn] in
                        SurfacePlot(x: "X", y: "Y", z: "Z") { x, z in
                            fn(x, z)
                        }.foregroundStyle(EllipticalGradient(colors: [.cyan, .purple]))
                    }.chart3DPose(Chart3DPose(
                        azimuth: .degrees(azimuth),
                        inclination: .degrees(inclination)
                    ))
//                    .chartOverlay { _ in
//                        RoundedRectangle(cornerRadius: 12)
//                            .foregroundStyle(.brown.gradient.opacity(0.3))
//                    }
                }.safeAreaInset(
                    edge: .bottom,
                    content: {
                        VStack {
                            Picker(selection: $graphType) {
                                ForEach(GraphType.allCases, id: \.self) {
                                    Text($0.rawValue.capitalized)
                                }
                            } label: {
                                Text("Graph Type")
                            }.pickerStyle(.segmented)
                                .padding()

                            Text("Azimuth")
                            Slider(
                                value: $azimuth,
                                in: 0 ... 360
                            ) {
                                Text("Azimuth")
                            } minimumValueLabel: {
                                Text("0°")
                            } maximumValueLabel: {
                                Text("360°")
                            }
                            Text("inclination")
                            Slider(
                                value: $inclination,
                                in: -90 ... 90
                            ) {
                                Text("inclination")
                            } minimumValueLabel: {
                                Text("-90°")
                            } maximumValueLabel: {
                                Text("90°")
                            }
                        }.padding().glassEffect(.clear, in: .rect(cornerRadius: 12))
                    }
                )
                .padding()
            }
            .navigationTitle("3D Chart")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let newPose = GraphPose(
                            type: graphType,
                            azimuth: azimuth,
                            inclination: inclination
                        )
                        context.insert(newPose)
                        try? context.save()
                    } label: {
                        Image(systemName: "camera")
                    }.buttonStyle(.glass)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        displaySheet.toggle()
                    } label: {
                        Image(systemName: "list.bullet")
                    }.buttonStyle(.glass)
                }
            }.sheet(isPresented: $displaySheet) {
                GraphPoseListView(
                    azimuth: $azimuth,
                    inclination: $inclination,
                    graphType: $graphType,
                    displaySheet: $displaySheet
                ).presentationDetents([.fraction(0.3), .medium, .large])
            }
        }
    }
}

#Preview {
    ContentView().modelContainer(for: GraphPose.self)
}
