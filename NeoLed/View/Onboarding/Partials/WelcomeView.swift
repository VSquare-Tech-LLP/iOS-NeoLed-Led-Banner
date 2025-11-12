//
//  WelcomeView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 25/09/25.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    
    var isActive: Bool
    
    @State var isShowTitle: Bool = false
    @State var isShowSubtitle: Bool = false
    @State var isShowImage: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: ScaleUtility.scaledSpacing(28)) {
                Image(.appLogo)
                    .resizable()
                    .frame(width: ScaleUtility.scaledValue(150), height: ScaleUtility.scaledValue(150))
                    .offset(y: ScaleUtility.scaledSpacing(-6))
                    .scaleEffect(isShowImage ? 1.0 : 0.5)
                    .opacity(isShowImage ? 1.0 : 0.0)
                
                VStack(spacing: ScaleUtility.scaledSpacing(10)) {
                    Text("Welcome to NeoLED")
                        .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(34)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.primaryApp)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .scaleEffect(isShowTitle ? 1.0 : 0.5)
                        .opacity(isShowTitle ? 1.0 : 0.0)
                    
                    Text("Make LED banners that grab attention! Simple, fast, and fully customizable!")
                      .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(16)))
                      .multilineTextAlignment(.center)
                      .foregroundColor(.primaryApp .opacity(0.6))
                      .frame(width: isIPad ? ScaleUtility.scaledValue(403) : ScaleUtility.scaledValue(303))
                      .lineSpacing(5)
                      .offset(y: ScaleUtility.scaledSpacing(6))
                      .scaleEffect(isShowSubtitle ? 1.0 : 0.5)
                      .opacity(isShowSubtitle ? 1.0 : 0.0)
                    
                }
            }
            .offset(y: ScaleUtility.scaledSpacing(-7))
        }
        .onAppear {
            performAnimation()
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                performAnimation()
            }
        }
    }
    
    func performAnimation() {
        self.isShowTitle = false
        self.isShowSubtitle = false
        self.isShowImage = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowImage = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowTitle = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowSubtitle = true
            }
        }
    }
}
