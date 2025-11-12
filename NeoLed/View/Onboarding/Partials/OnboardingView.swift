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
    var isActive: Bool

    @State var isShowTitle: Bool = false
    @State var isShowImage: Bool = false
    
    var body: some View {

        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(title)
                    .font(FontManager.bricolageGrotesqueExtraBold(size:.scaledFontSize(30)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primaryApp)
                    .lineSpacing(8)
                    .scaleEffect(isShowTitle ? 1.0 : 0.5)
                    .opacity(isShowTitle ? 1.0 : 0.0)
                
                Spacer()
            }
            .overlay {
                Image(imageName)
                    .resizable(size: CGSize(
                        width: isIPad ? 850 * ipadWidthRatio : ScaleUtility.scaledValue(375) ,
                        height: isIPad ? 1066 * ipadHeightRatio : ScaleUtility.scaledValue(604) ))
                    .offset(y: ScaleUtility.scaledSpacing(59))
                    .scaleEffect(isShowImage ? 1.0 : 0.5)
                    .opacity(isShowImage ? 1.0 : 0.0)
            }
            .padding(.top, ScaleUtility.scaledSpacing(40))
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                performAnimation()
            }
        }
        .onAppear {
            performAnimation()
        }
    }
    
    
    func performAnimation() {
        self.isShowTitle = false
        self.isShowImage = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowTitle = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowImage = true
            }
        }
    }
}
