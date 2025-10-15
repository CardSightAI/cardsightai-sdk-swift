import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Processes images for upload to the CardSight AI API
public class ImageProcessor {
    private let options: ImageProcessingOptions

    /// Initialize with processing options
    public init(options: ImageProcessingOptions = ImageProcessingOptions()) {
        self.options = options
    }

    // MARK: - Public Methods

    #if canImport(UIKit)
    /// Process a UIImage for upload
    /// - Parameters:
    ///   - image: The UIImage to process
    ///   - customOptions: Optional custom processing options for this operation
    /// - Returns: Processed image data ready for upload
    public func processForUpload(_ image: UIImage, customOptions: ImageProcessingOptions? = nil) async throws -> Data {
        let opts = customOptions ?? options

        // Correct orientation if needed
        let correctedImage = opts.correctOrientation ? image.correctingOrientation() : image

        // Resize if needed
        let resizedImage = try resize(correctedImage, maxDimension: opts.maxDimension)

        // Convert to JPEG
        guard let jpegData = resizedImage.jpegData(compressionQuality: opts.jpegQuality) else {
            throw CardSightAIError.imageProcessingError("Failed to convert image to JPEG format")
        }

        // Check file size and adjust quality if needed
        return try adjustQualityIfNeeded(resizedImage, initialData: jpegData, options: opts)
    }
    #endif

    #if canImport(AppKit)
    /// Process an NSImage for upload
    /// - Parameters:
    ///   - image: The NSImage to process
    ///   - customOptions: Optional custom processing options for this operation
    /// - Returns: Processed image data ready for upload
    public func processForUpload(_ image: NSImage, customOptions: ImageProcessingOptions? = nil) async throws -> Data {
        let opts = customOptions ?? options

        // Resize if needed
        let resizedImage = try resize(image, maxDimension: opts.maxDimension)

        // Convert to JPEG
        guard let tiffData = resizedImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: opts.jpegQuality]) else {
            throw CardSightAIError.imageProcessingError("Failed to convert image to JPEG format")
        }

        // Check file size and adjust quality if needed
        return try adjustQualityIfNeeded(resizedImage, initialData: jpegData, options: opts)
    }
    #endif

    /// Process image data for upload
    /// - Parameters:
    ///   - imageData: The image data to process
    ///   - customOptions: Optional custom processing options for this operation
    /// - Returns: Processed image data ready for upload
    public func processForUpload(_ imageData: Data, customOptions: ImageProcessingOptions? = nil) async throws -> Data {
        let opts = customOptions ?? options

        // Check if this is HEIC/HEIF format
        if isHEICFormat(imageData) {
            // Convert HEIC to JPEG
            return try await convertHEICToJPEG(imageData, options: opts)
        }

        // Check if it's already JPEG or PNG
        if isJPEGFormat(imageData) || isPNGFormat(imageData) {
            // Process the image (resize if needed)
            #if canImport(UIKit)
            if let image = UIImage(data: imageData) {
                return try await processForUpload(image, customOptions: opts)
            }
            #elseif canImport(AppKit)
            if let image = NSImage(data: imageData) {
                return try await processForUpload(image, customOptions: opts)
            }
            #endif
        }

        throw CardSightAIError.imageProcessingError("Unsupported image format. Please provide JPEG, PNG, or HEIC/HEIF images.")
    }

    /// Process an image from a URL for upload
    /// - Parameters:
    ///   - url: The URL of the image file
    ///   - customOptions: Optional custom processing options for this operation
    /// - Returns: Processed image data ready for upload
    public func processForUpload(_ url: URL, customOptions: ImageProcessingOptions? = nil) async throws -> Data {
        let data = try Data(contentsOf: url)
        return try await processForUpload(data, customOptions: customOptions)
    }

    // MARK: - Private Methods

    private func isHEICFormat(_ data: Data) -> Bool {
        // Check for HEIC/HEIF magic bytes
        let heicSignatures: [[UInt8]] = [
            [0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63], // ftypheic
            [0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70, 0x6D, 0x69, 0x66, 0x31], // ftypmif1
            [0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x78], // ftypheix
        ]

        guard data.count >= 12 else { return false }

        for signature in heicSignatures {
            let matches = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                return signature.enumerated().allSatisfy { index, byte in
                    bytes[index] == byte
                }
            }
            if matches { return true }
        }

        return false
    }

    private func isJPEGFormat(_ data: Data) -> Bool {
        guard data.count >= 3 else { return false }
        return data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF
    }

    private func isPNGFormat(_ data: Data) -> Bool {
        guard data.count >= 8 else { return false }
        let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        return data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            return pngSignature.enumerated().allSatisfy { index, byte in
                bytes[index] == byte
            }
        }
    }

    private func convertHEICToJPEG(_ heicData: Data, options: ImageProcessingOptions) async throws -> Data {
        guard let imageSource = CGImageSourceCreateWithData(heicData as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw CardSightAIError.imageProcessingError("Failed to read HEIC image data")
        }

        #if canImport(UIKit)
        let image = UIImage(cgImage: cgImage)
        return try await processForUpload(image, customOptions: options)
        #elseif canImport(AppKit)
        let image = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        return try await processForUpload(image, customOptions: options)
        #endif
    }

    #if canImport(UIKit)
    private func resize(_ image: UIImage, maxDimension: CGFloat) throws -> UIImage {
        let size = image.size

        // Check if resizing is needed
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }

        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        let newSize: CGSize

        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        // Resize the image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: newSize))

        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            throw CardSightAIError.imageProcessingError("Failed to resize image")
        }

        return resizedImage
    }

    private func adjustQualityIfNeeded(_ image: UIImage, initialData: Data, options: ImageProcessingOptions) throws -> Data {
        var jpegData = initialData
        var currentQuality = options.jpegQuality
        let maxSizeBytes = Int(options.maxFileSizeMB * 1024 * 1024)

        // Progressively reduce quality if file is too large
        while jpegData.count > maxSizeBytes && currentQuality > 0.1 {
            currentQuality -= 0.1
            guard let newData = image.jpegData(compressionQuality: currentQuality) else {
                throw CardSightAIError.imageProcessingError("Failed to compress image")
            }
            jpegData = newData
        }

        if jpegData.count > maxSizeBytes {
            throw CardSightAIError.imageProcessingError("Image too large even after compression. Please use a smaller image.")
        }

        return jpegData
    }
    #endif

    #if canImport(AppKit)
    private func resize(_ image: NSImage, maxDimension: CGFloat) throws -> NSImage {
        let size = image.size

        // Check if resizing is needed
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }

        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        let newSize: NSSize

        if size.width > size.height {
            newSize = NSSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = NSSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        // Create resized image
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize))
        resizedImage.unlockFocus()

        return resizedImage
    }

    private func adjustQualityIfNeeded(_ image: NSImage, initialData: Data, options: ImageProcessingOptions) throws -> Data {
        var jpegData = initialData
        var currentQuality = options.jpegQuality
        let maxSizeBytes = Int(options.maxFileSizeMB * 1024 * 1024)

        // Progressively reduce quality if file is too large
        while jpegData.count > maxSizeBytes && currentQuality > 0.1 {
            currentQuality -= 0.1

            guard let tiffData = image.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: tiffData),
                  let newData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: currentQuality]) else {
                throw CardSightAIError.imageProcessingError("Failed to compress image")
            }
            jpegData = newData
        }

        if jpegData.count > maxSizeBytes {
            throw CardSightAIError.imageProcessingError("Image too large even after compression. Please use a smaller image.")
        }

        return jpegData
    }
    #endif
}

// MARK: - UIImage Extensions

#if canImport(UIKit)
extension UIImage {
    /// Returns a copy of the image with corrected orientation
    func correctingOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
#endif