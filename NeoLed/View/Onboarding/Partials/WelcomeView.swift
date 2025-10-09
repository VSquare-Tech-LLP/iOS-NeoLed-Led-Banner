//
//  WelcomeView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 25/09/25.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: ScaleUtility.scaledSpacing(28)) {
                Image(.appLogo)
                    .resizable()
                    .frame(width: ScaleUtility.scaledValue(150), height: ScaleUtility.scaledValue(150))
                    .offset(y: ScaleUtility.scaledSpacing(-6))
                
                VStack(spacing: ScaleUtility.scaledSpacing(10)) {
                    Text("Welcome to NeoLED")
                        .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(34)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.primaryApp)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    
                    Text("Make LED banners that grab attention! Simple, fast, and fully customizable!")
                      .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(16)))
                      .multilineTextAlignment(.center)
                      .foregroundColor(.primaryApp .opacity(0.6))
                      .frame(width: ScaleUtility.scaledValue(303))
                      .lineSpacing(5)
                      .offset(y: ScaleUtility.scaledSpacing(6))
                     
                }
            }
            .offset(y: ScaleUtility.scaledSpacing(-7))
        }

    }
}
