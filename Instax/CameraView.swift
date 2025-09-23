//
//  CameraView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/23.
//

import SwiftUI
import UIKit

public struct CameraView: View {
    fileprivate enum Destination: Hashable {
        case edit(image: UIImage)
    }

    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        CameraContentView(path: $path)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .edit:
                    EmptyView()
                }
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
            if let image {
                path.append(CameraView.Destination.edit(image: image))
            }
        }
    }
}

private struct CameraBodyView: UIViewControllerRepresentable {
    private var completion: (UIImage?) -> Void

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

        init(parent: CameraBodyView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as! UIImage
            parent.completion(image)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
            picker.dismiss(animated: true)
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
