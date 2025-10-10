//
//  VideoGenerationHelper.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 09/10/25.
//



import SwiftUI
import UIKit

class VideoGenerationHelper {
    
    // MARK: - Video Generation (Always use screen dimensions)
    static func generateVideo(
        text: String,
        selectedFont: String,
        textSize: CGFloat,
        strokeSize: CGFloat,
        selectedColor: ColorOption,
        selectedOutlineColor: OutlineColorOption,
        selectedBgColor: OutlineColorOption,
        outlineEnabled: Bool,
        backgroundEnabled: Bool,
        selectedEffects: Set<String>,
        selectedAlignment: String,
        selectedShape: String,
        textSpeed: CGFloat,
        isHD: Bool,
        selectedLiveBg: String,
        backgroundResultImage: String,
        frameResultBg: String,
        frameRate: Int = 30,
        progressHandler: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        // ALWAYS use screen dimensions for consistent video output
        let videoWidth = UIScreen.main.bounds.width
        let videoHeight = UIScreen.main.bounds.height
        
        // Extract GIF frames if needed
        var gifFrames: [UIImage] = []
        var gifTotalDuration: Double = 2.0
        
        if selectedLiveBg != "None" {
            gifFrames = GIFFrameManager.instance.getFrames(for: selectedLiveBg)
            gifTotalDuration = GIFFrameManager.instance.getTotalDuration(for: selectedLiveBg)
            
            if gifTotalDuration == 0 {
                gifTotalDuration = 2.0
            }
            
            print("GIF '\(selectedLiveBg)': \(gifFrames.count) frames, duration: \(gifTotalDuration)s")
        }
        
        // Calculate video duration
        let animationDuration = 10.0 / textSpeed
        let videoDuration = max(3.0, min(30.0, animationDuration))
        
        print("Video Generation:")
        print("- Video Size: \(videoWidth) x \(videoHeight)")
        print("- Duration: \(videoDuration)s")
        
        // Create video generator
        let videoGenerator = VideoGenerator(
            frameRate: frameRate,
            duration: videoDuration,
            size: CGSize(width: videoWidth, height: videoHeight)
        ) { frameNumber in
            let progress = Double(frameNumber) / Double(Int(videoDuration * Double(frameRate)))
            
            return AnyView(
                createVideoFrame(
                    progress: progress,
                    text: text,
                    selectedFont: selectedFont,
                    textSize: textSize,
                    strokeSize: strokeSize,
                    selectedColor: selectedColor,
                    selectedOutlineColor: selectedOutlineColor,
                    selectedBgColor: selectedBgColor,
                    outlineEnabled: outlineEnabled,
                    backgroundEnabled: backgroundEnabled,
                    selectedEffects: selectedEffects,
                    selectedAlignment: selectedAlignment,
                    selectedShape: selectedShape,
                    textSpeed: textSpeed,
                    isHD: isHD,
                    selectedLiveBg: selectedLiveBg,
                    backgroundResultImage: backgroundResultImage,
                    frameResultBg: frameResultBg,
                    videoWidth: videoWidth,
                    videoHeight: videoHeight,
                    videoDuration: videoDuration,
                    gifFrames: gifFrames,
                    gifTotalDuration: gifTotalDuration
                )
            )
        }
        
        videoGenerator.generateVideo(progressHandler: progressHandler, completion: completion)
    }
    
    // MARK: - Create Video Frame
    @ViewBuilder
    private static func createVideoFrame(
        progress: Double,
        text: String,
        selectedFont: String,
        textSize: CGFloat,
        strokeSize: CGFloat,
        selectedColor: ColorOption,
        selectedOutlineColor: OutlineColorOption,
        selectedBgColor: OutlineColorOption,
        outlineEnabled: Bool,
        backgroundEnabled: Bool,
        selectedEffects: Set<String>,
        selectedAlignment: String,
        selectedShape: String,
        textSpeed: CGFloat,
        isHD: Bool,
        selectedLiveBg: String,
        backgroundResultImage: String,
        frameResultBg: String,
        videoWidth: CGFloat,
        videoHeight: CGFloat,
        videoDuration: Double,
        gifFrames: [UIImage],
        gifTotalDuration: Double
    ) -> some View {
        
        let isBold = selectedEffects.contains("Bold")
        let isItalic = selectedEffects.contains("Italic")
        let isLight = selectedEffects.contains("Blink")
        let isFlash = selectedEffects.contains("Glow")
        let isMirror = selectedEffects.contains("Mirror")
        
        let referenceDimension = max(videoWidth, videoHeight)
        let scaleFactor = referenceDimension / 844.0
        
        let scaledTextSize = textSize * 50 * scaleFactor
        let scaledStrokeSize = strokeSize * scaleFactor
        
        ZStack {

            // Background rendering
            if selectedLiveBg != "None" && !gifFrames.isEmpty {
                let currentTime = progress * videoDuration
                let gifProgress = (currentTime / gifTotalDuration).truncatingRemainder(dividingBy: 1.0)
                let frameIndex = Int(gifProgress * Double(gifFrames.count))
                let safeFrameIndex = min(max(frameIndex, 0), gifFrames.count - 1)
                
                // Use the same logic as ResultView for consistency
                ZStack {
                    Image(uiImage: gifFrames[safeFrameIndex])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .rotationEffect(.degrees(90))
                        .frame(
                            width: videoHeight,
                            height: videoWidth
                        )
                        .position(x: videoWidth / 2, y: videoHeight / 2)
                }
                .frame(width: videoWidth, height: videoHeight)
                .clipped()
                .if(!isHD) { view in
                    view.mask {
                        getShapeImageForVideo(selectedShape: selectedShape)
                            .frame(width: videoWidth, height: videoHeight)
                    }
                }
            } else if backgroundResultImage != "" {
                Image(backgroundResultImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: videoWidth, height: videoHeight)
                    .clipped()
                    .if(!isHD) { view in
                        view.mask {
                            getShapeImageForVideo(selectedShape: selectedShape)
                                .frame(width: videoWidth, height: videoHeight)
                        }
                    }
            }
            
            // Background shape
            if !isHD {
                getShapeImageForVideo(selectedShape: selectedShape)
                    .frame(width: videoWidth, height: videoHeight)
                    .clipped()
                    .opacity(0.1)
            }
            
            let animatedOffsetX = calculateAnimatedOffsetX(
                progress: progress,
                geoWidth: videoWidth,
                geoHeight: videoHeight,
                scaleFactor: scaleFactor,
                textSize: textSize,
                text: text,
                selectedFont: selectedFont,
                strokeSize: strokeSize,
                isBold: isBold,
                isItalic: isItalic,
                selectedAlignment: selectedAlignment,
                isMirror: isMirror
            )
            
            let animatedOffsetY = calculateAnimatedOffsetY(
                progress: progress,
                geoWidth: videoWidth,
                geoHeight: videoHeight,
                scaleFactor: scaleFactor,
                textSize: textSize,
                text: text,
                selectedFont: selectedFont,
                strokeSize: strokeSize,
                isBold: isBold,
                isItalic: isItalic,
                selectedAlignment: selectedAlignment,
                isMirror: isMirror
            )
            
            let isCurrentlyFlashing = isFlash && (Int(progress * videoDuration * 2) % 2 == 0)
            
            // Text rendering
            ZStack {
                // Layer 1: Blurred glow
                if strokeSize > 0 {
                    StrokeText(
                        text: text,
                        width: scaledStrokeSize,
                        color: outlineEnabled ? selectedOutlineColor.color : .white,
                        font: .custom(selectedFont, size: scaledTextSize),
                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
                    )
                    .modifier(ColorModifier(colorOption: selectedColor))
                    .blur(radius: isLight ? (40 * scaleFactor) : 0)
                    .opacity(isLight ? 0.5 : 1)
                } else {
                    Text(text)
                        .font(.custom(selectedFont, size: scaledTextSize))
                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
                        .modifier(ColorModifier(colorOption: selectedColor))
                        .blur(radius: isLight ? (40 * scaleFactor) : 0)
                        .opacity(isLight ? 0.5 : 1)
                }
                
                // Layer 2: Middle glow
                if isLight {
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
                        .blur(radius: 20 * scaleFactor)
                        .opacity(0.7)
                    } else {
                        Text(text)
                            .font(.custom(selectedFont, size: scaledTextSize))
                            .kerning(0.4 * scaleFactor)
                            .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
                            .modifier(ColorModifier(colorOption: selectedColor))
                            .blur(radius: 20 * scaleFactor)
                            .opacity(0.7)
                    }
                }
                
                // Layer 3: Sharp text
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
            .rotationEffect(.degrees(getRotation(selectedAlignment: selectedAlignment, isMirror: isMirror)))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .if(!isHD) { view in
                view.mask {
                    getShapeImageForVideo(selectedShape: selectedShape)
                        .frame(width: videoWidth, height: videoHeight)
                        .clipped()
                }
            }
        }
        .overlay {
            Image(frameResultBg)
                .resizable()
                .frame(width: videoWidth, height: videoHeight)
                .if(!isHD) { view in
                    view.mask {
                        getShapeImageForVideo(selectedShape: selectedShape)
                            .frame(width: videoWidth, height: videoHeight)
                    }
                }
        }
        .frame(width: videoWidth, height: videoHeight)
        .background(backgroundEnabled ? selectedBgColor.color : Color.secondaryApp)
    }
    
    // MARK: - Helper Functions
    
    private static func calculateActualTextWidth(
        scaleFactor: CGFloat,
        textSize: CGFloat,
        text: String,
        selectedFont: String,
        strokeSize: CGFloat,
        isBold: Bool,
        isItalic: Bool
    ) -> CGFloat {
        let scaledTextSize = textSize * 50 * scaleFactor
        
        let fontName = FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic)
        let font = UIFont(name: fontName, size: scaledTextSize) ?? UIFont.systemFont(ofSize: scaledTextSize)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let calculatedSize = (text as NSString).size(withAttributes: attributes)
        
        let strokePadding = (strokeSize * scaleFactor) * 6
        let safetyBuffer = scaledTextSize * 0.5
        
        return calculatedSize.width + strokePadding + safetyBuffer
    }
    
    private static func calculateAnimatedOffsetX(
        progress: Double,
        geoWidth: CGFloat,
        geoHeight: CGFloat,
        scaleFactor: CGFloat,
        textSize: CGFloat,
        text: String,
        selectedFont: String,
        strokeSize: CGFloat,
        isBold: Bool,
        isItalic: Bool,
        selectedAlignment: String,
        isMirror: Bool
    ) -> CGFloat {
        let actualTextWidth = calculateActualTextWidth(
            scaleFactor: scaleFactor,
            textSize: textSize,
            text: text,
            selectedFont: selectedFont,
            strokeSize: strokeSize,
            isBold: isBold,
            isItalic: isItalic
        )
        let scaledTextSize = textSize * 50 * scaleFactor
        let extraBuffer = scaledTextSize * 3
        
        switch selectedAlignment {
        case "up":
            let startPos = geoHeight + actualTextWidth / 2
            let endPos = -(actualTextWidth / 2) - extraBuffer
            return startPos + (endPos - startPos) * progress
            
        case "down":
            let startPos = -(geoHeight + actualTextWidth / 2)
            let endPos = (geoHeight + actualTextWidth / 2) + extraBuffer
            return startPos + (endPos - startPos) * progress
            
        case "left", "right":
            return geoWidth / 2 - 200
            
        default:
            let startPos: CGFloat = isMirror ? (-(actualTextWidth / 2) - extraBuffer) : (geoWidth + actualTextWidth / 2)
            let endPos: CGFloat = isMirror ? (geoWidth + actualTextWidth / 2) : (-(actualTextWidth / 2) - extraBuffer)
            return startPos + (endPos - startPos) * progress
        }
    }
    
    private static func calculateAnimatedOffsetY(
        progress: Double,
        geoWidth: CGFloat,
        geoHeight: CGFloat,
        scaleFactor: CGFloat,
        textSize: CGFloat,
        text: String,
        selectedFont: String,
        strokeSize: CGFloat,
        isBold: Bool,
        isItalic: Bool,
        selectedAlignment: String,
        isMirror: Bool
    ) -> CGFloat {
        let actualTextWidth = calculateActualTextWidth(
            scaleFactor: scaleFactor,
            textSize: textSize,
            text: text,
            selectedFont: selectedFont,
            strokeSize: strokeSize,
            isBold: isBold,
            isItalic: isItalic
        )
        let scaledTextSize = textSize * 50 * scaleFactor
        let extraBuffer = scaledTextSize * 3
        
        switch selectedAlignment {
        case "left":
            let startPos = -(geoWidth + actualTextWidth / 2)
            let endPos = (geoWidth + actualTextWidth / 2) + extraBuffer
            return startPos + (endPos - startPos) * progress
            
        case "right":
            let startPos = geoWidth + actualTextWidth / 2
            let endPos = -(actualTextWidth / 2) - extraBuffer
            return startPos + (endPos - startPos) * progress
            
        case "up", "down":
            return 0
            
        default:
            return 0
        }
    }
    
    private static func getRotation(selectedAlignment: String, isMirror: Bool) -> Double {
        switch selectedAlignment {
        case "left":
            return -270
        case "right":
            return 90
        case "up":
            return -270
        case "down":
            return -270
        default:
            return isMirror ? 90 : -270
        }
    }
    
    @ViewBuilder
    private static func getShapeImageForVideo(selectedShape: String) -> some View {
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
}
