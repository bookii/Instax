//
//  MainView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/23.
//

import SwiftUI

public struct MainView: View {
    private enum TabType: Hashable {
        case camera
        case album
    }

    @State private var tabType: TabType = .camera

    public var body: some View {
        NavigationRootView { path in
            TabView(selection: $tabType) {
                CameraView(path: path)
                    .tabItem {
                        Image(systemName: "camera")
                        Text("カメラ")
                    }
                Color.blue
                    .tabItem {
                        Image(systemName: "photo.stack")
                        Text("アルバム")
                    }
            }
            .navigationDestination(for: CameraView.Destination.self) { destination in
                CameraView.destinationView(for: destination, path: path)
            }
        }
    }
}

#if DEBUG
    #Preview {
        MainView()
            .environment(\.cameraRepository, MockCameraRepository())
    }
#endif
