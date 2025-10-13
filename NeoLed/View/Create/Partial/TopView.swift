//
//  TopView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 26/09/25.
//

import Foundation
import SwiftUI


struct TopView:View {
    @EnvironmentObject var userDefault: UserSettings
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    @Binding var backgroundImage: String
    @Binding var text: String
    @Binding var selectedFont: String
    @Binding var textSize: CGFloat
    @Binding var strokeSize: CGFloat
    @Binding var selectedColor: ColorOption
    @Binding var selectedOutlineColor: OutlineColorOption
    @Binding var outlineEnabled: Bool
    @Binding var hasCustomTextColor: Bool
    @Binding var customTextColor: UIColor
    @Binding var selectedEffects: Set<String>  // Keep this
    @Binding var selectedAlignment: String
    @Binding var selectedShape: String
    @Binding var textSpeed: CGFloat
    @Binding var isHD: Bool
    @Binding var selectedBgColor: OutlineColorOption
    @Binding var backgroundEnabled: Bool
    @Binding var selectedLiveBg: String
    @Binding var frameBg: String
    private var isBold: Bool { selectedEffects.contains("Bold") }
    private var isLight: Bool { selectedEffects.contains("Glow") }
    private var isFlash: Bool { selectedEffects.contains("Blink") }
    private var isMirror: Bool { selectedEffects.contains("Mirror") }
    private var isItalic: Bool { selectedEffects.contains("Italic") }
    
    @FocusState.Binding var isInputFocused: Bool
    var showPreview: () -> Void
    var onSave: () -> Void
    var onDownload: () -> Void
    var onValueChange: (() -> Void)? = nil
    
    @State var offsetx: CGFloat = 0
    @State var offsety: CGFloat = 0
    @State var textWidth: CGFloat = 0
    @State var show = false
    @State private var flashTimer: Timer?
    @State private var isFlashing = false
    @State private var previewText = ""
    
    
    @State private var blinkPhase: Bool = false
    @State private var animationID = UUID() // Add this
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    @State var showPaywall = false

    
    var body: some View {
        
        VStack(spacing: ScaleUtility.scaledSpacing(30)) {
            
            ZStack {
                
               RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height:  isIPad ? ScaleUtility.scaledValue(247) : ScaleUtility.scaledValue(167))
                    .background {
            
                            if backgroundEnabled {
                                selectedBgColor.color
                            }
                            else {
                                Color.secondaryApp
                            }
                        
                    }
                    .cornerRadius(10)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                    .overlay {
                        if text == "" {
                            Text("Enter Your Text")
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(36)))
                                .foregroundColor(Color.primaryApp)
                                .padding(.horizontal,ScaleUtility.scaledSpacing(36))
                        }
                    }
          
                
                GeometryReader { geo in
                    
                    ZStack {
                        
                        if backgroundImage != "" {
                            Image(backgroundImage)
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(10)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .if(!isHD) { view in
                                    view.mask {
                                        getShapeImage()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                    }
                                }
                        }
                        
                        if selectedLiveBg != "None" {
                            GifuGIFView(name: selectedLiveBg)
                                .frame(
                                    width: UIScreen.main.bounds.height,  // Use screen bounds instead of geo
                                    height: UIScreen.main.bounds.width
                                )
                                .position(x: geo.size.width / 2, y: geo.size.height / 2)  // Center it
                                .cornerRadius(10)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .if(!isHD) { view in
                                    view.mask {
                                        getShapeImage()
                                            .cornerRadius(10)
                                            .clipped()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                    }
                                }
                        }
                        
//                
//                        if selectedLiveBg != "None" {
//                            // Display GIF based on selectedLiveBg value
//                          GifuGIFView(name: selectedLiveBg)
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: ScaleUtility.scaledValue(335) ,height: ScaleUtility.scaledValue(167))
//                                .cornerRadius(10)
//                                .clipped()
//             
//                        }
                     
                        if !isHD {
                            getShapeImage()
                                .cornerRadius(10)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: geo.size.width, height: geo.size.height)
                                .opacity(0.1)
                        }
       
                    }
                        
                    ZStack {
                        // Blurred glow layers behind
                        if strokeSize > 0.2 {
                            Text(previewText)
                                .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic), size: textSize * 30))
                                // Remove .fontWeight() and .italic() modifiers completely
                                .modifier(ColorModifier(colorOption: selectedColor))
                                .stroke(
                                    color: outlineEnabled ? selectedOutlineColor.color : .white,
                                    width: strokeSize
                                )
                                .blur(radius: isLight ? 40 : 0)
                                .opacity(isLight ? 0.5 : 1)
                        } else {
                            Text(previewText)
                                .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic), size: textSize * 30))
                                .modifier(ColorModifier(colorOption: selectedColor))
                                .blur(radius: isLight ? 40 : 0)
                                .opacity(isLight ? 0.5 : 1)
                        }
                        
                        if isLight {
                            if strokeSize > 0.2 {
                                Text(previewText)
                                    .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic), size: textSize * 30))
                                    .kerning(0.6)
                                    .modifier(ColorModifier(colorOption: selectedColor))
                                    .stroke(
                                        color: outlineEnabled ? selectedOutlineColor.color : .white,
                                        width: strokeSize
                                    )
                                    .blur(radius: 20)
                                    .opacity(0.7)
                            } else {
                                Text(previewText)
                                    .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic), size: textSize * 30))
                                    .kerning(0.4)
                                    .modifier(ColorModifier(colorOption: selectedColor))
                                    .blur(radius: 20)
                                    .opacity(0.7)
                            }
                        }
                        
                        if previewText != "" {
                            // Sharp text on top
                            if strokeSize > 0.2 {
                                Text(previewText)
                                    .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic), size: textSize * 30))
                                    .modifier(ColorModifier(
                                        colorOption: (isFlash && blinkPhase) ? blinkFillColorOption : selectedColor
                                    ))
                                    .brightness(isFlash && blinkPhase ? 0.15 : 0)
                                    .stroke(
                                        color: outlineEnabled ? selectedOutlineColor.color : .white,
                                        width: strokeSize
                                    )
                
                              
                            } else {
                                Text(previewText)
                                    .font(.custom(FontManager.getFontWithEffects(baseFontName: selectedFont, isBold: isBold, isItalic: isItalic), size: textSize * 30))
                                    .modifier(ColorModifier(
                                        colorOption: (isFlash && blinkPhase) ? blinkFillColorOption : selectedColor
                                    ))
                                    .brightness(isFlash && blinkPhase ? 0.15 : 0)

                         
                                   
                            }
                        }
                    }
                    .scaleEffect(x: isMirror ? -1 : 1, y: 1)
                    .frame(height: 50)
                    .fixedSize()
                    .background { GeometryReader { textgeometry -> Color in
                        DispatchQueue.main.async {
                            self.textWidth = textgeometry.size.width
                        }
                        return Color.clear
                     }
                    }
                    .offset(x: getPreviewOffsetX(geo: geo), y: getPreviewOffsetY())
                    .rotationEffect(.degrees(getRotation()))
                    .position(x: geo.size.width / 2)
                    .if(!isHD) { view in
                        view.mask {
                            getShapeImage()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                    .onChange(of: selectedAlignment) { _, _ in
                        DispatchQueue.main.async {
                            offsetx = 0
                            offsety = 0
                            restartAnimation(geo: geo)
                        }
                    }
                    .onChange(of: selectedShape) { _, _ in
                        offsetx = 0
                        offsety = 0
                        restartAnimation(geo: geo)
                    }
                    .onChange(of: isHD) { _, _ in
                        offsetx = 0
                        offsety = 0
                        restartAnimation(geo: geo)
                    }
                    .onChange(of: strokeSize) { _, _ in
                        offsetx = 0
                        offsety = 0
                        restartAnimation(geo: geo)
                    }
                    .onChange(of: textSpeed) { _, _ in
                        offsetx = 0
                        offsety = 0
                        restartAnimation(geo: geo)
                    }
                    .onChange(of: isFlash) {_, _ in
                        offsetx = 0
                        offsety = 0
                        restartAnimation(geo: geo)
                    }
                    .onAppear() {
                        offsetx = 0
                        offsety = 0
                        restartAnimation(geo: geo)
//                        startContinuousAnimation(geo: geo)
               
                    }
                    .onChange(of: textWidth) { oldValue, newValue in
                        // Only update endpoint if width changed significantly
                        if abs(oldValue - newValue) > 1 {
                            startContinuousAnimation(geo: geo)
                        }
                    }
                    .onDisappear {
                        flashTimer?.invalidate()
                        flashTimer = nil
                    }
                    .overlay {
                   
                            if frameBg != "None" {
                                Image(frameBg)
                                    .resizable()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .if(!isHD) { view in
                                        view.mask {
                                            getShapeImage()
                                                .cornerRadius(10)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .frame(width: geo.size.width, height: geo.size.height)
                                        }
                                    }
                                
                            }
                        
                    }
      
                }
                .frame(maxWidth: .infinity)
                .frame(height: isIPad ? ScaleUtility.scaledValue(247) : ScaleUtility.scaledValue(167))
                .clipped()
                .padding(.horizontal, ScaleUtility.scaledSpacing(20))
            }

            
            VStack(spacing: ScaleUtility.scaledSpacing(10)) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            EllipticalGradient(
                                stops: [
                                    Gradient.Stop(color: .white.opacity(0.1), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.07, green: 0.07, blue: 0.08).opacity(0.1), location: 0.78),
                                ],
                                center: UnitPoint(x: 0.36, y: 0.34)
                            )
                        )
                        .frame(height:ScaleUtility.scaledValue(37) * heightRatio)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.primaryApp.opacity(0.15), lineWidth: 1)
                                .foregroundColor(Color.clear)
                                .frame(height:ScaleUtility.scaledValue(37) * heightRatio)
                        }
                    
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            Text("Enter Your Text")
                                .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(14)))
                                .foregroundColor(Color.primaryApp)
                                .background(Color.clear)
                            
                        }
                        
                        TextField("", text: $text)
                            .focused($isInputFocused)
                            .foregroundColor(Color.primaryApp)
                            .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(14)))
                            .padding(.vertical, ScaleUtility.scaledSpacing(10))
                            .textFieldStyle(PlainTextFieldStyle()) // <- Most important
                            .padding(.trailing,ScaleUtility.scaledSpacing(18))
                    }
                    .offset(x: ScaleUtility.scaledSpacing(15))
                    
                }
                .padding(.horizontal,ScaleUtility.scaledSpacing(20))
                
                
              HStack(spacing: ScaleUtility.scaledSpacing(11)) {
                    
                    Button {
                        impactFeedback.impactOccurred()
                        if userDefault.designCreated >= remoteConfigManager.totalFreeLED && !purchaseManager.hasPro {
                            showPaywall = true
                        }
                        else {
                            onSave()
                            userDefault.designCreated += 1
                        }
                    } label: {
                        Text("Save")
                          .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(14)))
                          .kerning(0.42)
                          .multilineTextAlignment(.center)
                          .foregroundColor(Color.secondaryApp)
                          .padding(.vertical, isIPad ? ScaleUtility.scaledSpacing(11) : ScaleUtility.scaledSpacing(9))
                          .padding(.horizontal, ScaleUtility.scaledSpacing(39.5))
                          .background(Color.accent)
                          .cornerRadius(5)
                    }
                    .disabled(text == "")
                    
                    Button {
                        impactFeedback.impactOccurred()
                        userDefault.designDownloaded += 1
                        if userDefault.designDownloaded > remoteConfigManager.totalFreeDownload && !purchaseManager.hasPro {
                            showPaywall = true
                        }
                        else {
                            onDownload()
                        }
                    } label: {
                        Image(.downloadIcon1)
                            .resizable()
                            .frame(width: isIPad ?  ScaleUtility.scaledValue(45) :  ScaleUtility.scaledValue(35),
                                   height: isIPad ?  ScaleUtility.scaledValue(45) :  ScaleUtility.scaledValue(35))
                          
                    }
                    .disabled(text == "")
                    
                    Spacer()
                    
                    
                    Button {
                        impactFeedback.impactOccurred()
                        showPreview()
                    } label: {
                        Text("Preview")
                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(14)))
                            .kerning(0.42)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.vertical, ScaleUtility.scaledSpacing(9))
                            .padding(.horizontal, ScaleUtility.scaledSpacing(18))
                            .background(
                                EllipticalGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                        Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                                    ],
                                    center: UnitPoint(x: 0.36, y: 0.34)
                                )
                            )
                            .cornerRadius(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.accent, lineWidth: 1)
                            }
                    }

                }
                .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                
            }
     
            
        }
        .padding(.top, ScaleUtility.scaledSpacing(59))
        .onChange(of: text) {
            previewText = text
            onValueChange?()
        }
        .onAppear {
            previewText = text
        }
        .fullScreenCover(isPresented: $showPaywall) {
            
            PaywallView(isInternalOpen: true) {
                showPaywall = false
            } purchaseCompletSuccessfullyAction: {
                showPaywall = false
            }
        }
    }
    
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



    private func restartAnimation(geo: GeometryProxy) {
        // Cancel any existing animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.linear(duration: 0)) {
                switch selectedAlignment {
                case "left", "None":
                    offsetx = isIPad ? geo.size.width / 2 + textWidth / 2 :  geo.size.height + textWidth / 2
                case "up":
                    offsety = isIPad ?  geo.size.height / 2 + textWidth / 2 : geo.size.height + textWidth / 2
                case "down":
                    offsety = isIPad ? -(geo.size.height / 2 + textWidth / 2) : -(geo.size.height + textWidth / 2)
                case "right":
                    offsetx = isIPad ? -(geo.size.width / 2 + textWidth / 2) :  -(geo.size.height + textWidth / 2)
                default:
                    offsetx = isIPad ?  geo.size.width / 2 + textWidth / 2 : geo.size.height + textWidth / 2
                }
            }
        }
        
        // Start new animation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let animationDuration = 10.0 / textSpeed
            
            withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                switch selectedAlignment {
                case "left", "None":
                    offsetx = isIPad ? -(geo.size.width / 2 + textWidth / 2) :  -textWidth / 1.2
                case "up":
                    offsety = isIPad ? -(geo.size.height / 2 + textWidth / 2) :  -textWidth / 2
                case "down":
                    offsety = isIPad ? geo.size.height / 2 + textWidth / 2 :  geo.size.height + textWidth / 2
                case "right":
                    offsetx = isIPad ? geo.size.width / 2 + textWidth / 2 :  geo.size.height + textWidth / 2
                default:
                    offsetx = isIPad ?  -(geo.size.width / 2 + textWidth / 2) :  -textWidth / 2
                }
            }
        }
        
        // Invalidate existing flash timer
        flashTimer?.invalidate()
        flashTimer = nil
        
        // Flash effect - reset and restart
        if isFlash {
            flashTimer?.invalidate()
            flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    blinkPhase.toggle()
                }
            }
        } else {
            flashTimer?.invalidate()
            flashTimer = nil
            blinkPhase = false
        }

    }
    
    private func startContinuousAnimation(geo: GeometryProxy) {
        // Set initial position
        withAnimation(.linear(duration: 0)) {
            switch selectedAlignment {
            case "left", "None":
                offsetx = isIPad ? geo.size.width / 2 + textWidth / 2 :  geo.size.height + textWidth / 2
            case "up":
                offsety = isIPad ? geo.size.height / 2 + textWidth / 2 : geo.size.height + textWidth / 2
            case "down":
                offsety = isIPad ?  -(geo.size.height / 2 + textWidth / 2) :  -(geo.size.height + textWidth / 2)
            case "right":
                offsetx = isIPad ? -(geo.size.width / 2 + textWidth / 2)  :  -(geo.size.height + textWidth / 2)
            default:
                offsetx = isIPad ? geo.size.width / 2 + textWidth / 2 :  geo.size.height + textWidth / 2
            }
        }
        
        // Start animation with new endpoint
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let animationDuration = 10.0 / textSpeed
            
            withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                switch selectedAlignment {
                case "left", "None":
                    offsetx = isIPad ? -(geo.size.width / 2 + textWidth / 2) : -textWidth / 1.2
                case "up":
                    offsety = isIPad ? -(geo.size.height / 2 + textWidth / 2) :  -textWidth / 2
                case "down":
                    offsety = isIPad ? geo.size.height / 2 + textWidth / 2 :  geo.size.height + textWidth / 2
                case "right":
                    offsetx = isIPad ?  geo.size.width / 2 + textWidth / 2 : geo.size.height + textWidth / 2
                default:
                    offsetx = isIPad ? -(geo.size.width / 2 + textWidth / 2) :  -textWidth / 2
                }
            }
        }
    }
    
    private func getShadowColor() -> Color {
        switch selectedColor.type {
        case .solid(let color):
            return color
        case .linearGradient(let gradientData):
            // Use the first color from the gradient for glow
            return gradientData.stops.first?.color ?? .white
        }
    }
    
    
    @ViewBuilder
    private func getShapeImage() -> some View {
        switch selectedShape {
        case "circle":
            Image(.circle3)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height:  isIPad ? ScaleUtility.scaledValue(247) : ScaleUtility.scaledValue(167))
            
        case "square":
            Image(.square3)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height:  isIPad ? ScaleUtility.scaledValue(247) :  ScaleUtility.scaledValue(167))
             
        case "heart":
            Image(.heart3)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height:  isIPad ? ScaleUtility.scaledValue(247) : ScaleUtility.scaledValue(167))
               
        case "star":
            Image(.star3)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height:  isIPad ? ScaleUtility.scaledValue(247) : ScaleUtility.scaledValue(167))
               
        case "ninjaStar":
            Image(.ninjaStar3)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height:  isIPad ? ScaleUtility.scaledValue(247) : ScaleUtility.scaledValue(167))
            
        default: // "None" or any other case
            Image(.circle3)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height:  isIPad ? ScaleUtility.scaledValue(247) : ScaleUtility.scaledValue(167))
       
        }
    }
    private func getPreviewOffsetX(geo: GeometryProxy) -> CGFloat {
        switch selectedAlignment {
        case "up", "down":
            return ScaleUtility.scaledValue(5)
        case "left", "right":
            return offsetx // Centered for horizontal scroll
        default:
            return isMirror ? offsetx : offsetx
        }
    }

    private func getPreviewOffsetY() -> CGFloat {
        switch selectedAlignment {
        case "left", "right":
            return isIPad ? ScaleUtility.scaledValue(120) : ScaleUtility.scaledValue(80) // Position for horizontal scroll
        case "up", "down":
            return offsety // Use offsety for vertical movement
        default:
            return isIPad ? ScaleUtility.scaledValue(120) : ScaleUtility.scaledValue(80)
        }
    }
    
    private func getRotation() -> Double {
        switch selectedAlignment {
        case "left":
            return 0
        case "right":
            return 0
        case "up":
            return 0  // Rotate for vertical scroll
        case "down":
            return 0   // Rotate opposite direction
        default:
            return 0
        }
    }
    
    
//    
//    private func getOffsetX() -> CGFloat {
//        switch selectedAlignment {
//        case "up", "down":
//            return offsetx
//        case "left", "right":
//            return 420 // Center horizontally for left/right scrolling
//        default:
//            return isMirror ? (show ? 1160 : -500) : (show ? -500 : 1160)
//        }
//    }
//
//    private func getOffsetY() -> CGFloat {
//        switch selectedAlignment {
//        case "left":
//            return show ? 300 : -300
//        case "right":
//            return show ? -300 : 300
//        case "up", "down":
//            return 0 // Center vertically for up/down scrolling
//        default:
//            return 0
//        }
//    }

}
