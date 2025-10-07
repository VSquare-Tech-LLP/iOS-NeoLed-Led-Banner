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
    
    @MainActor
    func generateVideo(completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("led_animation_\(UUID().uuidString).mp4")
            
            try? FileManager.default.removeItem(at: outputURL)
            
            guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
                completion(.failure(NSError(domain: "VideoGenerator", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to create video writer"])))
                return
            }
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: Int(size.width),
                AVVideoHeightKey: Int(size.height),
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
                    kCVPixelBufferWidthKey as String: Int(size.width),
                    kCVPixelBufferHeightKey as String: Int(size.height),
                    kCVPixelBufferMetalCompatibilityKey as String: true
                ]
            )
            
            videoWriter.add(videoWriterInput)
            videoWriter.startWriting()
            videoWriter.startSession(atSourceTime: .zero)
            
            let totalFrames = Int(duration * Double(frameRate))
            
            for frameNumber in 0..<totalFrames {
                while !videoWriterInput.isReadyForMoreMediaData {
                    try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                }
                
                autoreleasepool {
                    let presentationTime = CMTime(value: Int64(frameNumber), timescale: Int32(frameRate))
                    
                    if let pixelBuffer = self.renderFrame(frameNumber: frameNumber) {
                        adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                    }
                }
            }
            
            videoWriterInput.markAsFinished()
            await videoWriter.finishWriting()
            
            if videoWriter.status == .completed {
                completion(.success(outputURL))
            } else {
                completion(.failure(videoWriter.error ?? NSError(domain: "VideoGenerator", code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Video writing failed"])))
            }
        }
    }
    
    @MainActor
    private func renderFrame(frameNumber: Int) -> CVPixelBuffer? {
        let view = viewBuilder(frameNumber)
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(size)
        renderer.scale = 2.0 // Higher quality
        
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
            Int(size.width),
            Int(size.height),
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
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else {
            return nil
        }
        
        context.interpolationQuality = .high
        context.setShouldAntialias(true)
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        return buffer
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
    
    func convertViewToVideo() {
        isProcessing = true
        
        // Calculate animation parameters
        let animationDuration = 10.0 / textSpeed
        let totalFrames = Int(videoDuration * Double(frameRate))
        
        let videoGenerator = VideoGenerator(
            frameRate: frameRate,
            duration: videoDuration,
            size: CGSize(width: 1080, height: 1920)
        ) { frameNumber in
            let progress = Double(frameNumber) / Double(totalFrames)
            return AnyView(self.createVideoFrame(progress: progress, animationDuration: animationDuration))
        }
        
        Task { @MainActor in
            videoGenerator.generateVideo { result in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    switch result {
                    case .success(let url):
                        self.videoURL = url
                    case .failure(let error):
                        self.saveAlertMessage = "Failed to generate video: \(error.localizedDescription)"
                        self.showSaveAlert = true
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func createVideoFrame(progress: Double, animationDuration: Double) -> some View {
        let videoWidth: CGFloat = 1080
        let videoHeight: CGFloat = 1920
        
        // Scale factor: increase significantly for better video coverage
        // Original design ~390x844, video is 1080x1920 - scale based on height for better vertical coverage
        let scaleFactor = videoHeight / 844.0 * 1.5 // Extra 1.5x to fill more space
        let scaledTextSize = textSize * 50 * scaleFactor
        let scaledStrokeSize = strokeSize * scaleFactor
        
        ZStack {
            // Background shape - fill entire screen
            if !isHD {
                getShapeImageForVideo()
                    .frame(width: videoWidth, height: videoHeight)
                    .clipped()
                    .opacity(0.1)
            }
            
            // Calculate animated position based on progress
            let animatedOffsetX = calculateAnimatedOffsetX(
                progress: progress,
                geoWidth: videoWidth,
                geoHeight: videoHeight,
                scaleFactor: scaleFactor
            )
            let animatedOffsetY = calculateAnimatedOffsetY(
                progress: progress,
                geoWidth: videoWidth,
                geoHeight: videoHeight,
                scaleFactor: scaleFactor
            )
            
            // Flash effect calculation
            let isCurrentlyFlashing = isFlash && (Int(progress * videoDuration * 2) % 2 == 0)
            
            // Text layers
            ZStack {
                // Blur layer 1
                if strokeSize > 0 {
                    StrokeText(
                        text: text,
                        width: scaledStrokeSize,
                        color: outlineEnabled ? selectedOutlineColor.color : .white,
                        font: .custom(selectedFont, size: scaledTextSize),
                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
                    )
                    .modifier(ColorModifier(colorOption: selectedColor))
                    .blur(radius: isLight ? 40 * scaleFactor : 0)
                    .opacity(isLight ? 0.5 : 1)
                } else {
                    Text(text)
                        .font(.custom(selectedFont, size: scaledTextSize))
                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
                        .modifier(ColorModifier(colorOption: selectedColor))
                        .blur(radius: isLight ? 40 * scaleFactor : 0)
                        .opacity(isLight ? 0.5 : 1)
                }
                
                // Blur layer 2
                if strokeSize > 0 {
                    StrokeText(
                        text: text,
                        width: scaledStrokeSize,
                        color: outlineEnabled ? selectedOutlineColor.color : .white,
                        font: .custom(selectedFont, size: scaledTextSize),
                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
                    )
                    .kerning(0.6 * scaleFactor)
                    .modifier(ColorModifier(colorOption: selectedColor))
                    .blur(radius: isLight ? 20 * scaleFactor : 0)
                    .opacity(isLight ? 0.7 : 1)
                } else {
                    Text(text)
                        .font(.custom(selectedFont, size: scaledTextSize))
                        .kerning(0.4 * scaleFactor)
                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
                        .modifier(ColorModifier(colorOption: selectedColor))
                        .blur(radius: isLight ? 20 * scaleFactor : 0)
                        .opacity(isLight ? 0.7 : 1)
                }
                
                // Sharp text layer
                if strokeSize > 0 {
                    StrokeText(
                        text: text,
                        width: scaledStrokeSize,
                        color: outlineEnabled ? selectedOutlineColor.color : .white,
                        font: .custom(selectedFont, size: scaledTextSize),
                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
                    )
                    .modifier(ColorModifier(colorOption: selectedColor))
                    .brightness(0.1)
                    .opacity(isCurrentlyFlashing ? 0.3 : 1.0)
                } else {
                    Text(text)
                        .font(.custom(selectedFont, size: scaledTextSize))
                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
                        .modifier(ColorModifier(colorOption: selectedColor))
                        .brightness(0.1)
                        .opacity(isCurrentlyFlashing ? 0.3 : 1.0)
                }
            }
            .scaleEffect(x: isMirror ? -1 : 1, y: 1)
            .fixedSize()
            .offset(x: animatedOffsetX, y: animatedOffsetY)
            .rotationEffect(.degrees(getRotation()))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .if(!isHD) { view in
                view.mask {
                    getShapeImageForVideo()
                        .frame(width: videoWidth, height: videoHeight)
                        .clipped()
                }
            }
        }
        .frame(width: videoWidth, height: videoHeight)
        .background(Color.black)
    }
    
    @ViewBuilder
    private func getShapeImageForVideo() -> some View {
        switch selectedShape {
        case "circle":
            Image(.circle)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case "square":
            Image(.square)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case "heart":
            Image(.heart)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case "star":
            Image(.star)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case "ninjaStar":
            Image(.ninjaStar)
                .resizable()
                .aspectRatio(contentMode: .fill)
        default:
            Image(.circle)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    private func calculateAnimatedOffsetX(progress: Double, geoWidth: CGFloat, geoHeight: CGFloat, scaleFactor: CGFloat) -> CGFloat {
        // Estimate text width based on character count and font size
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
            return geoWidth / 2.5 // Adjusted for video dimensions
            
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
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

