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
        TabView(selection: $tabType) {
            Color.white
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
    }
}

#if DEBUG
    #Preview {
        MainView()
    }
#endif
