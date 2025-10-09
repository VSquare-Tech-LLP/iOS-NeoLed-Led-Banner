//import SwiftUI
//import AVFoundation
//import Photos
//
//// MARK: - Video Generator with ImageRenderer
//class VideoGenerator {
//    private let frameRate: Int
//    private let duration: Double
//    private let size: CGSize
//    private var viewBuilder: (Int) -> AnyView
//
//    init(frameRate: Int = 30, duration: Double, size: CGSize, viewBuilder: @escaping (Int) -> AnyView) {
//        self.frameRate = frameRate
//        self.duration = duration
//        self.size = size
//        self.viewBuilder = viewBuilder
//    }
//
//    func generateVideo(progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
//        // Start on background thread
//        Task(priority: .userInitiated) {
//            let outputURL = FileManager.default.temporaryDirectory
//                .appendingPathComponent("led_animation_\(UUID().uuidString).mp4")
//
//            try? FileManager.default.removeItem(at: outputURL)
//
//            guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
//                await MainActor.run {
//                    completion(.failure(NSError(domain: "VideoGenerator", code: -1,
//                        userInfo: [NSLocalizedDescriptionKey: "Failed to create video writer"])))
//                }
//                return
//            }
//
//            // Define video settings
//            let videoSettings: [String: Any] = [
//                AVVideoCodecKey: AVVideoCodecType.h264,
//                AVVideoWidthKey: Int(self.size.width),
//                AVVideoHeightKey: Int(self.size.height),
//                AVVideoCompressionPropertiesKey: [
//                    AVVideoAverageBitRateKey: 8000000,
//                    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
//                ]
//            ]
//
//            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
//            videoWriterInput.expectsMediaDataInRealTime = false
//
//            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
//                assetWriterInput: videoWriterInput,
//                sourcePixelBufferAttributes: [
//                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
//                    kCVPixelBufferWidthKey as String: Int(self.size.width),
//                    kCVPixelBufferHeightKey as String: Int(self.size.height),
//                    kCVPixelBufferMetalCompatibilityKey as String: true
//                ]
//            )
//
//            videoWriter.add(videoWriterInput)
//            videoWriter.startWriting()
//            videoWriter.startSession(atSourceTime: .zero)
//
//            let totalFrames = Int(self.duration * Double(self.frameRate))
//            var lastReportedProgress: Double = 0
//
//            for frameNumber in 0..<totalFrames {
//                // Wait for writer to be ready
//                while !videoWriterInput.isReadyForMoreMediaData {
//                    try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
//                }
//
//                // Render frame on main thread but yield control frequently
//                let pixelBuffer = await self.renderFrameWithYield(frameNumber: frameNumber)
//
//                if let pixelBuffer = pixelBuffer {
//                    let presentationTime = CMTime(value: Int64(frameNumber), timescale: Int32(self.frameRate))
//                    adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
//                }
//
//                // Update progress frequently
//                let currentProgress = Double(frameNumber + 1) / Double(totalFrames)
//                if currentProgress - lastReportedProgress >= 0.01 || frameNumber == totalFrames - 1 {
//                    lastReportedProgress = currentProgress
//                    await MainActor.run {
//                        progressHandler(currentProgress)
//                    }
//                }
//
//                // CRITICAL: Yield control every frame to let UI update
//                await Task.yield()
//            }
//
//            // Finish writing
//            videoWriterInput.markAsFinished()
//            await videoWriter.finishWriting()
//
//            // Check completion status
//            await MainActor.run {
//                if videoWriter.status == .completed {
//                    completion(.success(outputURL))
//                } else {
//                    completion(.failure(videoWriter.error ?? NSError(domain: "VideoGenerator", code: -2,
//                        userInfo: [NSLocalizedDescriptionKey: "Video writing failed"])))
//                }
//            }
//        }
//    }
//
//    // Render frame with explicit yielding
//    private func renderFrameWithYield(frameNumber: Int) async -> CVPixelBuffer? {
//        return await MainActor.run {
//            autoreleasepool {
//                let view = self.viewBuilder(frameNumber)
//                let renderer = ImageRenderer(content: view)
//                renderer.proposedSize = ProposedViewSize(self.size)
//                renderer.scale = 2.0
//
//                guard let cgImage = renderer.cgImage else {
//                    print("Failed to render frame \(frameNumber)")
//                    return nil
//                }
//
//                var pixelBuffer: CVPixelBuffer?
//                let attrs = [
//                    kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
//                    kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
//                    kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue
//                ] as CFDictionary
//
//                let status = CVPixelBufferCreate(
//                    kCFAllocatorDefault,
//                    Int(self.size.width),
//                    Int(self.size.height),
//                    kCVPixelFormatType_32BGRA,
//                    attrs,
//                    &pixelBuffer
//                )
//
//                guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
//                    return nil
//                }
//
//                CVPixelBufferLockBaseAddress(buffer, [])
//                defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
//
//                guard let context = CGContext(
//                    data: CVPixelBufferGetBaseAddress(buffer),
//                    width: Int(self.size.width),
//                    height: Int(self.size.height),
//                    bitsPerComponent: 8,
//                    bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
//                    space: CGColorSpaceCreateDeviceRGB(),
//                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
//                ) else {
//                    return nil
//                }
//
//                context.interpolationQuality = .high
//                context.setShouldAntialias(true)
//                context.draw(cgImage, in: CGRect(origin: .zero, size: self.size))
//
//                return buffer
//            }
//        }
//    }
//}
//
//// MARK: - Video Saver
//class VideoSaver: NSObject {
//    var successHandler: (() -> Void)?
//    var errorHandler: ((Error) -> Void)?
//
//    func saveVideo(_ url: URL) {
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else {
//                DispatchQueue.main.async {
//                    self.errorHandler?(NSError(domain: "VideoSaver", code: -1,
//                        userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]))
//                }
//                return
//            }
//
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
//            }) { success, error in
//                DispatchQueue.main.async {
//                    if success {
//                        self.successHandler?()
//                    } else if let error = error {
//                        self.errorHandler?(error)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - ResultView Extension
//extension ResultView {
//
//    func convertViewToVideo(autoDownload: Bool = false) {
//        isProcessing = true
//        progress = 0.0
//
//        let animationDuration = 10.0 / textSpeed
//        let totalFrames = Int(videoDuration * Double(frameRate))
//
//        let videoGenerator = VideoGenerator(
//            frameRate: frameRate,
//            duration: videoDuration,
//            size: CGSize(width: 1080, height: 1920)
//        ) { frameNumber in
//            let progress = Double(frameNumber) / Double(totalFrames)
//            return AnyView(self.createVideoFrame(progress: progress, animationDuration: animationDuration))
//        }
//
//        videoGenerator.generateVideo(progressHandler: { generationProgress in
//            // Update progress on main thread
//            self.progress = generationProgress
//        }) { result in
//            self.isProcessing = false
//
//            switch result {
//            case .success(let url):
//                self.videoURL = url
//                self.progress = 1.0
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.isExporting = false
//                    self.saveVideoToPhotos(url)
//                }
//
//            case .failure(let error):
//                self.isExporting = false
//                self.progress = 0.0
//                self.saveAlertMessage = "Failed to generate video: \(error.localizedDescription)"
//                self.showSaveAlert = true
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func createVideoFrame(progress: Double, animationDuration: Double) -> some View {
//        let videoWidth: CGFloat = 1080
//        let videoHeight: CGFloat = 1920
//        let scaleFactor = videoHeight / 844.0 * 1.5
//        let scaledTextSize = textSize * 50 * scaleFactor
//        let scaledStrokeSize = strokeSize * scaleFactor
//
//        ZStack {
//            if !isHD {
//                getShapeImageForVideo()
//                    .frame(width: videoWidth, height: videoHeight)
//                    .clipped()
//                    .opacity(0.1)
//            }
//
//            let animatedOffsetX = calculateAnimatedOffsetX(
//                progress: progress,
//                geoWidth: videoWidth,
//                geoHeight: videoHeight,
//                scaleFactor: scaleFactor
//            )
//            let animatedOffsetY = calculateAnimatedOffsetY(
//                progress: progress,
//                geoWidth: videoWidth,
//                geoHeight: videoHeight,
//                scaleFactor: scaleFactor
//            )
//
//            let isCurrentlyFlashing = isFlash && (Int(progress * videoDuration * 2) % 2 == 0)
//
//            ZStack {
//                if strokeSize > 0 {
//                    StrokeText(
//                        text: text,
//                        width: scaledStrokeSize,
//                        color: outlineEnabled ? selectedOutlineColor.color : .white,
//                        font: .custom(selectedFont, size: scaledTextSize),
//                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
//                    )
//                    .modifier(ColorModifier(colorOption: selectedColor))
//                    .blur(radius: isLight ? 40 * scaleFactor : 0)
//                    .opacity(isLight ? 0.5 : 1)
//                } else {
//                    Text(text)
//                        .font(.custom(selectedFont, size: scaledTextSize))
//                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
//                        .modifier(ColorModifier(colorOption: selectedColor))
//                        .blur(radius: isLight ? 40 * scaleFactor : 0)
//                        .opacity(isLight ? 0.5 : 1)
//                }
//
//                if strokeSize > 0 {
//                    StrokeText(
//                        text: text,
//                        width: scaledStrokeSize,
//                        color: outlineEnabled ? selectedOutlineColor.color : .white,
//                        font: .custom(selectedFont, size: scaledTextSize),
//                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
//                    )
//                    .kerning(0.6 * scaleFactor)
//                    .modifier(ColorModifier(colorOption: selectedColor))
//                    .blur(radius: isLight ? 20 * scaleFactor : 0)
//                    .opacity(isLight ? 0.7 : 1)
//                } else {
//                    Text(text)
//                        .font(.custom(selectedFont, size: scaledTextSize))
//                        .kerning(0.4 * scaleFactor)
//                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
//                        .modifier(ColorModifier(colorOption: selectedColor))
//                        .blur(radius: isLight ? 20 * scaleFactor : 0)
//                        .opacity(isLight ? 0.7 : 1)
//                }
//
//                if strokeSize > 0 {
//                    StrokeText(
//                        text: text,
//                        width: scaledStrokeSize,
//                        color: outlineEnabled ? selectedOutlineColor.color : .white,
//                        font: .custom(selectedFont, size: scaledTextSize),
//                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
//                    )
//                    .modifier(ColorModifier(colorOption: selectedColor))
//                    .brightness(0.1)
//                    .opacity(isCurrentlyFlashing ? 0.3 : 1.0)
//                } else {
//                    Text(text)
//                        .font(.custom(selectedFont, size: scaledTextSize))
//                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
//                        .modifier(ColorModifier(colorOption: selectedColor))
//                        .brightness(0.1)
//                        .opacity(isCurrentlyFlashing ? 0.3 : 1.0)
//                }
//            }
//            .scaleEffect(x: isMirror ? -1 : 1, y: 1)
//            .fixedSize()
//            .offset(x: animatedOffsetX, y: animatedOffsetY)
//            .rotationEffect(.degrees(getRotation()))
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .if(!isHD) { view in
//                view.mask {
//                    getShapeImageForVideo()
//                        .frame(width: videoWidth, height: videoHeight)
//                        .clipped()
//                }
//            }
//        }
//        .frame(width: videoWidth, height: videoHeight)
//        .background(Color.black)
//    }
//
//    @ViewBuilder
//    private func getShapeImageForVideo() -> some View {
//        switch selectedShape {
//        case "circle":
//            Image(.circle).resizable().aspectRatio(contentMode: .fill)
//        case "square":
//            Image(.square).resizable().aspectRatio(contentMode: .fill)
//        case "heart":
//            Image(.heart).resizable().aspectRatio(contentMode: .fill)
//        case "star":
//            Image(.star).resizable().aspectRatio(contentMode: .fill)
//        case "ninjaStar":
//            Image(.ninjaStar).resizable().aspectRatio(contentMode: .fill)
//        default:
//            Image(.circle).resizable().aspectRatio(contentMode: .fill)
//        }
//    }
//
//    private func calculateAnimatedOffsetX(progress: Double, geoWidth: CGFloat, geoHeight: CGFloat, scaleFactor: CGFloat) -> CGFloat {
//        let estimatedTextWidth = CGFloat(text.count) * (textSize * 50 * scaleFactor) * 0.6
//
//        switch selectedAlignment {
//        case "up":
//            let startPos = geoHeight + estimatedTextWidth / 2
//            let endPos = -estimatedTextWidth / 2
//            return startPos + (endPos - startPos) * progress
//        case "down":
//            let startPos = -(geoHeight + estimatedTextWidth / 2)
//            let endPos = geoHeight + estimatedTextWidth / 2
//            return startPos + (endPos - startPos) * progress
//        case "left", "right":
//            return geoWidth / 2.5
//        default:
//            let startPos: CGFloat = isMirror ? (-estimatedTextWidth / 2) : (geoWidth + estimatedTextWidth / 2)
//            let endPos: CGFloat = isMirror ? (geoWidth + estimatedTextWidth / 2) : (-estimatedTextWidth / 2)
//            return startPos + (endPos - startPos) * progress
//        }
//    }
//
//    private func calculateAnimatedOffsetY(progress: Double, geoWidth: CGFloat, geoHeight: CGFloat, scaleFactor: CGFloat) -> CGFloat {
//        let estimatedTextWidth = CGFloat(text.count) * (textSize * 50 * scaleFactor) * 0.6
//
//        switch selectedAlignment {
//        case "left":
//            let startPos = geoWidth + estimatedTextWidth / 2
//            let endPos = -estimatedTextWidth / 2
//            return startPos + (endPos - startPos) * progress
//        case "right":
//            let startPos = -(geoWidth + estimatedTextWidth / 2)
//            let endPos = geoWidth + estimatedTextWidth / 2
//            return startPos + (endPos - startPos) * progress
//        default:
//            return 0
//        }
//    }
//}
//
//// MARK: - Share Sheet
//struct ShareSheet: UIViewControllerRepresentable {
//    let items: [Any]
//
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        UIActivityViewController(activityItems: items, applicationActivities: nil)
//    }
//
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}


import SwiftUI
import AVFoundation
import Photos

// MARK: - Video Generator with ImageRenderer
class VideoGenerator {
    private let frameRate: Int
    private let duration: Double
    private let size: CGSize
    private var viewBuilder: (Int) -> AnyView
    
    init(frameRate: Int = 30, duration: Double, size: CGSize, viewBuilder: @escaping (Int) -> AnyView) {
        self.frameRate = frameRate
        self.duration = duration
        self.size = size
        self.viewBuilder = viewBuilder
    }
    
    func generateVideo(progressHandler: @escaping (Double) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        // Start on background thread
        Task(priority: .userInitiated) {
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("led_animation_\(UUID().uuidString).mp4")
            
            try? FileManager.default.removeItem(at: outputURL)
            
            guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
                await MainActor.run {
                    completion(.failure(NSError(domain: "VideoGenerator", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to create video writer"])))
                }
                return
            }
            
            // Define video settings
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: Int(self.size.width),
                AVVideoHeightKey: Int(self.size.height),
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 8000000,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
                ]
            ]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            videoWriterInput.expectsMediaDataInRealTime = false
            
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput,
                sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                    kCVPixelBufferWidthKey as String: Int(self.size.width),
                    kCVPixelBufferHeightKey as String: Int(self.size.height),
                    kCVPixelBufferMetalCompatibilityKey as String: true
                ]
            )
            
            videoWriter.add(videoWriterInput)
            videoWriter.startWriting()
            videoWriter.startSession(atSourceTime: .zero)
            
            let totalFrames = Int(self.duration * Double(self.frameRate))
            var lastReportedProgress: Double = 0
            
            for frameNumber in 0..<totalFrames {
                // Wait for writer to be ready
                while !videoWriterInput.isReadyForMoreMediaData {
                    try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                }
                
                // Render frame on main thread but yield control frequently
                let pixelBuffer = await self.renderFrameWithYield(frameNumber: frameNumber)
                
                if let pixelBuffer = pixelBuffer {
                    let presentationTime = CMTime(value: Int64(frameNumber), timescale: Int32(self.frameRate))
                    adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                }
                
                // Update progress frequently
                let currentProgress = Double(frameNumber + 1) / Double(totalFrames)
                if currentProgress - lastReportedProgress >= 0.01 || frameNumber == totalFrames - 1 {
                    lastReportedProgress = currentProgress
                    await MainActor.run {
                        progressHandler(currentProgress)
                    }
                }
                
                // CRITICAL: Yield control every frame to let UI update
                await Task.yield()
            }
            
            // Finish writing
            videoWriterInput.markAsFinished()
            await videoWriter.finishWriting()
            
            // Check completion status
            await MainActor.run {
                if videoWriter.status == .completed {
                    completion(.success(outputURL))
                } else {
                    completion(.failure(videoWriter.error ?? NSError(domain: "VideoGenerator", code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Video writing failed"])))
                }
            }
        }
    }
    
    // Render frame with explicit yielding
    private func renderFrameWithYield(frameNumber: Int) async -> CVPixelBuffer? {
        return await MainActor.run {
            autoreleasepool {
                let view = self.viewBuilder(frameNumber)
                let renderer = ImageRenderer(content: view)
                renderer.proposedSize = ProposedViewSize(self.size)
                renderer.scale = 2.0
                
                guard let cgImage = renderer.cgImage else {
                    print("Failed to render frame \(frameNumber)")
                    return nil
                }
                
                var pixelBuffer: CVPixelBuffer?
                let attrs = [
                    kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                    kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
                    kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue
                ] as CFDictionary
                
                let status = CVPixelBufferCreate(
                    kCFAllocatorDefault,
                    Int(self.size.width),
                    Int(self.size.height),
                    kCVPixelFormatType_32BGRA,
                    attrs,
                    &pixelBuffer
                )
                
                guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
                    return nil
                }
                
                CVPixelBufferLockBaseAddress(buffer, [])
                defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
                
                guard let context = CGContext(
                    data: CVPixelBufferGetBaseAddress(buffer),
                    width: Int(self.size.width),
                    height: Int(self.size.height),
                    bitsPerComponent: 8,
                    bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
                ) else {
                    return nil
                }
                
                context.interpolationQuality = .high
                context.setShouldAntialias(true)
                context.draw(cgImage, in: CGRect(origin: .zero, size: self.size))
                
                return buffer
            }
        }
    }
}

// MARK: - Video Saver
class VideoSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func saveVideo(_ url: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self.errorHandler?(NSError(domain: "VideoSaver", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]))
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.successHandler?()
                    } else if let error = error {
                        self.errorHandler?(error)
                    }
                }
            }
        }
    }
}

// MARK: - ResultView Extension
extension ResultView {
    
//    @ViewBuilder
//     func createVideoFrame(progress: Double, animationDuration: Double) -> some View {
//        let videoWidth: CGFloat = 1080
//        let videoHeight: CGFloat = 1920
//        let scaleFactor = videoHeight / 844.0 * 1.5
//        let scaledTextSize = textSize * 50 * scaleFactor
//        let scaledStrokeSize = strokeSize * scaleFactor
//
//        ZStack {
//            if !isHD {
//                getShapeImageForVideo()
//                    .frame(width: videoWidth, height: videoHeight)
//                    .clipped()
//                    .opacity(0.1)
//            }
//
//            let animatedOffsetX = calculateAnimatedOffsetX(
//                progress: progress,
//                geoWidth: videoWidth,
//                geoHeight: videoHeight,
//                scaleFactor: scaleFactor
//            )
//            let animatedOffsetY = calculateAnimatedOffsetY(
//                progress: progress,
//                geoWidth: videoWidth,
//                geoHeight: videoHeight,
//                scaleFactor: scaleFactor
//            )
//
//            let isCurrentlyFlashing = isFlash && (Int(progress * videoDuration * 2) % 2 == 0)
//
//            ZStack {
//                if strokeSize > 0 {
//                    StrokeText(
//                        text: text,
//                        width: scaledStrokeSize,
//                        color: outlineEnabled ? selectedOutlineColor.color : .white,
//                        font: .custom(selectedFont, size: scaledTextSize),
//                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
//                    )
//                    .modifier(ColorModifier(colorOption: selectedColor))
//                    .blur(radius: isLight ? 40 * scaleFactor : 0)
//                    .opacity(isLight ? 0.5 : 1)
//                } else {
//                    Text(text)
//                        .font(.custom(selectedFont, size: scaledTextSize))
//                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
//                        .modifier(ColorModifier(colorOption: selectedColor))
//                        .blur(radius: isLight ? 40 * scaleFactor : 0)
//                        .opacity(isLight ? 0.5 : 1)
//                }
//
//                if strokeSize > 0 {
//                    StrokeText(
//                        text: text,
//                        width: scaledStrokeSize,
//                        color: outlineEnabled ? selectedOutlineColor.color : .white,
//                        font: .custom(selectedFont, size: scaledTextSize),
//                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
//                    )
//                    .kerning(0.6 * scaleFactor)
//                    .modifier(ColorModifier(colorOption: selectedColor))
//                    .blur(radius: isLight ? 20 * scaleFactor : 0)
//                    .opacity(isLight ? 0.7 : 1)
//                } else {
//                    Text(text)
//                        .font(.custom(selectedFont, size: scaledTextSize))
//                        .kerning(0.4 * scaleFactor)
//                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
//                        .modifier(ColorModifier(colorOption: selectedColor))
//                        .blur(radius: isLight ? 20 * scaleFactor : 0)
//                        .opacity(isLight ? 0.7 : 1)
//                }
//
//                if strokeSize > 0 {
//                    StrokeText(
//                        text: text,
//                        width: scaledStrokeSize,
//                        color: outlineEnabled ? selectedOutlineColor.color : .white,
//                        font: .custom(selectedFont, size: scaledTextSize),
//                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
//                    )
//                    .modifier(ColorModifier(colorOption: selectedColor))
//                    .brightness(0.1)
//                    .opacity(isCurrentlyFlashing ? 0.3 : 1.0)
//                } else {
//                    Text(text)
//                        .font(.custom(selectedFont, size: scaledTextSize))
//                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
//                        .modifier(ColorModifier(colorOption: selectedColor))
//                        .brightness(0.1)
//                        .opacity(isCurrentlyFlashing ? 0.3 : 1.0)
//                }
//            }
//            .scaleEffect(x: isMirror ? -1 : 1, y: 1)
//            .fixedSize()
//            .offset(x: animatedOffsetX, y: animatedOffsetY)
//            .rotationEffect(.degrees(getRotation()))
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .if(!isHD) { view in
//                view.mask {
//                    getShapeImageForVideo()
//                        .frame(width: videoWidth, height: videoHeight)
//                        .clipped()
//                }
//            }
//        }
//        .frame(width: videoWidth, height: videoHeight)
//        .background(Color.black)
//    }
    
    @ViewBuilder
    private func getShapeImageForVideo() -> some View {
        switch selectedShape {
        case "circle":
            Image(.circle).resizable().aspectRatio(contentMode: .fill)
        case "square":
            Image(.square).resizable().aspectRatio(contentMode: .fill)
        case "heart":
            Image(.heart).resizable().aspectRatio(contentMode: .fill)
        case "star":
            Image(.star).resizable().aspectRatio(contentMode: .fill)
        case "ninjaStar":
            Image(.ninjaStar).resizable().aspectRatio(contentMode: .fill)
        default:
            Image(.circle).resizable().aspectRatio(contentMode: .fill)
        }
    }
    
    private func calculateAnimatedOffsetX(progress: Double, geoWidth: CGFloat, geoHeight: CGFloat, scaleFactor: CGFloat) -> CGFloat {
        let estimatedTextWidth = CGFloat(text.count) * (textSize * 50 * scaleFactor) * 0.6
        
        switch selectedAlignment {
        case "up":
            let startPos = geoHeight + estimatedTextWidth / 2
            let endPos = -estimatedTextWidth / 2
            return startPos + (endPos - startPos) * progress
        case "down":
            let startPos = -(geoHeight + estimatedTextWidth / 2)
            let endPos = geoHeight + estimatedTextWidth / 2
            return startPos + (endPos - startPos) * progress
        case "left", "right":
            return geoWidth / 2.5
        default:
            let startPos: CGFloat = isMirror ? (-estimatedTextWidth / 2) : (geoWidth + estimatedTextWidth / 2)
            let endPos: CGFloat = isMirror ? (geoWidth + estimatedTextWidth / 2) : (-estimatedTextWidth / 2)
            return startPos + (endPos - startPos) * progress
        }
    }
    
    private func calculateAnimatedOffsetY(progress: Double, geoWidth: CGFloat, geoHeight: CGFloat, scaleFactor: CGFloat) -> CGFloat {
        let estimatedTextWidth = CGFloat(text.count) * (textSize * 50 * scaleFactor) * 0.6
        
        switch selectedAlignment {
        case "left":
            let startPos = geoWidth + estimatedTextWidth / 2
            let endPos = -estimatedTextWidth / 2
            return startPos + (endPos - startPos) * progress
        case "right":
            let startPos = -(geoWidth + estimatedTextWidth / 2)
            let endPos = geoWidth + estimatedTextWidth / 2
            return startPos + (endPos - startPos) * progress
        default:
            return 0
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let filename: String?
    
    init(items: [Any], filename: String? = nil) {
        self.items = items
        self.filename = filename
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        var itemsToShare: [Any] = []
        
        // If we have a URL and a custom filename, create a temporary file with that name
        if let url = items.first as? URL, let filename = filename {
            let fileExtension = url.pathExtension
            let newFilename = filename + "." + fileExtension
            
            // Create a temporary URL with the custom name
            let tempDir = FileManager.default.temporaryDirectory
            let newURL = tempDir.appendingPathComponent(newFilename)
            
            // Copy the file to the new location
            try? FileManager.default.removeItem(at: newURL) // Remove if exists
            try? FileManager.default.copyItem(at: url, to: newURL)
            
            itemsToShare = [newURL]
        } else {
            itemsToShare = items
        }
        
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
