//
//  EditEffectView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 29/09/25.
//


import Foundation
import SwiftUI


struct LEDShape {  // Changed from "Shape"
    let shapeName: String
    let shapeIcon: String
}

struct LiveWallpaper {
    let wallpaperName: String
    let wallpaperImage: String
}

struct FrameBackground {
    let frameName: String
    let frameImage: String
    let framResult: String
}

struct EditBackgroundView: View {
    
    @Binding var isHD: Bool
    @Binding var selectedShape: String
    @Binding var selectedBgColor: OutlineColorOption
    @Binding var backgroundEnabled: Bool
    
    var shapeOption: [LEDShape] = [
        LEDShape(shapeName: "None", shapeIcon: "noSelectionIcon"),
        LEDShape(shapeName: "circle", shapeIcon: "circleIcon"),
        LEDShape(shapeName: "square", shapeIcon: "squareIcon"),
        LEDShape(shapeName: "heart", shapeIcon: "heartIcon2"),
        LEDShape(shapeName: "star", shapeIcon: "starIcon"),
        LEDShape(shapeName: "ninjaStar", shapeIcon: "ninjaStarIcon"),
    ]
    
    @Binding var selectedLiveBg: String
    
    var wallpaperOption: [LiveWallpaper] = [
        LiveWallpaper(wallpaperName: "None", wallpaperImage: "noSelectionIcon"),
        LiveWallpaper(wallpaperName: "gif1", wallpaperImage: "live1"),
        LiveWallpaper(wallpaperName: "gif2", wallpaperImage: "live2"),
        LiveWallpaper(wallpaperName: "gif3", wallpaperImage: "live3"),
        LiveWallpaper(wallpaperName: "gif4", wallpaperImage: "live4"),
        LiveWallpaper(wallpaperName: "gif5", wallpaperImage: "live5"),
        LiveWallpaper(wallpaperName: "gif6", wallpaperImage: "live6"),
        LiveWallpaper(wallpaperName: "gif7", wallpaperImage: "live7"),
        LiveWallpaper(wallpaperName: "gif8", wallpaperImage: "live8"),
        LiveWallpaper(wallpaperName: "gif9", wallpaperImage: "live9"),
        LiveWallpaper(wallpaperName: "gif10", wallpaperImage: "live10"),
    ]
    
    @Binding var frameBg: String
    @Binding var frameResultBg: String
    
    var frameOption: [FrameBackground] = [
        FrameBackground(frameName: "None", frameImage: "noSelectionIcon",framResult: "None"),
        FrameBackground(frameName: "frame1", frameImage: "f1",framResult: "fr1"),
        FrameBackground(frameName: "frame2", frameImage: "f2",framResult: "fr2"),
        FrameBackground(frameName: "frame3", frameImage: "f3",framResult: "fr3"),
        FrameBackground(frameName: "frame4", frameImage: "f4",framResult: "fr4"),
        FrameBackground(frameName: "frame5", frameImage: "f5",framResult: "fr5"),
        FrameBackground(frameName: "frame6", frameImage: "f6",framResult: "fr6"),
        FrameBackground(frameName: "frame7", frameImage: "f7",framResult: "fr7"),
        FrameBackground(frameName: "frame8", frameImage: "f8",framResult: "fr8"),
        FrameBackground(frameName: "frame9", frameImage: "f9",framResult: "fr9"),
        FrameBackground(frameName: "frame10", frameImage: "f10",framResult: "fr10"),
    ]
    
    
    @State private var showBgColorPicker = false
    @State private var customBgColor: UIColor = .blue
    @State private var hasCustomBgColor = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        OutlineColorPickerView(
                            text: "Background Color",
                            selectedOutlineColor: $selectedBgColor,
                            showColorPicker: $showBgColorPicker,
                            hasCustomColor: $hasCustomBgColor,
                            customColor: $customBgColor,
                            outlineEnabled: $backgroundEnabled,
                            selectedLiveBg: $selectedLiveBg,
                            isBackground: true,
                            selectedBgColor: $selectedBgColor
                        )
                        .padding(.horizontal, ScaleUtility.scaledSpacing(30))
                    }
                
                VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                    Text("Live Background")
                        .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.5942)))
                        .kerning(0.40783)
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.leading, ScaleUtility.scaledSpacing(30))
               
                    ScrollView(.horizontal) {
                        HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                            ForEach(Array(wallpaperOption.enumerated()), id: \.offset) { index, wallpaper in
                                
                                Button {
                                    selectedLiveBg = wallpaper.wallpaperName
                                    backgroundEnabled = false
                                } label: {
                                    
                                    Image(wallpaper.wallpaperImage)
                                        .resizable()
                                        .frame(width: wallpaper.wallpaperName == "None" ? ScaleUtility.scaledValue(16) : ScaleUtility.scaledValue(42),
                                               height: wallpaper.wallpaperName == "None" ? ScaleUtility.scaledValue(16) :  ScaleUtility.scaledValue(42))
                                        .padding(.all,wallpaper.wallpaperName == "None" ? ScaleUtility.scaledSpacing(13) : 0 )
                                        .background {
                                            if selectedLiveBg == wallpaper.wallpaperName {
                                                EllipticalGradient(
                                                    stops: [
                                                        Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                                        Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                                                    ],
                                                    center: UnitPoint(x: 0.36, y: 0.34)
                                                )
                                            }
                                            else {
                                                Color.clear
                                            }
                                        }
                                        .cornerRadius(5)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke( selectedLiveBg == wallpaper.wallpaperName ? Color.accent : Color.clear, lineWidth: 1)
                                               
                                            
                                            
                                        }
                                }
                                .frame(width: ScaleUtility.scaledValue(44), height: ScaleUtility.scaledValue(44))
                            }
                            
                        }
                        .frame(alignment: .leading)
                        .padding(.horizontal, ScaleUtility.scaledSpacing(30))
                    }
                }
           
                VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                    Text("Frame Background")
                        .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.5942)))
                        .kerning(0.40783)
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.leading, ScaleUtility.scaledSpacing(30))
               
                    ScrollView(.horizontal) {
                        HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                            ForEach(Array(frameOption.enumerated()), id: \.offset) { index, frame in
                                
                                Button {
                                    frameBg = frame.frameName
                                    frameResultBg = frame.framResult
                                } label: {
                                    
                                    Image(frame.frameImage)
                                        .resizable()
                                        .frame(width: frame.frameName == "None" ? ScaleUtility.scaledValue(16) : ScaleUtility.scaledValue(42),
                                               height: frame.frameName == "None" ? ScaleUtility.scaledValue(16) :  ScaleUtility.scaledValue(42))
                                        .padding(.all,frame.frameName == "None" ? ScaleUtility.scaledSpacing(13) : 0 )
                                        .background {
                                            if frameBg == frame.frameName {
                                                EllipticalGradient(
                                                    stops: [
                                                        Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                                        Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                                                    ],
                                                    center: UnitPoint(x: 0.36, y: 0.34)
                                                )
                                            }
                                            else {
                                                Color.clear
                                            }
                                        }
                                        .cornerRadius(5)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(frameBg == frame.frameName ? Color.accent : Color.clear, lineWidth: 1)
                                            
                                        }
                                }
                                .frame(width: ScaleUtility.scaledValue(44), height: ScaleUtility.scaledValue(44))
                            }
                            
                        }
                        .frame(alignment: .leading)
                        .padding(.horizontal, ScaleUtility.scaledSpacing(30))
                    }
                }
                
                VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                    Text("Banner Type")
                       .font(FontManager.bricolageGrotesqueMediumFont(size: 13.5942))
                      .kerning(0.40783)
                      .foregroundColor(Color.primaryApp.opacity(0.5))
                      .frame(maxWidth: .infinity, alignment: .topLeading)
                      .padding(.horizontal, ScaleUtility.scaledSpacing(30))
                    
                    HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                        
                        Button {
                            isHD = false
                        } label: {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: ScaleUtility.scaledValue(102), height: ScaleUtility.scaledValue(34))
                                .foregroundColor(Color.clear)
                                .background {
                                    if !isHD {
                                        EllipticalGradient(
                                         stops: [
                                             Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                             Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                                         ],
                                         center: UnitPoint(x: 0.36, y: 0.34)
                                        )
                                    }
                                    else {
                                        
                                        Color(red: 0.26, green: 0.25, blue: 0.25).opacity(0.5)
                                    }
                                }
                                .cornerRadius(5)
                                .overlay {
                                    Text("LED")
                                        .font(FontManager.bricolageGrotesqueRegularFont(size: 14))
                                        .kerning(0.42)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(!isHD  ? Color.accent : Color.clear, lineWidth: 1)
                                }
                        }

                        
                        Button {
                            isHD = true
                        } label: {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: ScaleUtility.scaledValue(102), height: ScaleUtility.scaledValue(34))
                                .foregroundColor(Color.clear)
                                .background {
                                    if isHD {
                                        EllipticalGradient(
                                         stops: [
                                             Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                             Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                                         ],
                                         center: UnitPoint(x: 0.36, y: 0.34)
                                        )
                                    }
                                    else {
                                        
                                        Color(red: 0.26, green: 0.25, blue: 0.25).opacity(0.5)
                                    }
                                }
                                .cornerRadius(5)
                                .overlay {
                                    Text("HD")
                                        .font(FontManager.bricolageGrotesqueRegularFont(size: 14))
                                        .kerning(0.42)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(isHD  ? Color.accent : Color.clear, lineWidth: 1)
                                }
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal, ScaleUtility.scaledSpacing(30))
                }
                
                
                VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                    Text("LED Shape Type")
                        .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.5942)))
                        .kerning(0.40783)
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.leading, ScaleUtility.scaledSpacing(30))
               
                    ScrollView(.horizontal) {
                        HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                            ForEach(Array(shapeOption.enumerated()), id: \.offset) { index, shape in
                                
                                Button {
                                    selectedShape = shape.shapeName
                                } label: {
                                    
                                    Image(shape.shapeIcon)
                                        .resizable()
                                        .frame(width: ScaleUtility.scaledValue(16), height: ScaleUtility.scaledValue(16))
                                        .padding(.all, ScaleUtility.scaledSpacing(13))
                                        .background {
                                            if selectedShape == shape.shapeName {
                                                EllipticalGradient(
                                                    stops: [
                                                        Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                                        Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                                                    ],
                                                    center: UnitPoint(x: 0.36, y: 0.34)
                                                )
                                            }
                                            else {
                                                Color.appGrey
                                            }
                                        }
                                        .cornerRadius(5)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke( selectedShape == shape.shapeName ? Color.accent : Color.clear, lineWidth: 1)
                                            
                                        }
                                }
                                .frame(width: ScaleUtility.scaledValue(44), height: ScaleUtility.scaledValue(44))
                            }
                            
                        }
                        .frame(alignment: .leading)
                        .padding(.horizontal, ScaleUtility.scaledSpacing(30))
                    }
                }
           
            }
          
        }
        .sheet(isPresented: $showBgColorPicker) {
            ColorPickerSheet(
                uiColor: $customBgColor,
                isPresented: $showBgColorPicker,
                onColorApplied: { color in
                    customBgColor = color
                    selectedBgColor = OutlineColorOption(
                        id: "custom_outline",
                        name: "Custom",
                        color: Color(color)
                    )
                    hasCustomBgColor = true
                    backgroundEnabled = true
                    selectedLiveBg = "None"
                }
            )
            .presentationDetents(isIPad ? [.large, .fraction(0.95)] : [.fraction(0.9)])
        }
    }
}
