//
//  CameraView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/23.
//

import SwiftUI
import UIKit

public struct CameraView: View {
    public enum Destination: Hashable {
        case crop(image: UIImage)
    }

    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        CameraContentView(path: $path)
    }
    
    public static func destinationView(for destination: Destination, path: Binding<NavigationPath>) -> some View {
        switch destination {
        case let .crop(image: image):
            CropView(path: path, image: image)
        }
    }
}

private struct CameraContentView: View {
    @Binding private var path: NavigationPath
    
    fileprivate init(path: Binding<NavigationPath>) {
        _path = path
    }
    
    fileprivate var body: some View {
        CameraBodyView { image in
            guard let image else {
                return
            }
            path.append(CameraView.Destination.crop(image: image))
        }
    }
}

private struct CameraBodyView: UIViewControllerRepresentable {
    private let completion: (UIImage?) -> Void

    fileprivate init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    fileprivate func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        #if targetEnvironment(simulator)
        // NOP
        #else
            picker.sourceType = .camera
        #endif
        picker.delegate = context.coordinator
        return picker
    }

    fileprivate func updateUIViewController(_: UIImagePickerController, context _: Context) {
        // NOP
    }

    fileprivate func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    fileprivate class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let parent: CameraBodyView

        fileprivate init(parent: CameraBodyView) {
            self.parent = parent
        }

        fileprivate func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as! UIImage
            parent.completion(image)
            picker.dismiss(animated: true)
        }

        fileprivate func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
            picker.dismiss(animated: true)
        }
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
    }
#endif
