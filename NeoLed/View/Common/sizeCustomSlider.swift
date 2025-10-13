//
//  sizeCustomSlider.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 29/09/25.
//

import Foundation
import Foundation
import SwiftUI



// MARK: - Updated Custom Slider (Reusable)
struct sizeCustomSlider: View {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>

    let sliderWidth: CGFloat = ScaleUtility.scaledValue(isIPad ? ScaleUtility.scaledValue(600) : ScaleUtility.scaledValue(263))
    let trackHeight: CGFloat = 10
    let thumbSize: CGFloat = 32
    let innerDotSize: CGFloat = 8
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    
    var body: some View {
        let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))

        ZStack(alignment: .leading) {
            // Track background
            Capsule()
                .fill(.white.opacity(0.2))
                .frame(width: sliderWidth, height: trackHeight)

            // Filled progress
            Capsule()
                .fill(Color.white.opacity(0.7))
                .frame(width: sliderWidth * progress, height: trackHeight)

            // Thumb

            Circle()
                .fill(Color.white)
                .frame(width: ScaleUtility.scaledValue(17), height: ScaleUtility.scaledValue(17))
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
