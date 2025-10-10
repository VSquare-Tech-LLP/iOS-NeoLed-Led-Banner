//
//  CustomTabPicker.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 03/10/25.
//

import Foundation
import SwiftUI

struct CustomTabPicker: View {
    @Binding var selectedTab:Int
    var tabs: [String]  // This is now a parameter for dynamic tabs.
    var isInside:Bool = false
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        
        GeometryReader { geometry in
            let totalWidth = geometry.size.width - 32 // padding adjustment
            let tabWidth = totalWidth / CGFloat(tabs.count) // dynamically calculating tab width
            let activeRectanglePadding: CGFloat = 4  // added padding for active rectangle
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.secondaryBG)
                    .scaledFrame(baseHeight: ScaleUtility.scaledValue(42))
             

                RoundedRectangle(cornerRadius: 50)
                    .fill(isInside ? Color.secondaryBG : Color.primaryApp )
                    .frame(width: tabWidth - 2 * activeRectanglePadding)
                    .scaledFrame(baseHeight: ScaleUtility.scaledValue(38))
                // reducing width
                    .offset(x: CGFloat(selectedTab) * tabWidth + activeRectanglePadding) // shifting the active rect
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedTab)

                HStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                selectionFeedback.selectionChanged()
                                selectedTab = index
                            }
                        }) {
                            HStack(spacing: ScaleUtility.scaledSpacing(8)) {
                               
                                Text(tabs[index])
                                    .font(selectedTab == index
                                          ? FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(14))
                                          : FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(14)))
                                
                                    .kerning(0.42)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor( selectedTab == index ? Color.secondaryApp : Color.primaryApp.opacity(0.5))

                            }
                            .frame(width: tabWidth)
                            .scaledFrame(baseHeight: ScaleUtility.scaledValue(38))
                            .foregroundColor( selectedTab == index ? Color.secondaryApp : Color.primaryApp )
                 
                        }
                    }
                }
            }
            .padding(.horizontal, ScaleUtility.scaledValue(22))  // 16px padding around the whole tab picker
        }
        .scaledFrame(baseHeight: ScaleUtility.scaledValue(42))
    }
}
