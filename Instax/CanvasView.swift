//
//  CanvasView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/26.
//

import SwiftUI
import PencilKit

public struct CanvasView: UIViewRepresentable {
    private var canvasView = PKCanvasView()
    private let toolPicker = PKToolPicker()
    
    @Binding private var isEditing: Bool
    
    public init(isEditing: Binding<Bool>) {
        _isEditing = isEditing
    }

    public func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isUserInteractionEnabled = isEditing
        canvasView.becomeFirstResponder()
        return canvasView
    }
    
    public func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isEditing
        toolPicker.setVisible(isEditing, forFirstResponder: uiView)
        toolPicker.addObserver(uiView)
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var isEditing: Bool = false
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
