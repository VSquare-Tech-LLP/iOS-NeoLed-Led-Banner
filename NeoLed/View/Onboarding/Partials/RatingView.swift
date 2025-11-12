//
//  ratingPage.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 25/09/25.
//

import Foundation
import SwiftUI
import StoreKit

struct RatingView: View {
    
    var isActive: Bool
    
    @State var isShowTitle1: Bool = false
    @State var isShowTitle2: Bool = false
    @State var isShowSubtitle: Bool = false
    @State var isShowImage: Bool = false
    
    var body: some View
    {
        VStack(spacing: 0) {
            
            VStack(spacing: isIPad ? ScaleUtility.scaledSpacing(168) : ScaleUtility.scaledSpacing(68)) {
                
                VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                    
                    VStack(spacing: 0) {
                        Text("Thanks for ")
                            .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(45)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.primaryApp)
                            .scaleEffect(isShowTitle1 ? 1.0 : 0.5)
                            .opacity(isShowTitle1 ? 1.0 : 0.0)
                        
                        Text("Rating!")
                            .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(45)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.primaryApp)
                            .scaleEffect(isShowTitle2 ? 1.0 : 0.5)
                            .opacity(isShowTitle2 ? 1.0 : 0.0)
                        
                    }
                    
                    Text("Your rating helps people design\nLED banners, one rating at a time.")
                        .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(18)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.primaryApp.opacity(0.7))
                        .scaleEffect(isShowSubtitle ? 1.0 : 0.5)
                        .opacity(isShowSubtitle ? 1.0 : 0.0)
                }
   
            
                    
                    RoundedRectangle(cornerRadius: 293)
                        .frame(width: ScaleUtility.scaledValue(236), height: ScaleUtility.scaledValue(172))
                        .background(Color.accent.opacity(0.4))
                        .blur(radius: 90)
                        .overlay {
                            Image(.heartIcon)
                                .resizable()
                                .frame(width: isIPad ? ScaleUtility.scaledValue(223) :  ScaleUtility.scaledValue(175),
                                       height:isIPad ? ScaleUtility.scaledValue(281) :  ScaleUtility.scaledValue(202))
                                .offset(y:ScaleUtility.scaledValue(16))
                                .scaleEffect(isShowImage ? 1.0 : 0.5)
                                .opacity(isShowImage ? 1.0 : 0.0)
                        }
                   
                    
         
                  
            }
            .padding(.top, ScaleUtility.scaledSpacing(54))
            
            Spacer()
        }

        .onAppear
        {
            performAnimation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                showRatingPopup()
            }
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                performAnimation()
            }
        }
 
    }
    
    func performAnimation() {
        self.isShowTitle1 = false
        self.isShowTitle2 = false
        self.isShowSubtitle = false
        self.isShowImage = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowTitle1 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowTitle2 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowSubtitle = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowImage = true
            }
        }
        
    }
    
    
    func showRatingPopup() {
        let userSettings = UserSettings() // Get user settings instance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            if userSettings.ratingPopupCount < 1  {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    
                    // Increment the rating count
                    userSettings.ratingPopupCount += 1
                    

                }
            }
        }
    }
}
