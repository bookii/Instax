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

    fileprivate init(path: Binding<NavigationPath>, image: UIImage) {
        _path = path
        self.image = image
    }

    fileprivate var body: some View {
        VStack(spacing: 0) {
            cardView
            VStack(spacing: 16) {
                Button {
                    isEditingMessage = true
                    // TODO: PencilKit の終了
                } label: {
                    Text("メッセージの編集")
                        .font(.custom("apricotJapanesefont", size: 24))
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .buttonStyle(.borderedProminent)
                Button {
                    isEditingMessage = false
                    // TODO: PencilKit の起動
                } label: {
                    Text("書き込み")
                        .font(.custom("apricotJapanesefont", size: 24))
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .buttonStyle(.borderedProminent)
            }
            Spacer(minLength: 0)
        }
        .onChange(of: isEditingMessage) { _, newValue in
            if newValue {
                isFocused = true
            }
        }
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
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            EditView(path: path, image: .mockImage)
        }
    }
#endif
