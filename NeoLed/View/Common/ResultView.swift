//
//  ResultView.swift
//  NeoLed
//

import SwiftUI

struct ResultView: View {
    
    @EnvironmentObject var userDefault: UserSettings
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    
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
    var isLight: Bool { selectedEffects.contains("Glow") }   // Glow → blur layer
    var isFlash: Bool { selectedEffects.contains("Blink") }  // Blink → color toggle
    var isMirror: Bool { selectedEffects.contains("Mirror") }
    var onBack: () -> Void
   
    @State private var flashTimer: Timer?
    @State private var isFlashing = false
    @State var isSavedToLibrary = false
    @State var offsetx: CGFloat = 0
    @State var offsety: CGFloat = 0
    @State var textWidth: CGFloat = 0
    @State var show = false
    
    @State var videoURL: URL? = nil
    @State var showShareSheet: Bool = false
    @State var showSaveAlert: Bool = false
    @State var saveAlertMessage: String = ""
    @State var isProcessing: Bool = false
    
    @State private var blinkPhase: Bool = false
    
    @State var progress: Double = 0.0
    @State var isExporting: Bool = false
    
    @State var showPaywall = false
    
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
       
                    // Proper glow — smooth outer light only, no rectangle artifacts
                    if isLight {
                        ZStack {
                            // Outer glow
                            Text(text)
                                .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                              size: .scaledFontSize(textSize * 50)))
                                .modifier(ColorModifier(colorOption: selectedColor))
                                .blur(radius: 20)
                                .opacity(0.6)

                            // Inner glow for depth
                            Text(text)
                                .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                              size: .scaledFontSize(textSize * 50)))
                                .modifier(ColorModifier(colorOption: selectedColor))
                                .blur(radius: 20)
                                .opacity(0.7)
                        }
                        // Mask ensures the glow follows letter shapes only (no rectangular blur)
                        .mask(
                            Text(text)
                                .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                              size: .scaledFontSize(textSize * 50)))
                        )
                    }

                    
 
                    // Blink + Glow layer (works even if Glow is off)
                    if isLight || isFlash {
                        
                        if strokeSize > 0 {
                            Text(text)
                                .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                              size: .scaledFontSize(textSize * 50)))
                                .modifier(ColorModifier(
                                    colorOption: (isFlash && blinkPhase) ? blinkFillColorOption : selectedColor
                                ))
                                .brightness(isFlash && blinkPhase ? 0.15 : 0)
                                .stroke(
                                    color: outlineEnabled ? selectedOutlineColor.color : .white,
                                    width: strokeSize
                                )
                                .blur(radius: isLight ? 20 : 0)
                                .opacity(isLight ? 0.6 : 1)
                                .kerning(0.6)
                        } else {
                            Text(text)
                                .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                              size: .scaledFontSize(textSize * 50)))
                                .modifier(ColorModifier(
                                    colorOption: (isFlash && blinkPhase) ? blinkFillColorOption : selectedColor
                                ))
                                .brightness(isFlash && blinkPhase ? 0.15 : 0)
                                .blur(radius: isLight ? 20 : 0)
                                .opacity(isLight ? 0.6 : 1)
                                .kerning(0.4)
                        }
                    }

                    
                    // Sharp text on top
                    if strokeSize > 0 {
                        Text(text)
                            .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                          size:  .scaledFontSize(textSize * 50)))
                            .modifier(ColorModifier(
                                colorOption: (isFlash && blinkPhase) ? blinkFillColorOption : selectedColor
                            ))
                            .brightness(isFlash && blinkPhase ? 0.15 : 0)
                            .stroke(
                                color: outlineEnabled ? selectedOutlineColor.color : .white,
                                width: strokeSize
                            )
                            .opacity(isFlash && blinkPhase ? 0.1 : 1.0)
                    } else {
                        Text(text)
                            .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic),
                                          size:  .scaledFontSize(textSize * 50)))
                            .modifier(ColorModifier(
                                colorOption: (isFlash && blinkPhase) ? blinkFillColorOption : selectedColor
                            ))
                            .brightness(isFlash && blinkPhase ? 0.15 : 0)
                            .opacity(isFlash && blinkPhase ? 0.1 : 1.0)
                    }
                }
                .scaleEffect(x: isMirror ? -1 : 1, y: 1)
                .frame(height: isIPad ? ScaleUtility.scaledValue(500) : ScaleUtility.scaledValue(300))
                .fixedSize()
                .padding(.all, strokeSize * 3)
                .clipped()
                .background { GeometryReader { textgeometry -> Color in
                    DispatchQueue.main.async {
                        self.textWidth = textgeometry.size.width
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
                        flashTimer?.invalidate()
                        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                blinkPhase.toggle()
                            }
                        }
                    } else {
                        flashTimer?.invalidate()
                        flashTimer = nil
                        blinkPhase = false
                    }
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
//                        .background {
//                            EllipticalGradient(
//                                stops: [
//                                    Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
//                                    Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
//                                ],
//                                center: UnitPoint(x: 0.36, y: 0.34)
//                            )
//                        }
//                        .cornerRadius(4.04762)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 4.04762)
//                                .stroke(Color.accent, lineWidth: 1)
//                        }
                }
                .padding(.leading,ScaleUtility.scaledSpacing(8))

        
                Spacer()
                
                HStack(spacing: ScaleUtility.scaledSpacing(14.57)) {
                    
                    // Share Video Button
                    Button {
                        AnalyticsManager.shared.log(.shared)
                        impactFeedback.impactOccurred()
                        if let url = videoURL {
                            showShareSheet = true
                        } else {
                            isExporting = true
                            convertViewToVideo(isShare: true)
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
                    Button {
                        AnalyticsManager.shared.log(.downloaded)
                        impactFeedback.impactOccurred()
                        
                  
                        if userDefault.designDownloaded > remoteConfigManager.totalFreeDownload && !purchaseManager.hasPro {
                            showPaywall = true
                        }
                        else {
                            if let url = videoURL {
                                saveVideoToPhotos(url)
                            } else {
                                isExporting = true
                                convertViewToVideo(isShare: false)
                                userDefault.designDownloaded += 1
                            }
                        }
                    } label: {
                        Image(.downloadIcon2)
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
//                    
//                    Button(action: {
//                        if !isSavedToLibrary {
//                            saveDesignToHistory()
//                        }
//                    }) {
//                        Image(isSavedToLibrary ? .savedIcon : .saveIcon)
//                            .resizable()
//                            .frame(width: isIPad ?  ScaleUtility.scaledValue(28.42857) : ScaleUtility.scaledValue(19.42857),
//                                   height: isIPad ?  ScaleUtility.scaledValue(28.42857) : ScaleUtility.scaledValue(19.42857))
//                       
//                    }
//                    .padding(.all, ScaleUtility.scaledSpacing(7.29))
//                    .background {
//                        EllipticalGradient(
//                            stops: [
//                                Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
//                                Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
//                            ],
//                            center: UnitPoint(x: 0.36, y: 0.34)
//                        )
//                    }
//                    .cornerRadius(4.04762)
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 4.04762)
//                            .stroke(Color.accent, lineWidth: 1)
//                    }
                
                }
                .sheet(isPresented: $showShareSheet) {
                    if let url = videoURL {
                        ShareSheet(items: [url], filename: "NeoLed Video")
                    }
                }
                .alert("Video Saved", isPresented: $showSaveAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(saveAlertMessage)
                }
                .tint(.blue)
            }
            .padding(.horizontal,ScaleUtility.scaledSpacing(20))
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
    
            if isFlash {
                flashTimer?.invalidate()
                flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        blinkPhase.toggle()
                    }
                }
            } else {
                flashTimer?.invalidate()
                flashTimer = nil
                blinkPhase = false
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            
            PaywallView(isInternalOpen: true) {
                showPaywall = false
            } purchaseCompletSuccessfullyAction: {
                showPaywall = false
            }
        }
    }
    
    
    // MARK: - Helper Functions
    
    
    private var blinkFillColorOption: ColorOption {
        if outlineEnabled {
            return ColorOption(id: "blink_outline",
                               name: "BlinkOutline",
                               type: .solid(selectedOutlineColor.color))
        } else {
            return ColorOption(id: "blink_default",
                               name: "BlinkDefault",
                               type: .solid(Color.appGiftBox)) // fallback if no outline
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
        isSavedToLibrary = true
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
    
    func convertViewToVideo(isShare: Bool) {
        isProcessing = true
        progress = 0.0
        
        // Uses screen dimensions automatically via helper
        VideoGenerationHelper.generateVideo(
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
            progressHandler: { generationProgress in
                self.progress = generationProgress
            },
            completion: { result in
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
        )
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
}
