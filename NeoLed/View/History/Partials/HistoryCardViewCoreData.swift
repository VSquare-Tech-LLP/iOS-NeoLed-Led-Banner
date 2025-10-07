//
//  HistoryCardViewCoreData.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 06/10/25.
//


import SwiftUI

struct HistoryCardViewCoreData: View {
    let design: LEDDesignEntity
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    // Use the effectsArray extension to safely get effects
    var isBold: Bool { design.effectsArray.contains("Bold") }
    var isItalic: Bool { design.effectsArray.contains("Italic") }
    var isLight: Bool { design.effectsArray.contains("Blink") }
    var isFlash: Bool { design.effectsArray.contains("Glow") }
    var isMirror: Bool { design.effectsArray.contains("Mirror") }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                
                GeometryReader { geo in
                    ZStack {
                        
                        if let liveBg = design.selectedLiveBg, liveBg != "None" {
                            GifuGIFView(name: liveBg)
                                .frame(
                                    width: UIScreen.main.bounds.height,  // Use screen bounds instead of geo
                                    height: UIScreen.main.bounds.width
                                )
                                .position(x: geo.size.width / 2, y: geo.size.height / 2)  // Center it
                                .if(!design.isHD) { view in
                                    view.mask {
                                        getShapeImage()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                    }
                                }
                        }
                        else if design.backgroundImage != "" {
                            Image(design.backgroundImage ?? "LED1")
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .if(!design.isHD) { view in
                                    view.mask {
                                        getShapeImage()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                    }
                                }
                        }
                        else if design.backgroundEnabled {
                           design.toBgColor().color
                       } else {
                           Color.secondaryApp
                       }
                        
                        
                        // LED Shape overlay (when not HD)
                        if !design.isHD {
                            getShapeImage()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .opacity(0.1)
                        }
                        
      
                        
                        // Text Preview - Centered
                            if let text = design.text {
                                if design.strokeSize > 0 {
                                    Text(text)
                                        .font(.custom(design.selectedFont ?? FontManager.bricolageGrotesqueRegularFont, size: design.textSize * 30 / 2))
                                        .fontWeight(isBold ? .heavy : .regular)
                                        .italic(isItalic)
                                        .modifier(ColorModifier(colorOption: design.toEffectiveTextColorOption()))
                                        .stroke(
                                            color: design.outlineEnabled ? design.toOutlineColor().color : .white,
                                            width: design.strokeSize / 2
                                        )
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 16)
                                } else {
                                    Text(text)
                                        .font(.custom(design.selectedFont ?? FontManager.bricolageGrotesqueRegularFont, size: design.textSize * 30 / 2))
                                        .fontWeight(isBold ? .heavy : .regular)
                                        .italic(isItalic)
                                        .modifier(ColorModifier(colorOption:  design.toEffectiveTextColorOption()))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 16)
                                }
                           
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .if(!design.isHD) { view in
                        view.mask {
                            getShapeImage()
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                    .overlay {  // <-- HERE IS THE OVERLAY
                        if let frameBg = design.frameBg, frameBg != "None" {
                            Image(frameBg)
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .if(!design.isHD) { view in
                                    view.mask {
                                        getShapeImage()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                    }
                                }
                        }
                    }
          
                }
                .frame(maxWidth: .infinity)
                .frame(height: ScaleUtility.scaledValue(130))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Delete Button
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(.deleteIcon)
                        .resizable()
                        .frame(width: ScaleUtility.scaledValue(12), height: ScaleUtility.scaledValue(12))
                        .padding(.all, ScaleUtility.scaledSpacing(6))
                        .background{
                            Circle()
                                .fill(.secondaryApp.opacity(0.5))
                        }
                        .overlay(
                            Circle()
                                .stroke(.primaryApp.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(ScaleUtility.scaledSpacing(10))
                .alert("Delete Design", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        onDelete()
                    }
                } message: {
                    Text("Are you sure you want to delete this design?")
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.5)
                    .stroke(.primaryApp.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func getShapeImage() -> some View {
        switch design.selectedShape {
        case "circle":
            Image(.circle3)
                .resizable()
                .scaledToFill()
        case "square":
            Image(.square3)
                .resizable()
                .scaledToFill()
        case "heart":
            Image(.heart3)
                .resizable()
                .scaledToFill()
        case "star":
            Image(.star3)
                .resizable()
                .scaledToFill()
        case "ninjaStar":
            Image(.ninjaStar3)
                .resizable()
                .scaledToFill()
        default:
            Image(.circle3)
                .resizable()
                .scaledToFill()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
