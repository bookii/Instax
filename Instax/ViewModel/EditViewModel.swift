//
//  EditViewModel.swift
//  Instax
//
//  Created by mizznoff on 2025/09/30.
//

import Foundation
import SwiftUICore
import UIKit

public final class EditViewModel: NSObject, ObservableObject {
    // MARK: - Properties

    @Published public private(set) var renderedImage: UIImage?

    override public init() {}

    @MainActor public func renderImage(view: some View) {
        let renderer = ImageRenderer(content: view)
    }
}
