//
//  CanvasView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/26.
//

import PencilKit
import SwiftUI

public struct CanvasView: UIViewRepresentable {
    private var canvasView = PKCanvasView()
    private let toolPicker = PKToolPicker()

    @Binding private var isEditing: Bool

    public init(isEditing: Binding<Bool>) {
        _isEditing = isEditing
    }

    public func makeUIView(context _: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.overrideUserInterfaceStyle = .light
        canvasView.isUserInteractionEnabled = isEditing
        if isEditing {
            // NOTE: AttributeGraph: cycle detected through attribute のメッセージは一旦無視する
            // ref: https://zenn.dev/st43/scraps/bb81fdb42d77d1
            canvasView.becomeFirstResponder()
        }
        return canvasView
    }

    public func updateUIView(_ uiView: PKCanvasView, context _: Context) {
        toolPicker.overrideUserInterfaceStyle = .light
        toolPicker.setVisible(isEditing, forFirstResponder: uiView)
        toolPicker.addObserver(uiView)
        uiView.isUserInteractionEnabled = isEditing
        if isEditing {
            uiView.becomeFirstResponder()
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var isEditing = false
        VStack(spacing: 16) {
            Button(isEditing ? "編集終了" : "編集開始") {
                isEditing.toggle()
            }
            Color.white
                .overlay {
                    CanvasView(isEditing: $isEditing)
                }
                .compositingGroup()
                .shadow(radius: 4)
        }
        .padding(16)
    }
#endif
