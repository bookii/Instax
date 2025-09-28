//
//  CameraView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/23.
//

import AVFoundation
import SwiftUI
import UIKit

public struct CameraView: View {
    public enum Destination: Hashable {
        case edit(image: UIImage)
    }

    @Environment(\.cameraRepository) private var cameraRepository
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        CameraContentView(path: $path, cameraRepository: cameraRepository)
    }

    public static func destinationView(for destination: Destination, path: Binding<NavigationPath>) -> some View {
        switch destination {
        case let .edit(image: image):
            EditView(path: path, image: image)
        }
    }
}

private struct CameraContentView: View {
    @State private var isCapturing = false
    @State private var error: Error?
    @State private var isErrorPresented = false
    @State private var cardSize: CGSize = .zero

    @StateObject private var viewModel: CameraViewModel
    @Binding private var path: NavigationPath

    fileprivate init(path: Binding<NavigationPath>, cameraRepository: CameraRepositoryProtocol) {
        _path = path
        _viewModel = .init(wrappedValue: .init(cameraRepository: cameraRepository))
    }

    fileprivate var body: some View {
        VStack(spacing: 0) {
            Spacer()
            cardView
            Spacer()
            captureButton
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
        }
        .colorScheme(.dark)
        .task {
            await viewModel.start()
        }
        .onReceive(viewModel.$isCapturing) { isCapturing in
            self.isCapturing = isCapturing
        }
        .onReceive(viewModel.$capturedImage) { image in
            guard let image else {
                return
            }
            path.append(CameraView.Destination.edit(image: image))
        }
        .onReceive(viewModel.errorPublisher) { error in
            self.error = error
            isErrorPresented = true
        }
        .alert($error.wrappedValue?.localizedDescription ?? "", isPresented: $isErrorPresented) {
            Button("OK") {
                error = nil
                isErrorPresented = false
            }
        }
    }

    private var cardView: some View {
        Color.white
            .aspectRatio(Constants.instaxOuterAspectRatio, contentMode: .fit)
            .onGeometryChange(for: CGSize.self, of: \.size) { size in
                cardSize = size
            }
            .padding(.horizontal, 24)
            .overlay {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 8 * cardSize.height / Constants.instaxOuterAspectRatio.height)
                    CameraPreview(session: viewModel.session)
                        .aspectRatio(Constants.instaxInnerAspectRatio, contentMode: .fit)
                        .frame(width: cardSize.width * Constants.instaxInnerAspectRatio.width / Constants.instaxOuterAspectRatio.width)
                        .clipped()
                    Spacer()
                }
                .frame(width: cardSize.width, height: cardSize.height)
            }
    }

    private var captureButton: some View {
        Button {
            viewModel.capture()
        } label: {
            Circle()
                .fill(.white)
                .frame(width: 56, height: 56)
        }
        .padding(4)
        .overlay {
            Circle()
                .stroke(Color.white, lineWidth: 4)
        }
        .disabled(isCapturing)
    }
}

private struct CameraPreview: UIViewRepresentable {
    private let session: AVCaptureSession

    fileprivate init(session: AVCaptureSession) {
        self.session = session
    }

    fileprivate func makeUIView(context _: Context) -> CameraPreviewInnerView {
        let view = CameraPreviewInnerView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    fileprivate func updateUIView(_: CameraPreviewInnerView, context _: Context) {
        // NOP
    }
}

private class CameraPreviewInnerView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            CameraView(path: path)
                .navigationDestination(for: CameraView.Destination.self) { destination in
                    CameraView.destinationView(for: destination, path: path)
                }
        }
        .environment(\.cameraRepository, MockCameraRepository())
    }
#endif
