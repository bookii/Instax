//
//  CameraViewModel.swift
//  Instax
//
//  Created by mizznoff on 2025/09/28.
//

import AVFoundation
import Combine
import Foundation
import UIKit

public final class CameraViewModel: NSObject, ObservableObject {
    // MARK: - Properties

    @Published public private(set) var isCapturing = false
    @Published public private(set) var capturedImage: UIImage?
    public let errorPublisher = PassthroughSubject<Error, Never>()

    public var session: AVCaptureSession {
        cameraRepository.session
    }

    private let cameraRepository: CameraRepositoryProtocol

    // MARK: - Lifecycle

    public init(cameraRepository: CameraRepositoryProtocol) {
        self.cameraRepository = cameraRepository
        super.init()
        self.cameraRepository.delegate = self
    }

    // MARK: - Methods

    public func start() async {
        do {
            try await cameraRepository.start()
        } catch {
            errorPublisher.send(error)
        }
    }

    public func capture() {
        isCapturing = true
        cameraRepository.capture()
    }
}

extension CameraViewModel: CameraRepositoryDelegate {
    public func cameraRepository(_: CameraRepositoryProtocol, didFinishCapturingWithResult result: Result<UIImage, Error>) {
        switch result {
        case let .success(image):
            capturedImage = image
        case let .failure(error):
            errorPublisher.send(error)
        }
        isCapturing = false
    }
}
