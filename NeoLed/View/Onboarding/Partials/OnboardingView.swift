//
//  OnboardingView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 25/09/25.
//

import Foundation
import SwiftUI

struct OnboardingView: View {

    var imageName: String
    var title: String
    
    var body: some View {

        VStack {
            VStack
            {
                Text(title)
                    .font(FontManager.bricolageGrotesqueExtraBold(size:.scaledFontSize(30)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primaryApp)
                    .lineSpacing(8)
                  
                
                Spacer()
            }
            .overlay {
                Image(imageName)
                    .resizable(size: CGSize(
                        width: isIPad ? 850 * ipadWidthRatio : ScaleUtility.scaledValue(375) ,
                        height: isIPad ? 1066 * ipadHeightRatio : ScaleUtility.scaledValue(604) ))
                    .offset(y: ScaleUtility.scaledSpacing(59))
            }
            .padding(.top, ScaleUtility.scaledSpacing(40))
        }
    }
}
