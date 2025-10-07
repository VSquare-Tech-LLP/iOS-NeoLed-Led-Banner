//
//  ResultView.swift
//  NeoLed
//

import SwiftUI

struct ResultView: View {
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

    let selectedEffects: Set<String>  // Keep this
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
   
    @State  var isFlashing = false
    
    @State var offsetx: CGFloat = 0
    @State var offsety: CGFloat = 0
    @State var textWidth: CGFloat = 0
    @State var show = false
    
    
    
    @State  var videoURL: URL? = nil
    @State  var showShareSheet: Bool = false
    @State  var showSaveAlert: Bool = false
    @State  var saveAlertMessage: String = ""
    @State  var isProcessing: Bool = false
    
    @State  var videoDuration: Double = 5.0
    @State  var frameRate: Int = 30
    
    @State private var blinkPhase: Bool = false
    
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
                                width: UIScreen.main.bounds.height,  // Use screen bounds instead of geo
                                height: UIScreen.main.bounds.width
                            )
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)  // Center it
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
                            .font(.custom(selectedFont, size: textSize * 50))
                            .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
                            .italic(isItalic)
                            .modifier(ColorModifier(colorOption: selectedColor))
                            .stroke(
                                color: outlineEnabled ? selectedOutlineColor.color : .white,
                                width: strokeSize
                            )
                            .blur(radius: isLight ? 40 : 0)
                            .opacity(isLight ? 0.5 : 1)
                    } else {
                        Text(text)
                            .font(.custom(selectedFont, size: textSize * 50))
                            .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
                            .italic(isItalic)
                            .modifier(ColorModifier(colorOption: selectedColor))
                            .blur(radius: isLight ? 40 : 0)
                            .opacity(isLight ? 0.5 : 1)
                    }
                    
                    // Middle glow layer for Blink effect
                    if isLight {
                        if strokeSize > 0 {
                            Text(text)
                                .font(.custom(selectedFont, size: textSize * 50))
                                .fontWeight(isBold ? .heavy : .regular)
                                .italic(isItalic)
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
                                .font(.custom(selectedFont, size: textSize * 50))
                                .kerning(0.4)
                                .fontWeight(isBold ? .heavy : .regular)
                                .italic(isItalic)
                                .modifier(ColorModifier(colorOption: selectedColor))
                                .blur(radius: 20)
                                .opacity(0.7)
                        }
                    }
                    
                    // Sharp text on top
                    if strokeSize > 0 {
                        Text(text)
                            .font(.custom(selectedFont, size: textSize * 50))
                            .fontWeight(isBold ? .heavy : .regular)
                            .italic(isItalic)
                            .modifier(ColorModifier(colorOption: selectedColor))
                            .stroke(
                                color: outlineEnabled ? selectedOutlineColor.color : .white,
                                width: strokeSize
                            )
                            .brightness(0.1)
                            .opacity(isFlash && blinkPhase ? 0.1 : 1.0)
                    } else {
                        Text(text)
                            .font(.custom(selectedFont, size: textSize * 50))
                            .fontWeight(isBold ? .heavy : (isLight ? .light : .regular))
                            .italic(isItalic)
                            .modifier(ColorModifier(colorOption: selectedColor))
                            .brightness(0.1)
                            .opacity(isFlash && blinkPhase ? 0.1 : 1.0)
                    }
                }
                .scaleEffect(x: isMirror ? -1 : 1, y: 1) // Mirror effect
                .frame(height: 200)
                .fixedSize()
                .padding(.all, strokeSize * 3)  // Add padding to prevent clipping
                .clipped()  // ← Add this to hide overflow
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
                        withAnimation(
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            blinkPhase = true
                        }
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
                    onBack()
                } label: {
                    Image(.backIcon)
                        .resizable()
                        .frame(width: ScaleUtility.scaledValue(34), height: ScaleUtility.scaledValue(34))
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
                
                // Replace your existing HStack with share and download buttons with this:

                HStack(spacing: ScaleUtility.scaledSpacing(14.57)) {
                    
                    // Share Video Button
                    Button {
                        if let url = videoURL {
                            showShareSheet = true
                        } else {
                            convertViewToVideo()
                        }
                    } label: {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                                .frame(width: ScaleUtility.scaledValue(19.42857), height: ScaleUtility.scaledValue(19.42857))
                        } else {
                            Image(.shareIcon1)
                                .resizable()
                                .frame(width: ScaleUtility.scaledValue(19.42857), height: ScaleUtility.scaledValue(19.42857))
                        }
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
                        if let url = videoURL {
                            saveVideoToPhotos(url)
                        } else {
                            convertViewToVideo()
                        }
                    } label: {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                                .frame(width: ScaleUtility.scaledValue(19.42857), height: ScaleUtility.scaledValue(19.42857))
                        } else {
                            Image(.downloadIcon)
                                .resizable()
                                .frame(width: ScaleUtility.scaledValue(19.42857), height: ScaleUtility.scaledValue(19.42857))
                        }
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
                        ShareSheet(items: [url])
                    }
                }
                .alert("Video Status", isPresented: $showSaveAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(saveAlertMessage)
                }
            }
            .padding(.horizontal,ScaleUtility.scaledSpacing(28))
            .padding(.top,ScaleUtility.scaledSpacing(59))
            
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
            return isMirror ? (show ? 1160 : -500) : (show ? -500 : 1160)
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

  
