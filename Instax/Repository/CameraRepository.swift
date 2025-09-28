//
//  CameraRepository.swift
//  Instax
//
//  Created by mizznoff on 2025/09/28.
//

import AVFoundation
import Foundation
import SwiftUICore
import UIKit

extension EnvironmentValues {
    @Entry var cameraRepository: CameraRepositoryProtocol = CameraRepository()
}

public protocol CameraRepositoryProtocol: AnyObject {
    var session: AVCaptureSession { get }
    var delegate: CameraRepositoryDelegate? { get set }
    func start() async throws
    func capture()
}

@MainActor
public protocol CameraRepositoryDelegate: AnyObject {
    func cameraRepository(_ repository: CameraRepositoryProtocol, didFinishCapturingWithResult result: Result<UIImage, Error>)
}

public final class CameraRepository: NSObject, CameraRepositoryProtocol {
    public enum Error: LocalizedError {
        case cameraNotGranted
        case cameraNotFound
        case sessionError
        case generateError

        public var errorDescription: String? {
            switch self {
            case .cameraNotGranted:
                "カメラへのアクセス権限がありません"
            case .cameraNotFound:
                "カメラが見つかりません"
            case .sessionError:
                "セッションのエラー"
            case .generateError:
                "画像の取得に失敗しました"
            }
        }
    }

    // MARK: - Properties

    public let session = AVCaptureSession()
    public weak var delegate: CameraRepositoryDelegate?

    private var input: AVCaptureDeviceInput?
    private let output = AVCapturePhotoOutput()

    // MARK: - Lifecycle

    override public init() {}

    // MARK: - Methods

    public func start() async throws {
        if let input {
            session.removeInput(input)
        }
        session.removeOutput(output)

        try await withCheckedThrowingContinuation { continuation in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                continuation.resume()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: Error.cameraNotGranted)
                    }
                }
            case .denied, .restricted:
                continuation.resume(throwing: Error.cameraNotGranted)
            @unknown default:
                continuation.resume(throwing: Error.cameraNotGranted)
            }
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw Error.cameraNotFound
        }
        let input = try AVCaptureDeviceInput(device: camera)
        guard session.canAddInput(input) else {
            throw Error.sessionError
        }
        session.addInput(input)
        self.input = input

        guard session.canAddOutput(output) else {
            throw Error.sessionError
        }
        session.addOutput(output)
        output.maxPhotoQualityPrioritization = .quality

        session.commitConfiguration()

        session.startRunning()
    }

    public func capture() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraRepository: @preconcurrency AVCapturePhotoCaptureDelegate {
    @MainActor public func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Swift.Error?) {
        if let error {
            delegate?.cameraRepository(self, didFinishCapturingWithResult: .failure(error))
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else {
            delegate?.cameraRepository(self, didFinishCapturingWithResult: .failure(Error.generateError))
            return
        }

        delegate?.cameraRepository(self, didFinishCapturingWithResult: .success(image.cropped(aspectRatio: Constants.instaxInnerAspectRatio)))
    }
}

private extension UIImage {
    func cropped(aspectRatio: CGSize) -> Self {
        precondition(aspectRatio != .zero, "aspectRate cannot be .zero")

        // orientation を維持する処理
        let renderedImage = UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }

        guard let cgImage = renderedImage.cgImage else {
            return self
        }

        let pixelWidth = CGFloat(cgImage.width)
        let pixelHeight = CGFloat(cgImage.height)

        let targetAspect = aspectRatio.width / aspectRatio.height
        let sourceAspect = pixelWidth / pixelHeight

        let (cropWidth, cropHeight): (CGFloat, CGFloat) = if sourceAspect > targetAspect {
            (pixelHeight * targetAspect, pixelHeight)
        } else {
            (pixelWidth, pixelWidth / targetAspect)
        }

        let originX = (pixelWidth - cropWidth) / 2
        let originY = (pixelHeight - cropHeight) / 2

        let cropRect = CGRect(x: originX.rounded(.towardZero),
                              y: originY.rounded(.towardZero),
                              width: cropWidth.rounded(.towardZero),
                              height: cropHeight.rounded(.towardZero))
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return self
        }
        return .init(cgImage: croppedCGImage, scale: renderedImage.scale, orientation: .up)
    }
}

#if DEBUG
    public final class MockCameraRepository: NSObject, @preconcurrency CameraRepositoryProtocol {
        // MARK: - Properties

        public let session = AVCaptureSession()
        public weak var delegate: CameraRepositoryDelegate?

        override public init() {}

        public func start() async throws {
            // NOP
        }

        @MainActor public func capture() {
            delegate?.cameraRepository(self, didFinishCapturingWithResult: .success(.mockImage))
        }
    }
#endif
