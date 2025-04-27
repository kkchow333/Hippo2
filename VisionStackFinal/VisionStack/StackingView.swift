//
//  StackingView.swift
//  VisionStack
//
//  Created by Brian Advent on 23.03.24.
//

import SwiftUI
import RealityKit
import RealityKitContent

// Define a proper window identifier type
struct DynamicWindowId: Hashable, Codable, Identifiable {
    let id: String
    
    init() {
        self.id = UUID().uuidString
    }
}

struct StackingView: View {
    @StateObject var model = HandTrackingViewModel()
    @Environment(\.openWindow) private var openWindow
    @State private var windows: [DynamicWindowId] = []
    
    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }.task {
            await model.runSession()
        }.task {
            await model.processHandUpdates()
        }.task {
            await model.processReconstructionUpdates()
        }.gesture(SpatialTapGesture().targetedToAnyEntity().onEnded({ value in
            Task {
                await model.placeCube()
            }
        }))
        .onChange(of: model.windowPosition) { _, newPosition in
            guard let position = newPosition else { return }
            
            // Create a new window identifier
            let windowId = DynamicWindowId()
            windows.append(windowId)
            
            // Open a new window at the specified position
            openWindow(value: windowId)
        }
    }
}

#Preview {
    StackingView()
}
