//
//  ResultView.swift
//  NeoLed
//

import SwiftUI

struct ResultView: View {
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    @StateObject private var viewModel = LEDDesignViewModel()
    let backgroundResultImage: String
    let backgroundImage: String
    let text: String
    let selectedFont: String
    let textSize: CGFloat
    let strokeSize: CGFloat
    let selectedColor: ColorOption
    let selectedOutlineColor: OutlineColorOption
    let selectedBgColor: OutlineColorOption
    let backgroundEnabled: Bool
    let outlineEnabled: Bool
    let hasCustomTextColor: Bool
    let customTextColor: UIColor

    let selectedEffects: Set<String>
    let selectedAlignment: String
    let selectedShape: String
    let textSpeed: CGFloat
    let isHD: Bool
    let selectedLiveBg: String
    let frameResultBg: String
    let frameBg: String
    let isSaved: Bool
    
    var isBold: Bool { selectedEffects.contains("Bold") }
    var isItalic: Bool { selectedEffects.contains("Italic") }
    var isLight: Bool { selectedEffects.contains("Blink") }
    var isFlash: Bool { selectedEffects.contains("Glow") }
    var isMirror: Bool { selectedEffects.contains("Mirror") }
    var onBack: () -> Void
   
    @State var isFlashing = false
    
    @State var offsetx: CGFloat = 0
    @State var offsety: CGFloat = 0
    @State var textWidth: CGFloat = 0
    @State var show = false
    
    @State var videoURL: URL? = nil
    @State var showShareSheet: Bool = false
    @State var showSaveAlert: Bool = false
    @State var saveAlertMessage: String = ""
    @State var isProcessing: Bool = false
    
    @State var videoDuration: Double = 5.0
    @State var frameRate: Int = 30
    
    @State private var blinkPhase: Bool = false
    
    @State var progress: Double = 0.0
    @State var isExporting: Bool = false
    @State private var timer: Timer? = nil
    
    @State var scaledTextSize: CGFloat = 50
    @State var scaledTextSpeed: CGFloat = 1.0
    
    @State var geoWidth: CGFloat = 0
    @State var geoHeight: CGFloat = 0
    
    @State private var gifFrames: [UIImage] = []
    @State private var gifTotalDuration: Double = 2.0  // Default
    @State var actualMeasuredTextWidth: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            
            GeometryReader { geo in
                
                ZStack {
                    
                    if backgroundResultImage != "" {
                        Image(backgroundResultImage)
                            .resizable()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .if(!isHD) { view in
                                view.mask {
                                    getShapeImage()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                }
                            }
                    }
                    
                    if selectedLiveBg != "None" {
                        GifuGIFView(name: selectedLiveBg)
                            .rotationEffect(.degrees(90))
                            .frame(
                                width: UIScreen.main.bounds.height,
                                height: UIScreen.main.bounds.width
                            )
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                            .if(!isHD) { view in
                                view.mask {
                                    getShapeImage()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                }
                            }
                    }
                    
                    if !isHD {
                        getShapeImage()
                            .frame(width: geo.size.width, height: geo.size.height )
                            .opacity(0.1)
                    }
                }
                
                
                ZStack {
                    // Blurred glow layers behind
                    if strokeSize > 0 {
                        Text(text)
                            .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                          size:  .scaledFontSize(textSize * 50)))
                            .modifier(ColorModifier(colorOption: selectedColor))
                            .stroke(
                                color: outlineEnabled ? selectedOutlineColor.color : .white,
                                width: strokeSize
                            )
                            .blur(radius: isLight ? 40 : 0)
                            .opacity(isLight ? 0.5 : 1)
                    } else {
                        Text(text)
                            .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                          size:  .scaledFontSize(textSize * 50)))
                            .modifier(ColorModifier(colorOption: selectedColor))
                            .blur(radius: isLight ? 40 : 0)
                            .opacity(isLight ? 0.5 : 1)
                    }
                    
                    // Middle glow layer for Blink effect
                    if isLight {
                        if strokeSize > 0 {
                            Text(text)
                                .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                              size:  .scaledFontSize(textSize * 50)))
                                .modifier(ColorModifier(colorOption: selectedColor))
                                .stroke(
                                    color: outlineEnabled ? selectedOutlineColor.color : .white,
                                    width: strokeSize
                                )
                                .kerning(0.6)
                                .blur(radius: 20)
                                .opacity(0.7)
                        } else {
                            Text(text)
                                .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                              size:  .scaledFontSize(textSize * 50)))
                                .kerning(0.4)
                                .modifier(ColorModifier(colorOption: selectedColor))
                                .blur(radius: 20)
                                .opacity(0.7)
                        }
                    }
                    
                    // Sharp text on top
                    if strokeSize > 0 {
                        Text(text)
                            .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                          size:  .scaledFontSize(textSize * 50)))
                            .modifier(ColorModifier(colorOption: selectedColor))
                            .stroke(
                                color: outlineEnabled ? selectedOutlineColor.color : .white,
                                width: strokeSize
                            )
                            .brightness(0.1)
                            .opacity(isFlash && blinkPhase ? 0.1 : 1.0)
                    } else {
                        Text(text)
                            .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                          size:  .scaledFontSize(textSize * 50)))
                            .modifier(ColorModifier(colorOption: selectedColor))
                            .brightness(0.1)
                            .opacity(isFlash && blinkPhase ? 0.1 : 1.0)
                    }
                }
                .scaleEffect(x: isMirror ? -1 : 1, y: 1)
                .frame(height: isIPad ? ScaleUtility.scaledValue(500) : ScaleUtility.scaledValue(200))
                .fixedSize()
                .padding(.all, strokeSize * 3)
                .clipped()
                .background { GeometryReader { textgeometry -> Color in
                    DispatchQueue.main.async {
                        self.textWidth = textgeometry.size.width
                        self.actualMeasuredTextWidth = textgeometry.size.width
                    }
                    return Color.clear
                }
                }
                .offset(x: getOffsetX(), y: getOffsetY())
                .rotationEffect(.degrees(getRotation()))
                .position(x: geo.size.width / 2)
                .if(!isHD) { view in
                    view.mask {
                        getShapeImage()
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        switch selectedAlignment {
                        case "up":
                            offsetx = geo.size.height + textWidth / 2
                        case "down":
                            offsetx = -(geo.size.height + textWidth / 2)
                        case "left":
                            offsety = geo.size.width + textWidth / 2
                        case "right":
                            offsety = -(geo.size.width + textWidth / 2)
                        default:
                            offsetx = geo.size.height + textWidth / 2
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let animationDuration = 10.0 / textSpeed
                        
                        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                            switch selectedAlignment {
                            case "up":
                                offsetx = -textWidth / 2
                            case "down":
                                offsetx = geo.size.height + textWidth / 2
                            case "left":
                                offsety = -textWidth / 2
                            case "right":
                                offsety = geo.size.width + textWidth / 2
                            default:
                                offsetx = -textWidth / 2
                            }
                        }
                    }
                    
                    
                    // Flash effect - reset and restart
                    if isFlash {
                        withAnimation(
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            blinkPhase = true
                        }
                    }
                    
                    
                    self.geoWidth = geo.size.width
                    self.geoHeight = geo.size.height
                    let scaleFactor = min(max(geo.size.height / 800.0, 1.0), 2.0) // Adjust scale factor (between 1x and 2x)
                    scaledTextSize = textSize * scaleFactor
                    scaledTextSpeed = textSpeed * scaleFactor
                }
                .overlay {
                    
                    Image(frameResultBg)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all)
                        .if(!isHD) { view in
                            view.mask {
                                getShapeImage()
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                }
                .ignoresSafeArea(.all)
                .onAppear(){
                    // Calculate video duration dynamically when the view appears
                    calculateVideoDuration(geoWidth: UIScreen.main.bounds.width, geoHeight: UIScreen.main.bounds.height)
                }
                
                
            }
            
            
            HStack {
                
                Button {
                    impactFeedback.impactOccurred()
                    onBack()
                } label: {
                    Image(.backIcon)
                        .resizable()
                        .frame(width: isIPad ?  ScaleUtility.scaledValue(51) : ScaleUtility.scaledValue(34),
                               height: isIPad ?  ScaleUtility.scaledValue(51) : ScaleUtility.scaledValue(34))
                        .background {
                            EllipticalGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                    Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                                ],
                                center: UnitPoint(x: 0.36, y: 0.34)
                            )
                        }
                        .cornerRadius(4.04762)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4.04762)
                                .stroke(Color.accent, lineWidth: 1)
                        }
                }

        
                Spacer()
                
                HStack(spacing: ScaleUtility.scaledSpacing(14.57)) {
                    
                    // Share Video Button
                    Button {
                        AnalyticsManager.shared.log(.shared)
                        impactFeedback.impactOccurred()
                        if let url = videoURL {
                            // Video already exists, just show share sheet
                            showShareSheet = true
                        } else {
                            // Need to generate video first
                            isExporting = true
                            convertViewToVideo(isShare: true, geoWidth: geoWidth, geoHeight: geoHeight)
                        }
                    } label: {

                            Image(.shareIcon1)
                                .resizable()
                                .frame(width: isIPad ?  ScaleUtility.scaledValue(28.42857) : ScaleUtility.scaledValue(19.42857),
                                       height: isIPad ?  ScaleUtility.scaledValue(28.42857) : ScaleUtility.scaledValue(19.42857))
                        
                    }
                    .padding(.all, ScaleUtility.scaledSpacing(7.29))
                    .background {
                        EllipticalGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                            ],
                            center: UnitPoint(x: 0.36, y: 0.34)
                        )
                    }
                    .cornerRadius(4.04762)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4.04762)
                            .stroke(Color.accent, lineWidth: 1)
                    }
                    .disabled(isProcessing)
                    
                    // Download Video Button
                    // Download Video Button
                    Button {
                        AnalyticsManager.shared.log(.downloaded)
                        impactFeedback.impactOccurred()
                        // Make sure text width is measured first
                        if actualMeasuredTextWidth == 0 {
                            // Wait a moment for measurement
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let url = videoURL {
                                    saveVideoToPhotos(url)
                                } else {
                                    isExporting = true
                                    convertViewToVideo(isShare: false, geoWidth: geoWidth, geoHeight: geoHeight)
                                }
                            }
                        } else {
                            if let url = videoURL {
                                saveVideoToPhotos(url)
                            } else {
                                isExporting = true
                                convertViewToVideo(isShare: false, geoWidth: geoWidth, geoHeight: geoHeight)
                            }
                        }
                    } label: {
                            Image(.downloadIcon)
                                .resizable()
                                .frame(width: isIPad ?  ScaleUtility.scaledValue(28.42857) : ScaleUtility.scaledValue(19.42857),
                                       height: isIPad ?  ScaleUtility.scaledValue(28.42857) : ScaleUtility.scaledValue(19.42857))
                    }
                    .padding(.all, ScaleUtility.scaledSpacing(7.29))
                    .background {
                        EllipticalGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                            ],
                            center: UnitPoint(x: 0.36, y: 0.34)
                        )
                    }
                    .cornerRadius(4.04762)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4.04762)
                            .stroke(Color.accent, lineWidth: 1)
                    }
                    .disabled(isProcessing)
                }
                .sheet(isPresented: $showShareSheet) {
                    if let url = videoURL {
                        ShareSheet(items: [url], filename: "NeoLed Video")
                    }
                }
                .alert("Video Status", isPresented: $showSaveAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(saveAlertMessage)
                }
                .tint(.blue)
            }
            .padding(.horizontal,ScaleUtility.scaledSpacing(28))
            .padding(.top,ScaleUtility.scaledSpacing(59))
            
        }
        .overlay {
            if isExporting {
                ZStack {
                    // Semi-transparent background
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                        // Text overlay
                        Text("Exporting Video...")
                            .font(.system(size: .scaledFontSize(20), weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Progress percentage
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: .scaledFontSize(16), weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        // Progress bar
                        ZStack(alignment: .leading) {
                            // Background capsule
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: ScaleUtility.scaledValue(250), height: ScaleUtility.scaledValue(8))
                            
                            // Progress capsule
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: ScaleUtility.scaledValue(250) * CGFloat(progress), height: ScaleUtility.scaledValue(8))
                                .animation(.linear(duration: 0.3), value: progress)
                        }
                    }
                    .padding( ScaleUtility.scaledSpacing(40))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.8))
                            .shadow(radius: 10)
                    )
                }
            }
        }
        .onDisappear {
            // Auto-save when leaving the view
            if isSaved {
                saveDesignToHistory()
            }
        }
        
        .background {
            if backgroundEnabled {
                selectedBgColor.color
            }
            else {
                Color.secondaryApp
            }
           
        }
        .ignoresSafeArea(.all)
        .navigationBarHidden(true)
        .ignoresSafeArea(.all)
        .onAppear(){
            let animationDuration = 10.0 / textSpeed
            
            withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                show.toggle()
            }
        }
        .onChange(of: isFlash) { _, newValue in
            if newValue {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                ) {
                    blinkPhase = true
                }
            } else {
                blinkPhase = false
            }
        }
    }
    
    
    private func saveDesignToHistory() {
        viewModel.saveDesign(
            backgroundResultImage: backgroundResultImage,
            backgroundImage: backgroundImage,
            text: text,
            selectedFont: selectedFont,
            textSize: textSize,
            strokeSize: strokeSize,
            selectedColor: selectedColor,
            selectedOutlineColor: selectedOutlineColor,
            selectedBgColor: selectedBgColor,
            backgroundEnabled: backgroundEnabled,
            outlineEnabled: outlineEnabled,
            hasCustomTextColor: hasCustomTextColor,
            customTextColor: customTextColor,
            selectedEffects: selectedEffects,
            selectedAlignment: selectedAlignment,
            selectedShape: selectedShape,
            textSpeed: textSpeed,
            isHD: isHD,
            selectedLiveBg: selectedLiveBg,
            frameResultBg: frameResultBg,
            frameBg: frameBg
        )
        
        saveAlertMessage = "Design saved to history!"
        showSaveAlert = true
    }
    
    func saveVideoToPhotos(_ url: URL) {
        let videoSaver = VideoSaver()
        videoSaver.successHandler = {
            saveAlertMessage = "Video successfully saved to your photo library."
            showSaveAlert = true
        }
        videoSaver.errorHandler = { error in
            saveAlertMessage = "Error saving video: \(error.localizedDescription)"
            showSaveAlert = true
        }
        videoSaver.saveVideo(url)
    }
    
    func getShadowColor() -> Color {
        switch selectedColor.type {
        case .solid(let color):
            return color
        case .linearGradient(let gradientData):
            // Use the first color from the gradient for glow
            return gradientData.stops.first?.color ?? .white
        }
    }
    
    func calculateVideoDuration(geoWidth: CGFloat, geoHeight: CGFloat) {
        // MATCH THE LIVE PREVIEW EXACTLY
        // The live preview uses: animationDuration = 10.0 / textSpeed
        // This is NOT distance-based, it's a fixed formula
        let animationDuration = 10.0 / textSpeed
        
        // Ensure reasonable bounds
        videoDuration = max(3.0, min(30.0, animationDuration))
        
        print("Video Duration Calculation:")
        print("- Text Speed: \(textSpeed)")
        print("- Animation Duration: \(animationDuration)s")
        print("- Final Duration: \(videoDuration)s")
    }
    
    
    // Calculate actual text width using UIFont metrics OR measured width
    private func calculateActualTextWidth(scaleFactor: CGFloat) -> CGFloat {
        // If we have a measured width from the live preview, scale it and use it
        if actualMeasuredTextWidth > 0 {
            // The measured width is from the live preview with its scale
            // We need to adjust it for the video's scale factor
            let livePreviewScaleFactor = geoHeight / 844.0
            let widthRatio = scaleFactor / livePreviewScaleFactor
            return actualMeasuredTextWidth * widthRatio
        }
        
        // Fallback: calculate using UIFont metrics
        let scaledTextSize = textSize * 50 * scaleFactor
        
        let fontName = FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic)
        let font = UIFont(name: fontName, size: scaledTextSize) ?? UIFont.systemFont(ofSize: scaledTextSize)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let calculatedSize = (text as NSString).size(withAttributes: attributes)
        
        // Add generous padding
        let strokePadding = (strokeSize * scaleFactor) * 6
        let safetyBuffer = scaledTextSize * 0.5
        
        return calculatedSize.width + strokePadding + safetyBuffer
    }
    
    func convertViewToVideo(isShare: Bool, geoWidth: CGFloat, geoHeight: CGFloat) {
        isProcessing = true
        progress = 0.0
        
        // Extract GIF frames using the manager
        if selectedLiveBg != "None" {
            gifFrames = GIFFrameManager.instance.getFrames(for: selectedLiveBg)
            gifTotalDuration = GIFFrameManager.instance.getTotalDuration(for: selectedLiveBg)
            
            if gifTotalDuration == 0 {
                gifTotalDuration = 2.0 // Fallback
            }
            
            print("GIF '\(selectedLiveBg)': \(gifFrames.count) frames, duration: \(gifTotalDuration)s")
        }
        
        // Calculate video duration based on scrolling distance and speed
        calculateVideoDuration(geoWidth: geoWidth, geoHeight: geoHeight)
        
        // Create the video generator with correct duration
        let videoGenerator = VideoGenerator(
            frameRate: frameRate,
            duration: videoDuration,
            size: CGSize(width: geoWidth, height: geoHeight)
        ) { frameNumber in
            let progress = Double(frameNumber) / Double(Int(videoDuration * Double(frameRate)))
            return AnyView(self.createVideoFrame(progress: progress, videoWidth: geoWidth, videoHeight: geoHeight))
        }
        
        videoGenerator.generateVideo(progressHandler: { generationProgress in
            self.progress = generationProgress
        }) { result in
            self.isProcessing = false
            switch result {
            case .success(let url):
                self.videoURL = url
                self.progress = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isExporting = false
                    if isShare {
                        self.showShareSheet = true
                    } else {
                        self.saveVideoToPhotos(url)
                    }
                }
            case .failure(let error):
                self.isExporting = false
                self.progress = 0.0
                self.saveAlertMessage = "Failed to generate video: \(error.localizedDescription)"
                self.showSaveAlert = true
            }
        }
    }
    
    
    @ViewBuilder
    func getShapeImage() -> some View {
        switch selectedShape {
        case "circle":
            Image(.circle)
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        case "square":
            Image(.square)
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        case "heart":
            Image(.heart)
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        case "star":
            Image(.star)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        case "ninjaStar":
            Image(.ninjaStar)
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        default: // "None" or any other case
            Image(.circle)
                .resizable().scaledToFill()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
    }
    
    func getOffsetX() -> CGFloat {
        switch selectedAlignment {
        case "up", "down":
            return offsetx
        case "left", "right":
            return 420 // Center horizontally for left/right scrolling
        default:
            return offsetx
        }
    }

    func getOffsetY() -> CGFloat {
        switch selectedAlignment {
        case "left":
            return show ? 300 : -300
        case "right":
            return show ? -300 : 300
        case "up", "down":
            return 0 // Center vertically for up/down scrolling
        default:
            return 0
        }
    }

    func getRotation() -> Double {
        switch selectedAlignment {
        case "left":
            return -270
        case "right":
            return 90
        case "up":
            return -270
        case "down":
            return -270
        default: // "None" - use mirror logic
            return isMirror ? 90 : -270
        }
    }
    @ViewBuilder
    private func createVideoFrame(progress: Double, videoWidth: CGFloat, videoHeight: CGFloat) -> some View {
        let referenceDimension = max(videoWidth, videoHeight)
        let scaleFactor = referenceDimension / 844.0
        
        let scaledTextSize = textSize * 50 * scaleFactor
        let scaledStrokeSize = strokeSize * scaleFactor
        
        ZStack {
            // FIXED: Show EITHER background image OR GIF, not both
            if selectedLiveBg != "None" && !gifFrames.isEmpty {
                // Live background (GIF) - Full screen size with iPad-specific handling
                let currentTime = progress * videoDuration
                let gifProgress = (currentTime / gifTotalDuration).truncatingRemainder(dividingBy: 1.0)
                let frameIndex = Int(gifProgress * Double(gifFrames.count))
                let safeFrameIndex = min(max(frameIndex, 0), gifFrames.count - 1)
                
                if isIPad {
                    // iPad: Use proper rotation and sizing
                    Image(uiImage: gifFrames[safeFrameIndex])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: videoHeight,  // Swap dimensions before rotation
                            height: videoWidth
                        )
                        .rotationEffect(.degrees(90))
                        .frame(width: videoWidth, height: videoHeight)  // Final frame size
                        .clipped()
                        .if(!isHD) { view in
                            view.mask {
                                getShapeImageForVideo()
                                    .frame(width: videoWidth, height: videoHeight)
                            }
                        }
                } else {
                    // iPhone: Keep original logic
                    Image(uiImage: gifFrames[safeFrameIndex])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .rotationEffect(.degrees(90))
                        .frame(
                            width: videoHeight,
                            height: videoWidth
                        )
                        .position(x: videoWidth / 2, y: videoHeight / 2)
                        .clipped()
                        .if(!isHD) { view in
                            view.mask {
                                getShapeImageForVideo()
                                    .frame(width: videoWidth, height: videoHeight)
                            }
                        }
                }
            } else if backgroundResultImage != "" {
                // Background result image (only if no GIF)
                Image(backgroundResultImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: videoWidth, height: videoHeight)
                    .clipped()
                    .if(!isHD) { view in
                        view.mask {
                            getShapeImageForVideo()
                                .frame(width: videoWidth, height: videoHeight)
                        }
                    }
            }
            
            // Background shape (if not HD)
            if !isHD {
                getShapeImageForVideo()
                    .frame(width: videoWidth, height: videoHeight)
                    .clipped()
                    .opacity(0.1)
            }
            
            let animatedOffsetX = calculateAnimatedOffsetX(progress: progress, geoWidth: videoWidth, geoHeight: videoHeight, scaleFactor: scaleFactor)
            let animatedOffsetY = calculateAnimatedOffsetY(progress: progress, geoWidth: videoWidth, geoHeight: videoHeight, scaleFactor: scaleFactor)
            
            let isCurrentlyFlashing = isFlash && (Int(progress * videoDuration * 2) % 2 == 0)
            
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
        .overlay {
            Image(frameResultBg)
                .resizable()
                .frame(width: videoWidth, height: videoHeight)
                .if(!isHD) { view in
                    view.mask {
                        getShapeImageForVideo()
                            .frame(width: videoWidth, height: videoHeight)
                    }
                }
        }
        .frame(width: videoWidth, height: videoHeight)
        .background(backgroundEnabled ? selectedBgColor.color : Color.secondaryApp)
    }
//
//    @ViewBuilder
//    private func createVideoFrame(progress: Double, videoWidth: CGFloat, videoHeight: CGFloat) -> some View {
//        let referenceDimension = max(videoWidth, videoHeight)
//        let scaleFactor = referenceDimension / 844.0
//        
//        let scaledTextSize = textSize * 50 * scaleFactor
//        let scaledStrokeSize = strokeSize * scaleFactor
//        
//        ZStack {
//            // FIXED: Show EITHER background image OR GIF, not both
//            if selectedLiveBg != "None" && !gifFrames.isEmpty {
//                // Live background (GIF) - Full screen size
//                let currentTime = progress * videoDuration
//                let gifProgress = (currentTime / gifTotalDuration).truncatingRemainder(dividingBy: 1.0)
//                let frameIndex = Int(gifProgress * Double(gifFrames.count))
//                let safeFrameIndex = min(max(frameIndex, 0), gifFrames.count - 1)
//                
//                Image(uiImage: gifFrames[safeFrameIndex])
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .rotationEffect(.degrees(90))
//                    .frame(
//                        width: videoHeight,
//                        height: videoWidth
//                    )
//                    .position(x: videoWidth / 2, y: videoHeight / 2)
//                    .clipped()
//                    .if(!isHD) { view in
//                        view.mask {
//                            getShapeImageForVideo()
//                                .frame(width: videoWidth, height: videoHeight)
//                        }
//                    }
//            } else if backgroundResultImage != "" {
//                // Background result image (only if no GIF)
//                Image(backgroundResultImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: videoWidth, height: videoHeight)
//                    .clipped()
//                    .if(!isHD) { view in
//                        view.mask {
//                            getShapeImageForVideo()
//                                .frame(width: videoWidth, height: videoHeight)
//                        }
//                    }
//            }
//            
//            // Background shape (if not HD)
//            if !isHD {
//                getShapeImageForVideo()
//                    .frame(width: videoWidth, height: videoHeight)
//                    .clipped()
//                    .opacity(0.1)
//            }
//            
//            let animatedOffsetX = calculateAnimatedOffsetX(progress: progress, geoWidth: videoWidth, geoHeight: videoHeight, scaleFactor: scaleFactor)
//            let animatedOffsetY = calculateAnimatedOffsetY(progress: progress, geoWidth: videoWidth, geoHeight: videoHeight, scaleFactor: scaleFactor)
//            
//            let isCurrentlyFlashing = isFlash && (Int(progress * videoDuration * 2) % 2 == 0)
//            
//            ZStack {
//                // Layer 1: Blurred glow
//                if strokeSize > 0 {
//                    StrokeText(
//                        text: text,
//                        width: scaledStrokeSize,
//                        color: outlineEnabled ? selectedOutlineColor.color : .white,
//                        font: .custom(selectedFont, size: scaledTextSize),
//                        fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
//                    )
//                    .modifier(ColorModifier(colorOption: selectedColor))
//                    .blur(radius: isLight ? (40 * scaleFactor) : 0)
//                    .opacity(isLight ? 0.5 : 1)
//                } else {
//                    Text(text)
//                        .font(.custom(selectedFont, size: scaledTextSize))
//                        .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
//                        .modifier(ColorModifier(colorOption: selectedColor))
//                        .blur(radius: isLight ? (40 * scaleFactor) : 0)
//                        .opacity(isLight ? 0.5 : 1)
//                }
//                
//                // Layer 2: Middle glow
//                if isLight {
//                    if strokeSize > 0 {
//                        StrokeText(
//                            text: text,
//                            width: scaledStrokeSize,
//                            color: outlineEnabled ? selectedOutlineColor.color : .white,
//                            font: .custom(selectedFont, size: scaledTextSize),
//                            fontWeight: isBold ? .heavy : (isLight ? .light : .regular)
//                        )
//                        .kerning(0.6 * scaleFactor)
//                        .modifier(ColorModifier(colorOption: selectedColor))
//                        .blur(radius: 20 * scaleFactor)
//                        .opacity(0.7)
//                    } else {
//                        Text(text)
//                            .font(.custom(selectedFont, size: scaledTextSize))
//                            .kerning(0.4 * scaleFactor)
//                            .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
//                            .modifier(ColorModifier(colorOption: selectedColor))
//                            .blur(radius: 20 * scaleFactor)
//                            .opacity(0.7)
//                    }
//                }
//                
//                // Layer 3: Sharp text
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
//        .overlay {
//            Image(frameResultBg)
//                .resizable()
//                .frame(width: videoWidth, height: videoHeight)
//                .if(!isHD) { view in
//                    view.mask {
//                        getShapeImageForVideo()
//                            .frame(width: videoWidth, height: videoHeight)
//                    }
//                }
//        }
//        .frame(width: videoWidth, height: videoHeight)
//        .background(backgroundEnabled ? selectedBgColor.color : Color.secondaryApp)
//    }
    
    private func calculateAnimatedOffsetX(progress: Double, geoWidth: CGFloat, geoHeight: CGFloat, scaleFactor: CGFloat) -> CGFloat {
        let actualTextWidth = calculateActualTextWidth(scaleFactor: scaleFactor)
        let scaledTextSize = textSize * 50 * scaleFactor
        let extraBuffer = scaledTextSize * 3  // Extra buffer proportional to text size
        
        switch selectedAlignment {
        case "up":
            // Text moves from bottom to top (rotated -270°)
            let startPos = geoHeight + actualTextWidth / 2
            let endPos = -(actualTextWidth / 2) - extraBuffer
            return startPos + (endPos - startPos) * progress
            
        case "down":
            // Text moves from top to bottom (rotated -270°)
            let startPos = -(geoHeight + actualTextWidth / 2)
            let endPos = (geoHeight + actualTextWidth / 2) + extraBuffer
            return startPos + (endPos - startPos) * progress
            
        case "left", "right":
            // Center horizontally for vertical scrolling
            return geoWidth / 2 - 200
            
        default: // Horizontal scrolling (None or default)
            let startPos: CGFloat = isMirror ? (-(actualTextWidth / 2) - extraBuffer) : (geoWidth + actualTextWidth / 2)
            let endPos: CGFloat = isMirror ? (geoWidth + actualTextWidth / 2) : (-(actualTextWidth / 2) - extraBuffer)
            return startPos + (endPos - startPos) * progress
        }
    }

    private func calculateAnimatedOffsetY(progress: Double, geoWidth: CGFloat, geoHeight: CGFloat, scaleFactor: CGFloat) -> CGFloat {
        let actualTextWidth = calculateActualTextWidth(scaleFactor: scaleFactor)
        let scaledTextSize = textSize * 50 * scaleFactor
        let extraBuffer = scaledTextSize * 3  // Extra buffer proportional to text size
        
        switch selectedAlignment {
        case "left":
            // Text moves from right to left (rotated -270°)
            let startPos = -(geoWidth + actualTextWidth / 2)
            let endPos = (geoWidth + actualTextWidth / 2) + extraBuffer
            return startPos + (endPos - startPos) * progress
          
            
        case "right":
            // Text moves from left to right (rotated 90°)
            let startPos = geoWidth + actualTextWidth / 2
            let endPos = -(actualTextWidth / 2) - extraBuffer
            return startPos + (endPos - startPos) * progress
            
        case "up", "down":
            // Center vertically for horizontal scrolling
            return 0
            
        default: // Horizontal scrolling
            return 0
        }
    }

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
}
