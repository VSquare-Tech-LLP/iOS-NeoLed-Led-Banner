//
//  ReusableCustomSlider.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 26/09/25.
//

import Foundation
import SwiftUI



// MARK: - Updated Custom Slider (Reusable)
struct ReusableCustomSlider: View {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>

    let sliderWidth: CGFloat = ScaleUtility.scaledValue(ScaleUtility.isPad() ? 680 : 310)
    let trackHeight: CGFloat = 10
    let thumbSize: CGFloat = 32
    let innerDotSize: CGFloat = 8
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    
    var body: some View {
        let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))

        ZStack(alignment: .leading) {
            // Track background
            Capsule()
                .fill(Color.secondaryBG)
                .frame(width: sliderWidth, height: trackHeight)

            // Filled progress
            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: sliderWidth * progress, height: trackHeight)

            // Thumb

            Circle()
                .fill(Color.white)
                .frame(width: ScaleUtility.scaledValue(18), height: ScaleUtility.scaledValue(18))
                .overlay(
                    Circle()
                        .fill(Color.black)
                        .frame(width: ScaleUtility.scaledValue(7), height: ScaleUtility.scaledValue(7))
                )
                .offset(x: sliderWidth * progress - thumbSize / 5)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            selectionFeedback.selectionChanged()
                            let location = min(max(gesture.location.x, 0), sliderWidth)
                            let newValue = Double(location / sliderWidth) * (range.upperBound - range.lowerBound) + range.lowerBound
                            value = newValue
                           
                        }
                )
        }
        .frame(width: sliderWidth, height: max(trackHeight, thumbSize))
    }
}
