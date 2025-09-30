//
//  ActivityView.swift
//  Instax
//
//  Created by mizznoff on 2025/09/30.
//

import LinkPresentation
import SwiftUI
import UIKit

public struct ActivityView: UIViewControllerRepresentable {
    private let image: UIImage

    public init(image: UIImage) {
        self.image = image
    }

    public func makeUIViewController(context _: Context) -> UIActivityViewController {
        let itemSource = ItemSource(image: image)
        let viewController = UIActivityViewController(activityItems: [itemSource], applicationActivities: nil)
        return viewController
    }

    public func updateUIViewController(_: UIActivityViewController, context _: Context) {
        // NOP
    }
}

private class ItemSource: NSObject, UIActivityItemSource {
    private let image: UIImage

    fileprivate init(image: UIImage) {
        self.image = image
    }

    fileprivate func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        image
    }

    fileprivate func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        activityViewControllerPlaceholderItem(activityViewController)
    }

    fileprivate func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.iconProvider = NSItemProvider(object: image)
        return metadata
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var isPresented = false
        Button("共有") {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            ActivityView(image: .mockImage)
        }
    }
#endif
