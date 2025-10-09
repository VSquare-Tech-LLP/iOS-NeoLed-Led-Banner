//
//  cardView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 26/09/25.
//

import Foundation
import SwiftUI

struct CardView : View {
    
    var imageName: String
    var onTap: () -> Void  // Add callback
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        Button {
            impactFeedback.impactOccurred()
            onTap()
            AnalyticsManager.shared.log(.templateSelected(templateName: imageName))
        } label: {
            Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: ScaleUtility.scaledValue(130))
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            
        }

    }
}
