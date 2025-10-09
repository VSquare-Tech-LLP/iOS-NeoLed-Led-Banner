//
//  BannerFilter.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 26/09/25.
//

import Foundation
import SwiftUI

struct BannerFilter: View {
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    @Binding var selectedOption: String
    var bannerOptions = ["LED",
                         "Business",
                         "Holidays",
                         "Celebrations",
                         "Informational",]
    
    
    var body: some View {
        ScrollView(.horizontal,showsIndicators: false) {
            HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                ForEach(Array(bannerOptions.enumerated()), id: \.offset) { index, banner in
                    Button {
                        selectionFeedback.selectionChanged()
                        selectedOption = banner
                    } label: {
                        
                        Text(banner)
                            .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(14)))
                            .foregroundColor(Color.primaryApp)
                            .padding(.vertical, ScaleUtility.scaledSpacing(10))
                            .padding(.horizontal, ScaleUtility.scaledSpacing(18))
                            .background {
                                if selectedOption == banner {
                                    EllipticalGradient(
                                        stops: [
                                            Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.4), location: 0.00),
                                            Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03).opacity(0.1), location: 0.78),
                                        ],
                                        center: UnitPoint(x: 0.36, y: 0.34)
                                    )
                                } else {
                                    Color.clear
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke( selectedOption == banner ? Color.accent : Color.primaryApp.opacity(0.5), lineWidth: 1)
                            )
                        
                    }
                    .frame(height: isIPad ? ScaleUtility.scaledValue(54) :  ScaleUtility.scaledValue(40))
                }
            }
            .padding(.horizontal, ScaleUtility.scaledSpacing(20))
        }
    }
}
