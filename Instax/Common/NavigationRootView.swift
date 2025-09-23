//
//  NavigationRootView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/23.
//

import SwiftUI

public struct NavigationRootView<Content: View>: View {
    @State private var path = NavigationPath()
    private let content: (Binding<NavigationPath>) -> Content

    public init(@ViewBuilder content: @escaping (Binding<NavigationPath>) -> Content) {
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $path) {
            content($path)
        }
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            CameraView(path: path)
        }
    }
#endif
