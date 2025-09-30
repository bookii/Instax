//
//  EditView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/24.
//

import Combine
import PencilKit
import SwiftUI

public struct EditView: View {
    @Binding private var path: NavigationPath
    private let photoImage: UIImage

    public init(path: Binding<NavigationPath>, photoImage: UIImage) {
        _path = path
        self.photoImage = photoImage
    }

    public var body: some View {
        EditContentView(path: $path, photoImage: photoImage)
            .navigationTitle("写真の編集")
    }
}

private struct EditContentView: View {
    @Environment(\.displayScale) private var displayScale
    @Binding private var path: NavigationPath
    private let photoImage: UIImage
    @State private var cardSize: CGSize = .zero

    @State private var isEditingMessage: Bool = false
    @FocusState private var isFocused: Bool
    @State private var message: String = ""
    private let messageLimit = 10
    @State private var isRenderingMessage: Bool = false

    private let pkCanvasView = PKCanvasView()
    @State private var isEditingCanvas: Bool = false
    @State private var renderedCanvasImage: UIImage?

    @State private var renderedCardImage: UIImage?
    @State private var isActivityViewPresented: Bool = false

    fileprivate init(path: Binding<NavigationPath>, photoImage: UIImage) {
        _path = path
        self.photoImage = photoImage
    }

    fileprivate var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                cardView
                    .shadow(radius: 4)
                    .padding(.horizontal, 24)
                Spacer().frame(height: 24)
                VStack(spacing: 16) {
                    editMessageButton
                    drawButton
                }
                // VStack の領域を変化させないように opacity で表示管理する
                .opacity(isEditingMessage || isEditingCanvas ? 0 : 1)
                Spacer(minLength: 0)
            }
            .padding(.vertical, 24)
            .background {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        endEditingMessage()
                        isEditingCanvas = false
                    }
            }
        }
        .background {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
        }
        .colorScheme(.light)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("共有") {
                    shareImage()
                }
                .fontWeight(.bold)
                .disabled(message.isEmpty)
            }
        }
        .sheet(isPresented: $isActivityViewPresented, onDismiss: {
            renderedCanvasImage = nil
            renderedCardImage = nil
        }) {
            if let renderedCardImage {
                ActivityView(image: renderedCardImage)
            }
        }
        .onChange(of: isEditingMessage) { _, newValue in
            if newValue {
                isFocused = true
            }
        }
        .onChange(of: isFocused) { _, newValue in
            isEditingMessage = newValue
        }
        .animation(.linear(duration: 0.1), value: isEditingMessage)
        .animation(.linear(duration: 0.1), value: isEditingCanvas)
    }

    private var cardView: some View {
        Color.white
            .aspectRatio(Constants.instaxOuterAspectRatio, contentMode: .fit)
            .overlay {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 8 * cardSize.height / Constants.instaxOuterAspectRatio.height)
                    Image(uiImage: photoImage)
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(Constants.instaxInnerAspectRatio, contentMode: .fit)
                        .frame(width: cardSize.width * Constants.instaxInnerAspectRatio.width / Constants.instaxOuterAspectRatio.width)
                        .clipped()
                    Spacer()
                    Group {
                        if isRenderingMessage {
                            Text(message)
                        } else {
                            TextField(text: $message, prompt: Text("メッセージを入力")) {}
                                .focused($isFocused)
                                .submitLabel(.done)
                                .onReceive(Just(message)) { _ in
                                    message = String(message.prefix(messageLimit))
                                }
                        }
                    }
                    .multilineTextAlignment(.center)
                    .font(.custom("apricotJapanesefont", size: cardSize.width / 10))
                    Spacer()
                }
                .frame(width: cardSize.width, height: cardSize.height)
            }
            .overlay {
                if let renderedCanvasImage {
                    Image(uiImage: renderedCanvasImage)
                        .frame(width: cardSize.width, height: cardSize.height)
                } else {
                    CanvasView(pkCanvasView: pkCanvasView, isEditing: $isEditingCanvas)
                        .frame(width: cardSize.width, height: cardSize.height)
                }
            }
            .compositingGroup()
            .onGeometryChange(for: CGSize.self, of: \.size) { size in
                cardSize = size
            }
            .onTapGesture {
                endEditingMessage()
            }
    }

    private var editMessageButton: some View {
        Button {
            isEditingCanvas = false
            isEditingMessage = true
        } label: {
            Text("メッセージの編集")
                .font(.custom("apricotJapanesefont", size: 24))
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .buttonStyle(.borderedProminent)
    }

    private var drawButton: some View {
        Button {
            endEditingMessage()
            isEditingCanvas = true
        } label: {
            Text("描き込む")
                .font(.custom("apricotJapanesefont", size: 24))
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .buttonStyle(.borderedProminent)
    }

    private func endEditingMessage() {
        isFocused = false
        isEditingMessage = false
    }

    private func shareImage() {
        isRenderingMessage = true
        renderedCanvasImage = pkCanvasView.drawing.image(from: pkCanvasView.bounds, scale: displayScale)
        let renderer = ImageRenderer(content: cardView)
        renderer.proposedSize = .init(cardSize)
        renderer.scale = displayScale
        guard let renderedCardImage = renderer.uiImage else {
            // TODO: エラー表示
            return
        }
        self.renderedCardImage = renderedCardImage
        isActivityViewPresented = true
        isRenderingMessage = false
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            EditView(path: path, photoImage: .mockImage)
        }
    }
#endif
