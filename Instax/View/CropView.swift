//
//  CropView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/23.
//

import CropViewController
import SwiftUI

public struct CropView: View {
    fileprivate enum Destination: Hashable {
        case edit(image: UIImage)
    }

    @Binding private var path: NavigationPath
    private let image: UIImage

    public init(path: Binding<NavigationPath>, image: UIImage) {
        _path = path
        self.image = image
    }

    public var body: some View {
        CropContentView(path: $path, image: image)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case let .edit(image):
                    EditView(path: $path, photoImage: image)
                }
            }
    }
}

private struct CropContentView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var path: NavigationPath
    private let image: UIImage

    fileprivate init(path: Binding<NavigationPath>, image: UIImage) {
        _path = path
        self.image = image
    }

    fileprivate var body: some View {
        CropBodyView(image: image) { croppedImage in
            if let croppedImage {
                path.append(CropView.Destination.edit(image: croppedImage))
            } else {
                dismiss()
            }
        }
    }
}

private struct CropBodyView: UIViewControllerRepresentable {
    private let image: UIImage
    private let completion: (UIImage?) -> Void

    fileprivate init(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        self.image = image
        self.completion = completion
    }

    fileprivate func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = CropViewController(image: image)
        viewController.delegate = context.coordinator
        viewController.aspectRatioPreset = .presetCustom
        viewController.customAspectRatio = CGSize(width: 46, height: 62)
        viewController.aspectRatioLockEnabled = true
        viewController.resetAspectRatioEnabled = false
        return viewController
    }

    fileprivate func updateUIViewController(_: UIViewControllerType, context _: Context) {
        // NOP
    }

    fileprivate func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    fileprivate class Coordinator: NSObject, CropViewControllerDelegate {
        private let parent: CropBodyView

        fileprivate init(parent: CropBodyView) {
            self.parent = parent
        }

        fileprivate func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
            parent.completion(image)
            cropViewController.dismiss(animated: true)
        }

        fileprivate func cropViewController(_ cropViewController: CropViewController, didFinishCancelled _: Bool) {
            parent.completion(nil)
            cropViewController.dismiss(animated: true)
        }
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            CropView(path: path, image: .mockImage)
        }
    }
#endif
