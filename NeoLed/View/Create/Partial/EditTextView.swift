//
//  EditTextView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 26/09/25.
//
 
import SwiftUI

struct Fonts {
   let fontDisplay: String
   let fontImageName: String
}


struct Effect {
    let effectName: String
    let effectImage: String
}

struct TextAlignments {
    let alignmentName: String
    let alignmentImage: String
}

struct EditTextView: View {
       @Binding var selectedEffect: Set<String>
       @Binding var textSize: CGFloat
       @Binding var strokeSize: CGFloat
       @Binding var selectedFont: String
       @Binding var selectedColor: ColorOption
       @Binding var selectedOutlineColor: OutlineColorOption
       @Binding var outlineEnabled: Bool
       @Binding var hasCustomTextColor: Bool
       @Binding var customTextColor: UIColor
       @Binding var textSpeed: CGFloat
       @Binding var selectedAlignment: String
       @Binding var selectedLiveBg: String
       @Binding var selectedBgColor: OutlineColorOption
      var onValueChange: (() -> Void)? = nil
   var fontOptions: [Fonts] = [
      Fonts(fontDisplay: FontManager.bricolageGrotesqueRegularFont ,fontImageName: FontManager.bricolageGrotesqueBoldFont),
      Fonts(fontDisplay: FontManager.arvoRegularFont ,fontImageName: FontManager.arvoBoldFont),
      Fonts(fontDisplay: FontManager.balsamiqSansRegularFont ,fontImageName: FontManager.balsamiqSansBoldFont),
      Fonts(fontDisplay: FontManager.dmSerifDisplayRegularFont ,fontImageName: FontManager.dmSerifDisplayRegularFont),
      Fonts(fontDisplay: FontManager.dotoRegularFont ,fontImageName: FontManager.dotoBoldFont),
      Fonts(fontDisplay: FontManager.dynaPuffRegular ,fontImageName: FontManager.dynaPuffBold),
      Fonts(fontDisplay: FontManager.lobsterTwoRegularFont ,fontImageName: FontManager.lobsterTwoBoldFont),
      Fonts(fontDisplay: FontManager.montserratRegularFont ,fontImageName: FontManager.montserratBoldFont),
      Fonts(fontDisplay: FontManager.nunitoRegularFont ,fontImageName: FontManager.nunitoBoldFont),
      Fonts(fontDisplay: FontManager.openSansRegularFont ,fontImageName: FontManager.openSansBoldFont),
      Fonts(fontDisplay: FontManager.poppinsRegularFont ,fontImageName: FontManager.poppinsBoldFont),
      Fonts(fontDisplay: FontManager.ralewayRegularFont ,fontImageName: FontManager.ralewayBoldFont),
      Fonts(fontDisplay: FontManager.ribeyeRegularFont ,fontImageName: FontManager.ribeyeRegularFont),
      Fonts(fontDisplay: FontManager.robotoRegularFont ,fontImageName: FontManager.robotoBoldFont),
      Fonts(fontDisplay: FontManager.zillaSlabRegularFont ,fontImageName: FontManager.zillaSlabBoldFont),
   ]
   
    var effectOptions: [Effect] = [
        Effect(effectName: "None", effectImage: "noSelectionIcon"),
        Effect(effectName: "Bold", effectImage: "boldIcon"),
        Effect(effectName: "Italic", effectImage: "italicIcon"),
        Effect(effectName: "Glow", effectImage: "lightIcon"),
        Effect(effectName: "Blink", effectImage: "flashIcon"),
        Effect(effectName: "Mirror", effectImage: "mirrorIcon"),
    ]
    
    var alignmentOptions: [TextAlignments] = [
        TextAlignments(alignmentName: "None", alignmentImage: "noSelectionIcon"),
        TextAlignments(alignmentName: "left", alignmentImage: "leftArrowIcon"),
        TextAlignments(alignmentName: "right", alignmentImage: "rightArrowIcon"),
        TextAlignments(alignmentName: "up", alignmentImage: "upArrowIcon"),
        TextAlignments(alignmentName: "down", alignmentImage: "downArrowIcon"),

    ]

    
   // Color picker states
   @State private var showTextColorPicker = false
    
   @State private var showOutlineColorPicker = false

   @State private var customOutlineColor: UIColor = .blue
   @State private var hasCustomOutlineColor = false
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    @State var originalTextSize = 4.0
    @State var originalStrokeSize = 1.0
    @State var originalSpeed = 1.0
    
   var body: some View {
       VStack(spacing: 0) {
           VStack(spacing: ScaleUtility.scaledSpacing(15)) {
               
               VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                   Text("Text Effect")
                       .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.5942)))
                       .kerning(0.40783)
                       .foregroundColor(.white.opacity(0.5))
                       .frame(maxWidth: .infinity,alignment: .leading)
                       .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                   
                   ScrollView(.horizontal,showsIndicators: false) {
                       
                       HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                           
                           ForEach(Array(effectOptions.enumerated()), id: \.offset) { _, effect in
                               
                               VStack(spacing: ScaleUtility.scaledSpacing(6)) {
                                   
                                   let isSelected = selectedEffect.contains(effect.effectName)
                                   let isEffectAvailable = FontManager.isEffectAvailable(effect.effectName, for: selectedFont)
                                   
                                   Button {
                                       impactFeedback.impactOccurred()
                                       // Only allow interaction if effect is available
                                       guard isEffectAvailable else { return }
                                       
                                       // If "None" is clicked
                                       if effect.effectName == "None" {
                                           selectedEffect.removeAll()
                                           selectedEffect.insert("None")
                                           AnalyticsManager.shared.log(.effectApplied(effectName: "None"))
                                       }
                                       // If any other effect is clicked
                                       else {
                                           // Remove "None" if it exists
                                           selectedEffect.remove("None")
                                           
                                           // Toggle the clicked effect
                                           if isSelected {
                                               selectedEffect.remove(effect.effectName)
                                               // If no effects remain, add "None" back
                                               if selectedEffect.isEmpty {
                                                   selectedEffect.insert("None")
                                               }
                                           } else {
                                               selectedEffect.insert(effect.effectName)
                                               AnalyticsManager.shared.log(.effectApplied(effectName: effect.effectName))
                                           }
                                       }
                                       
                                       onValueChange?()
                                       
                                   } label: {
                                       
                                       Image(effect.effectImage)
                                           .resizable()
                                           .frame(width:  isIPad ? ScaleUtility.scaledValue(24) :  ScaleUtility.scaledValue(16),
                                                  height:  isIPad ? ScaleUtility.scaledValue(24) : ScaleUtility.scaledValue(16))
                                           .padding(.all, ScaleUtility.scaledSpacing(13))
                                           .background {
                                               if isSelected {
                                                   EllipticalGradient(
                                                       stops: [
                                                           Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                                           Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.2), location: 0.78),
                                                       ],
                                                       center: UnitPoint(x: 0.36, y: 0.34)
                                                   )
                                               }
                                               else {
                                                   Color.black
                                               }
                                           }
                                           .cornerRadius(5)
                                           .overlay {
                                               RoundedRectangle(cornerRadius: 5)
                                                   .stroke( isSelected ? Color.accent : Color.clear, lineWidth: 1)
                                               
                                           }
                                           .opacity(isEffectAvailable ? 1.0 : 0.3)
                                   }
                                   .disabled(!isEffectAvailable)
                                   .frame(width: isIPad ? ScaleUtility.scaledValue(66) : ScaleUtility.scaledValue(44),
                                          height:isIPad ?  ScaleUtility.scaledValue(66) :  ScaleUtility.scaledValue(44))
                                       
                                   Text(effect.effectName)
                                       .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(12)))
                                       .foregroundColor(Color.primaryApp)
                                       .opacity(isEffectAvailable ? 1.0 : 0.3)
                               }
                           }
                           
                           
                       }
                       .frame(alignment: .leading)
                       .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                   }
                   
                   
               }
               
               Rectangle()
                   .foregroundColor(Color.primaryApp.opacity(0.2))
                   .frame(maxWidth: .infinity)
                   .frame(height: ScaleUtility.scaledValue(1.5))
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
           
               VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                   Text("Font Style")
                       .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(14)))
                       .kerning(0.42)
                       .foregroundColor(.primaryApp.opacity(0.5))
                       .frame(maxWidth: .infinity, alignment: .topLeading)
                       .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                   
                   ScrollView(.horizontal,showsIndicators: false) {
                       HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                           ForEach(Array(fontOptions.enumerated()), id: \.offset) { index, font in
                               Button(action: {
                                   impactFeedback.impactOccurred()
                                   selectedFont = font.fontDisplay
                                   AnalyticsManager.shared.log(.fontSelected(fontName: font.fontDisplay))
                                   onValueChange?()
                               }) {
                                   Text("Aa")
                                       .font(.custom(font.fontImageName, size: .scaledFontSize(14)))
                                       .foregroundColor(Color.primaryApp)
                                       .padding( isIPad ? ScaleUtility.scaledSpacing(13) : ScaleUtility.scaledSpacing(11))
                                       .background {
                                           if selectedFont == font.fontDisplay {
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
                                       .overlay {
                                           RoundedRectangle(cornerRadius: 5)
                                               .stroke(selectedFont == font.fontDisplay ? Color.accent : Color.clear, lineWidth: 2)
                                       }
                                       .cornerRadius(5)
                               }
                               .frame(width: isIPad ? ScaleUtility.scaledValue(66) : ScaleUtility.scaledValue(44),
                                      height:isIPad ?  ScaleUtility.scaledValue(66) :  ScaleUtility.scaledValue(44))
                           }
                       }
                       .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                   }
                   
               }
               
               Rectangle()
                   .foregroundColor(Color.primaryApp.opacity(0.2))
                   .frame(maxWidth: .infinity)
                   .frame(height: ScaleUtility.scaledValue(1.5))
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
               

               VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                   
                   HStack {
                       Text("Text Size")
                           .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(14)))
                           .kerning(0.42)
                           .foregroundColor(.primaryApp.opacity(0.5))
                       
                       Spacer()
                       
                       Button {
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                               textSize = originalTextSize
                           }
                       } label: {
                           Text("Reset")
                               .font(FontManager.bricolageGrotesqueLightFont(size: .scaledFontSize(14)))
                               .kerning(0.42)
                               .foregroundColor(Color(red: 1, green: 0.52, blue: 0.52))
                       }

                   }
                   .frame(maxWidth: .infinity)
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                
                   
                   HStack(spacing: ScaleUtility.scaledSpacing(17)) {
                       Text("A")
                           .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(10)))
                           .foregroundColor(.white)
                       
                       sizeCustomSlider(value: $textSize, range: 2.0...8.0)
                           .onChange(of: textSize) { _, _ in
                                                onValueChange?()  // ✅ ADD THIS
                                            }
                       
                       Text("A")
                           .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(16)))
                           .foregroundColor(.white)
                   }
               }
             
               
               Rectangle()
                   .foregroundColor(Color.primaryApp.opacity(0.2))
                   .frame(maxWidth: .infinity)
                   .frame(height: ScaleUtility.scaledValue(1.5))
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
               

               VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                   
                   HStack {
                       Text("Stroke Size")
                           .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(14)))
                           .kerning(0.42)
                           .foregroundColor(.primaryApp.opacity(0.5))
                       
                       Spacer()
                       
                       Button {
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                               strokeSize = originalStrokeSize
                             
                           }
                       } label: {
                           Text("Reset")
                               .font(FontManager.bricolageGrotesqueLightFont(size: .scaledFontSize(14)))
                               .kerning(0.42)
                               .foregroundColor(Color(red: 1, green: 0.52, blue: 0.52))
                       }

                   }
                   .frame(maxWidth: .infinity)
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                   
                   HStack(spacing: ScaleUtility.scaledSpacing(17)) {
                       
                       StrokeText(text: "A",
                                 width: 0.5,
                                 color: Color.primaryApp,
                                  font: FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(16)),
                                 fontWeight: .regular) // Use .regular, .bold, .heavy, etc.
                       
                       
                       sizeCustomSlider(value: $strokeSize, range: 0...7)
                           .onChange(of: strokeSize) { _, _ in
                                                onValueChange?()  // ✅ ADD THIS
                                            }
                       
                       StrokeText(text: "A",
                                  width: 1.0,
                                 color: Color.primaryApp,
                                  font: FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(16)),
                                 fontWeight: .regular) // Use .regular, .bold, .heavy, etc.
                       

                   }
               }
             
               
               Rectangle()
                   .foregroundColor(Color.primaryApp.opacity(0.2))
                   .frame(maxWidth: .infinity)
                   .frame(height: ScaleUtility.scaledValue(1.5))
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
          
      
               
               VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                   Text("Text Color")
                       .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.5942)))
                       .kerning(0.40783)
                       .foregroundColor(Color.primaryApp.opacity(0.5))
                       .frame(maxWidth: .infinity, alignment: .topLeading)
                       .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                   
                   ScrollView(.horizontal, showsIndicators: false) {
                       VStack(spacing: ScaleUtility.scaledSpacing(10)) {
                           // First Row - 10 colors
                           HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                               ForEach(0..<10) { index in
                                   colorButton(ColorOption.predefinedColors[index],onValueChange: {
                                       onValueChange?()
                                   })
                                       .frame(height:  isIPad ? ScaleUtility.scaledValue(45) : ScaleUtility.scaledValue(30))
                               }
                           }
                           .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                           
                           // Second Row - 10 colors
                           HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                               ForEach(10..<20) { index in
                                   colorButton(ColorOption.predefinedColors[index],onValueChange: {
                                       onValueChange?()
                                   })
                                       .frame(height:  isIPad ? ScaleUtility.scaledValue(45) : ScaleUtility.scaledValue(30))
                               }
                           }
                           .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                       }
                   }
               }
               
               Rectangle()
                   .foregroundColor(Color.primaryApp.opacity(0.2))
                   .frame(maxWidth: .infinity)
                   .frame(height: ScaleUtility.scaledValue(1.5))
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
               
               ScrollView(.horizontal, showsIndicators: false) {
                   OutlineColorPickerView(
                       text: "Stroke Color",
                       selectedOutlineColor: $selectedOutlineColor,
                       showColorPicker: $showOutlineColorPicker,
                       hasCustomColor: $hasCustomOutlineColor,
                       customColor: $customOutlineColor,
                       outlineEnabled: $outlineEnabled,
                       selectedLiveBg: $selectedLiveBg,
                       isBackground: false ,
                       selectedBgColor: $selectedBgColor,
                       onValueChange: {
                           onValueChange!()
                       }
                   )
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
               }
               
               Rectangle()
                   .foregroundColor(Color.primaryApp.opacity(0.2))
                   .frame(maxWidth: .infinity)
                   .frame(height: ScaleUtility.scaledValue(1.5))
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
               
               
               VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                   
                   HStack {
                       Text("Text Speed")
                           .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.5942)))
                           .kerning(0.40783)
                           .foregroundColor(.primaryApp.opacity(0.5))
                       
                       Spacer()
                       
                       Button {
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                               textSpeed = originalSpeed
                             
                           }
                       } label: {
                           Text("Reset")
                               .font(FontManager.bricolageGrotesqueLightFont(size: .scaledFontSize(14)))
                               .kerning(0.42)
                               .foregroundColor(Color(red: 1, green: 0.52, blue: 0.52))
                       }

                   }
                   .frame(maxWidth: .infinity)
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                   
                   ReusableCustomSlider(value: $textSpeed, range: 0.5...5.0)
                       .onChange(of: textSpeed) { _, _ in
                                         onValueChange?()  // ✅ ADD THIS
                                     }
              
               }
               
               Rectangle()
                   .foregroundColor(Color.primaryApp.opacity(0.2))
                   .frame(maxWidth: .infinity)
                   .frame(height: ScaleUtility.scaledValue(1.5))
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
               
               
               VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                   Text("Scroll Direction")
                       .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.5942)))
                       .kerning(0.40783)
                       .foregroundColor(Color.primaryApp.opacity(0.5))
                       .frame(maxWidth: .infinity, alignment: .topLeading)
                       .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                   
                   ScrollView(.horizontal,showsIndicators: false) {
                       
                       HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                           ForEach(Array(alignmentOptions.enumerated()), id: \.offset) { index, align in
                               
                               Button {
                                   AnalyticsManager.shared.log(.scrollDirectionChanged(direction: align.alignmentName))
                                   DispatchQueue.main.async {
                                       impactFeedback.impactOccurred()
                                       selectedAlignment = ""
                                       selectedAlignment = align.alignmentName
                                       onValueChange?()
                                   }
                               } label: {
                                   Image(align.alignmentImage)
                                       .resizable()
                                       .frame(width:  isIPad ? ScaleUtility.scaledValue(24) : ScaleUtility.scaledValue(16),
                                              height:  isIPad ? ScaleUtility.scaledValue(24) : ScaleUtility.scaledValue(16))
                                       .padding(.all, ScaleUtility.scaledSpacing(13))
                                       .background {
                                           if selectedAlignment == align.alignmentName {
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
                                               .stroke( selectedAlignment == align.alignmentName ? Color.accent : Color.clear, lineWidth: 1)
                                           
                                       }
                               }
                               .frame(width:  isIPad ? ScaleUtility.scaledValue(66) : ScaleUtility.scaledValue(44),
                                      height:  isIPad ? ScaleUtility.scaledValue(66) : ScaleUtility.scaledValue(44))
                               
                           }
                       }
                       
                       
                       
                   }
                   .frame(alignment: .leading)
                   .padding(.horizontal, ScaleUtility.scaledSpacing(20))
               }
          

           }
       }
       .onAppear {
           originalTextSize = textSize
           originalStrokeSize = strokeSize
           originalSpeed = textSpeed
         
       }
       .onChange(of: selectedFont) { _, newFont in
           // Remove Bold effect if new font doesn't support it
           if !FontManager.isEffectAvailable("Bold", for: newFont) {
               selectedEffect.remove("Bold")
           }
           
           // Remove Italic effect if new font doesn't support it
           if !FontManager.isEffectAvailable("Italic", for: newFont) {
               selectedEffect.remove("Italic")
           }
           
           // If no effects remain after removal, add "None"
           if selectedEffect.isEmpty {
               selectedEffect.insert("None")
           }
       }
       .sheet(isPresented: $showTextColorPicker) {
           ColorPickerSheet(
               uiColor: $customTextColor,
               isPresented: $showTextColorPicker,
               onColorApplied: { color in
                   customTextColor = color
                   selectedColor = ColorOption(
                       id: "custom_text",
                       name: "Custom",
                       type: .solid(Color(color))
                   )
                   hasCustomTextColor = true
                   AnalyticsManager.shared.log(.textColorSelected(colorName: "Custom"))
               }
           )
           .presentationDetents(isIPad ? [.large, .fraction(0.95)] : [.fraction(0.9)])
       }
       .sheet(isPresented: $showOutlineColorPicker) {
           ColorPickerSheet(
               uiColor: $customOutlineColor,
               isPresented: $showOutlineColorPicker,
               onColorApplied: { color in
                   customOutlineColor = color
                   selectedOutlineColor = OutlineColorOption(
                       id: "custom_outline",
                       name: "Custom",
                       color: Color(color)
                   )
                   hasCustomOutlineColor = true
                   outlineEnabled = true
                   
                   AnalyticsManager.shared.log(.strokeColorSelected(colorName: "Custom"))
               }
           )
           .presentationDetents(isIPad ? [.large, .fraction(0.95)] : [.fraction(0.9)])
       }
   }
   
   @ViewBuilder
   private func colorButton(_ colorOption: ColorOption,onValueChange: (() -> Void)) -> some View {
       Button(action: {
           impactFeedback.impactOccurred()
           if colorOption.id == "white" {
               showTextColorPicker = true
           } else {
               selectedColor = colorOption
               hasCustomTextColor = false  // Deselect custom color
               AnalyticsManager.shared.log(.textColorSelected(colorName: colorOption.name))
           }
       }) {
           ZStack {
               Rectangle()
                   .foregroundColor(.clear)
                   .frame(width: isIPad ? ScaleUtility.scaledValue(42) :  ScaleUtility.scaledValue(28),
                          height:  isIPad ? ScaleUtility.scaledValue(42) : ScaleUtility.scaledValue(28))
                   .cornerRadius(5.83333)
                   .overlay {
                       RoundedRectangle(cornerRadius: 5)
                           .stroke(
                               (selectedColor.id == colorOption.id ||
                                (colorOption.id == "white" && hasCustomTextColor)) ?
                                   Color.accent : Color.clear,
                               lineWidth: 1
                           )
                   }
               
               // Show custom color in the white button if selected
               if colorOption.id == "white" && hasCustomTextColor {
                   Rectangle()
                       .fill(Color(customTextColor))
                       .frame(
                        width:  isIPad ? ScaleUtility.scaledValue(33) : ScaleUtility.scaledValue(22),
                        height:  isIPad ? ScaleUtility.scaledValue(33) : ScaleUtility.scaledValue(22)
                       )
                       .cornerRadius(5)
               } else {
                   colorOption.colorPreview(
                       size: (selectedColor.id == colorOption.id && !hasCustomTextColor)
                       ?  isIPad ? ScaleUtility.scaledValue(33) : ScaleUtility.scaledValue(22)
                       :  isIPad ? ScaleUtility.scaledValue(42) : ScaleUtility.scaledValue(28)
                   )
                   .overlay {
                       if colorOption.id == "white" && !hasCustomTextColor {
                           Image(.plusIcon)
                               .resizable()
                               .frame(width:  isIPad ? ScaleUtility.scaledValue(21) : ScaleUtility.scaledValue(14),
                                      height:  isIPad ? ScaleUtility.scaledValue(21) : ScaleUtility.scaledValue(14))
                       }
                   }
               }
           }
       }
   }
}
