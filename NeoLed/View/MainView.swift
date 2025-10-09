//
//  MainView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 24/09/25.
//

import Foundation
import SwiftUI

enum TabSelection: Hashable {
    case explore
    case create
    case history
}


struct MainView: View {
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    @State var backgroundImage: String = ""
    @State var backgroundResultImage: String = ""
    @State private var selectedTab: TabSelection = .explore
    @State private var text: String = ""  // ADD THIS
    @State private var textSize: CGFloat = 4.0
    @State private var strokeSize: CGFloat = 0.0
    @State private var selectedFont: String = FontManager.bricolageGrotesqueRegularFont
    @State private var selectedColor: ColorOption = ColorOption.predefinedColors[1]
    @State private var selectedOutlineColor: OutlineColorOption = OutlineColorOption.predefinedOutlineColors[0]
    @State private var outlineEnabled = false
    @State private var backgroundEnabled = false
    @State private var hasCustomTextColor = false
    @State private var customTextColor: UIColor = .white
    @State private var selectedEffects: Set<String> = ["None"]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .explore:
                        ExploreView(
                            onTemplateSelect: { template in
                                // Load template data into state
                                loadTemplate(template)
                                // Switch to create tab
                                selectedTab = .create
                            }
                        )
                    case .create:
                        CreateView(
                            backgroundResultImage: $backgroundResultImage,
                            text: $text,
                            backgroundImage: $backgroundImage,
                            textSize: $textSize,
                            strokeSize: $strokeSize,
                            selectedFont: $selectedFont,
                            selectedColor: $selectedColor,
                            selectedOutlineColor: $selectedOutlineColor,
                            outlineEnabled: $outlineEnabled,
                            backgroundEnabled: $backgroundEnabled,
                            hasCustomTextColor: $hasCustomTextColor,
                            customTextColor: $customTextColor,
                            selectedEffects: $selectedEffects
                        )
                    case .history:
                        HistoryView()
                    }
                }
                .frame(maxWidth:.infinity)
                .transition(.opacity)
                
                
                VStack {
                    Spacer()
      
                    
                    HStack {
                        
                        Button {
                            impactFeedback.impactOccurred()
                            selectedTab = .explore
                            
                            backgroundImage = ""
                            backgroundResultImage = ""
                            text = ""
                            textSize = 4.0
                            strokeSize = 0.0
                            selectedFont = FontManager.bricolageGrotesqueRegularFont
                            selectedColor = ColorOption.predefinedColors[1]
                            selectedOutlineColor = OutlineColorOption.predefinedOutlineColors[0]
                            outlineEnabled  = false
                            backgroundEnabled = false
                            hasCustomTextColor = false
                            customTextColor = .white
                            selectedEffects = ["None"]
                        } label: {
                            VStack(spacing: ScaleUtility.scaledSpacing(4.88)) {
                                Image(.exploreIcon)
                                    .resizable()
                                    .frame(width: ScaleUtility.scaledValue(29.26829), height: ScaleUtility.scaledValue(29.26829))
                                
                                Text("Explore")
                                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.41463)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: ScaleUtility.scaledValue(85.36585))
                            }
                            .opacity(selectedTab != .explore ? 0.5 : 1)
                        }
                        
                        Spacer()
                        
                        Button {
                            impactFeedback.impactOccurred()
                            selectedTab = .create
                        } label: {
                            VStack(spacing: ScaleUtility.scaledSpacing(4.88)) {
                                Image(.createIcon)
                                    .resizable()
                                    .frame(width: ScaleUtility.scaledValue(29.26829), height: ScaleUtility.scaledValue(29.26829))
                                
                                Text("Create")
                                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.41463)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: ScaleUtility.scaledValue(85.36585))
                            }
                            .opacity(selectedTab != .create ? 0.5 : 1)
                        }
                        
                        Spacer()
                        
                        Button {
                            impactFeedback.impactOccurred()
                            selectedTab = .history
                            
                            backgroundImage = ""
                            backgroundResultImage = ""
                            text = ""
                            textSize = 4.0
                            strokeSize = 0.0
                            selectedFont = FontManager.bricolageGrotesqueRegularFont
                            selectedColor = ColorOption.predefinedColors[1]
                            selectedOutlineColor = OutlineColorOption.predefinedOutlineColors[0]
                            outlineEnabled  = false
                            backgroundEnabled = false
                            hasCustomTextColor = false
                            customTextColor = .white
                            selectedEffects = ["None"]
                        } label: {
                            VStack(spacing: ScaleUtility.scaledSpacing(4.88)) {
                                Image(.historyIcon)
                                    .resizable()
                                    .frame(width: ScaleUtility.scaledValue(29.26829), height: ScaleUtility.scaledValue(29.26829))
                                
                                Text("History")
                                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.41463)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: ScaleUtility.scaledValue(84))
                            }
                            .opacity(selectedTab != .history ? 0.5 : 1)
                        }
                    }
                    .padding(.horizontal, isIPad ? ScaleUtility.scaledSpacing(84) : ScaleUtility.scaledSpacing(34))
                    .padding(.bottom, ScaleUtility.scaledSpacing(10))
                    .frame(height: ScaleUtility.scaledValue(97))
                    .background {
                        Image(.tabBg)
                            .resizable()
                            .frame(height: ScaleUtility.scaledValue(97))
                            .frame(maxWidth:.infinity)
                    }
                    .cornerRadius(10)
                }
    
            }
            .ignoresSafeArea(.all)
            
        }
    }
    
    private func loadTemplate(_ template: LEDTemplate) {
        text = template.text
        textSize = template.textSize
        strokeSize = template.strokeSize ?? 0.0
        backgroundImage = template.imageName
        backgroundResultImage = template.backgroundResultImage
        selectedFont = template.selectedFont
        if template.isBold {
            selectedEffects.insert("Bold")
            selectedEffects.remove("None")
        }
        if template.isItalic {
            selectedEffects.insert("Italic")
            selectedEffects.remove("None")
        }
        // Load text color from hex
        // Load text color from hex
        if let hexColor = template.customTextColorHex, !hexColor.isEmpty {
            customTextColor = UIColor(hex: hexColor) ?? .white
            hasCustomTextColor = true
            // 👇 ensure the UI uses this custom color immediately
            selectedColor = ColorOption(
                id: "custom_text",
                name: "Custom",
                type: .solid(Color(customTextColor))
            )
        } else {
            hasCustomTextColor = false
            customTextColor = .white
            // (optional) reset to a default swatch if you want:
            // selectedColor = ColorOption.predefinedColors[1]
        }

        
        // Load stroke color from predefined colors
        if let strokeSize = template.strokeSize, strokeSize > 0,
           let strokeColorId = template.strokeColorId,
           let strokeColor = OutlineColorOption.predefinedOutlineColors.first(where: { $0.id == strokeColorId }) {
            selectedOutlineColor = strokeColor
            outlineEnabled = true
        } else {
            outlineEnabled = false
        }
    }
}
