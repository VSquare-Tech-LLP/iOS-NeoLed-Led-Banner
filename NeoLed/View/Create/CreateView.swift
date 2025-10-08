//
//  CreateView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 24/09/25.
//

import Foundation
import SwiftUI

struct CreateView: View {
     @Binding var backgroundResultImage: String
     @Binding var text: String
     @Binding var backgroundImage: String
     @Binding var textSize: CGFloat
     @Binding var strokeSize: CGFloat
     @Binding var selectedFont: String
     @Binding var selectedColor: ColorOption
     @Binding var selectedOutlineColor: OutlineColorOption
     @Binding var outlineEnabled: Bool
     @Binding var backgroundEnabled: Bool
     @Binding var hasCustomTextColor: Bool
     @Binding var customTextColor: UIColor
     @Binding var selectedEffects: Set<String>
     @FocusState private var inputFocused: Bool
   
    
    
     @State var selectedEditOption: String = "Text"
      var editOptions = ["Text",
                       "Effect",
                       "Background"]
    
    // Text customization states
//     @State private var textSize: CGFloat = 2.0
//     @State private var strokeSize: CGFloat = 0.0
//     @State private var selectedFont: String = FontManager.bricolageGrotesqueRegularFont
//     @State private var selectedColor: ColorOption = ColorOption.predefinedColors[1]
//     @State private var selectedOutlineColor: OutlineColorOption = OutlineColorOption.predefinedOutlineColors[0]
//     @State private var outlineEnabled = false
//     @State private var backgroundEnabled = false
//     @State private var hasCustomTextColor = false
//     @State private var customTextColor: UIColor = .white
     @State private var selectedBgColor: OutlineColorOption = OutlineColorOption.predefinedOutlineColors[0]
     
     // Effect customization states
//     @State private var selectedEffects: Set<String> = ["None"]
     @State private var selectedAlignment: String = "None"
     @State private var selectedShape: String = "None"
     @State private var selectedLiveBg: String = "None"
     @State private var frameBg: String = "None"
     @State var frameResultBg: String = "None"
     @State private var textSpeed: CGFloat = 1.0
     @State var showPreview: Bool = false
     @State var isHD: Bool = false 
     @State var selectedTab: Int = 0
 
    var body: some View {
        VStack(spacing:0) {
            
            VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                
                TopView(
                    backgroundImage: $backgroundImage,
                    text: $text,
                    selectedFont: $selectedFont,
                    textSize: $textSize,
                    strokeSize: $strokeSize,
                    selectedColor: $selectedColor,
                    selectedOutlineColor: $selectedOutlineColor,
                    outlineEnabled: $outlineEnabled,
                    hasCustomTextColor: $hasCustomTextColor,
                    customTextColor: $customTextColor,
                    selectedEffects: $selectedEffects,  // Add this line
                    selectedAlignment: $selectedAlignment,
                    selectedShape: $selectedShape,
                    textSpeed: $textSpeed,
                    isHD: $isHD,
                    selectedBgColor: $selectedBgColor,
                    backgroundEnabled: $backgroundEnabled,
                    selectedLiveBg: $selectedLiveBg,
                    frameBg: $frameBg,
                    isInputFocused: $inputFocused) {
                        if text != "" {
                            showPreview = true
                        }
                }
                
                CustomTabPicker(selectedTab: $selectedTab, tabs: ["Text","Background"])
                

            }
            
            ScrollView {
                
                Spacer()
                    .frame(height: ScaleUtility.scaledValue(25))
                
                
                if selectedTab == 0 {
                    
                    EditTextView(
                        selectedEffect: $selectedEffects,
                        textSize: $textSize,
                        strokeSize: $strokeSize,
                        selectedFont: $selectedFont,
                        selectedColor: $selectedColor,
                        selectedOutlineColor: $selectedOutlineColor,
                        outlineEnabled: $outlineEnabled,
                        hasCustomTextColor: $hasCustomTextColor,
                        customTextColor: $customTextColor,
                        textSpeed: $textSpeed,
                        selectedAlignment: $selectedAlignment,
                        selectedLiveBg: $selectedLiveBg,
                        selectedBgColor: $selectedBgColor)
              
                }
                else {
                    
                    EditBackgroundView(isHD: $isHD,
                                       selectedShape: $selectedShape,
                                       selectedBgColor: $selectedBgColor,
                                       backgroundEnabled: $backgroundEnabled,
                                       selectedLiveBg: $selectedLiveBg,
                                       frameBg: $frameBg,
                                       frameResultBg: $frameResultBg)
                    
                    
                }
      
                
                Spacer()
                    .frame(height: ScaleUtility.scaledValue(105))
                  
            }
           
            
            
            
            Spacer()
        }
        .background {
            Image(.background)
                .resizable()
                .scaledToFill()
        }
        .navigationDestination(isPresented: $showPreview) {
            ResultView(
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
                  selectedEffects: selectedEffects,  // Add this line
                  selectedAlignment: selectedAlignment,
                  selectedShape: selectedShape,
                  textSpeed: textSpeed,
                  isHD: isHD,
                  selectedLiveBg: selectedLiveBg,
                  frameResultBg: frameResultBg,
                  frameBg: frameBg,
                  isSaved: true,
                  onBack: {
                      showPreview = false
                  }
              )
            .background {
                Image(.background)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}
