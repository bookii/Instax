//
//  EditView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/24.
//

import Combine
import SwiftUI

public struct EditView: View {
    @Binding private var path: NavigationPath
    private let image: UIImage

    public init(path: Binding<NavigationPath>, image: UIImage) {
        _path = path
        self.image = image
    }

    public var body: some View {
        EditContentView(path: $path, image: image)
    }
}

private struct EditContentView: View {
    @Binding private var path: NavigationPath
    private let image: UIImage
    @State private var cardSize: CGSize = .zero
    @State private var isEditingMessage: Bool = false
    @FocusState private var isFocused: Bool
    @State private var message: String = ""
    private let messageLimit = 10
    @State private var isEditingCanvas: Bool = false

    fileprivate init(path: Binding<NavigationPath>, image: UIImage) {
        _path = path
        self.image = image
    }

    fileprivate var body: some View {
        VStack(spacing: 0) {
            cardView
            VStack(spacing: 16) {
                if !isEditingMessage, !isEditingCanvas {
                    editMessageButton
                    drawButton
                }
            }
            Spacer(minLength: 0)
        }
        .onChange(of: isEditingMessage) { _, newValue in
            if newValue {
                isFocused = true
            }
        }
        .onChange(of: isFocused) { _, newValue in
            if !newValue {
                isEditingMessage = false
            }
        }
        .background {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    endEditingMessage()
                    isEditingCanvas = false
                }
        }
        .animation(.default, value: isEditingMessage)
        .animation(.default, value: isEditingCanvas)
    }

    private var cardView: some View {
        Color.white
            .aspectRatio(CGSize(width: 54, height: 86), contentMode: .fit)
            .onGeometryChange(for: CGSize.self, of: \.size) { size in
                cardSize = size
            }
            .shadow(radius: 4)
            .padding(24)
            .overlay {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 8 * cardSize.height / 86)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(CGSize(width: 46, height: 62), contentMode: .fit)
                        .frame(width: cardSize.width * 46 / 54)
                        .clipped()
                    Spacer()
                    TextField(text: $message, prompt: Text("メッセージを入力")) {}
                        .multilineTextAlignment(.center)
                        .font(.custom("apricotJapanesefont", size: cardSize.width / 10))
                        .onReceive(Just(message)) { _ in
                            message = String(message.prefix(messageLimit))
                        }
                        .focused($isFocused)
                        .disabled(!isEditingMessage)
                    Spacer()
                }
                .frame(width: cardSize.width, height: cardSize.height)
            }
            .overlay {
                CanvasView(isEditing: $isEditingCanvas)
                    .frame(width: cardSize.width, height: cardSize.height)
            }
            .onTapGesture {
                endEditingMessage()
            }
    }
    
    private var editMessageButton: some View {
        Button {
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
            isEditingCanvas = true
        } label: {
            Text("描き込み")
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
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            EditView(path: path, image: .mockImage)
        }
    }
#endif
