//
//  EditView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/24.
//

import Combine
import SwiftUI

public struct EditView: View {
    public enum Destination: Hashable {
        case share(image: UIImage)
    }

    @Binding private var path: NavigationPath
    private let image: UIImage

    public init(path: Binding<NavigationPath>, image: UIImage) {
        _path = path
        self.image = image
    }

    public var body: some View {
        EditContentView(path: $path, image: image)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case let .share(image):
                    EmptyView()
                }
            }
    }
}

private struct EditContentView: View {
    @Environment(\.dismiss) private var dismiss
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
        .navigationTitle("写真の編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("戻る") {
                    // TODO: dismiss してよいか確認する
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    saveImage()
                }
                .fontWeight(.bold)
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
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(Constants.instaxInnerAspectRatio, contentMode: .fit)
                        .frame(width: cardSize.width * Constants.instaxInnerAspectRatio.width / Constants.instaxOuterAspectRatio.width)
                        .clipped()
                    Spacer()
                    TextField(text: $message, prompt: Text("メッセージを入力")) {}
                        .multilineTextAlignment(.center)
                        .font(.custom("apricotJapanesefont", size: cardSize.width / 10))
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onReceive(Just(message)) { _ in
                            message = String(message.prefix(messageLimit))
                        }
                    Spacer()
                }
                .frame(width: cardSize.width, height: cardSize.height)
            }
            .overlay {
                CanvasView(isEditing: $isEditingCanvas)
                    .frame(width: cardSize.width, height: cardSize.height)
            }
            .onGeometryChange(for: CGSize.self, of: \.size) { size in
                cardSize = size
            }
            .compositingGroup()
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

    private func saveImage() {
        let renderer = ImageRenderer(content: cardView)
        if let image = renderer.uiImage {
            path.append(EditView.Destination.share(image: image))
        }
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            EditView(path: path, image: .mockImage)
        }
    }
#endif
