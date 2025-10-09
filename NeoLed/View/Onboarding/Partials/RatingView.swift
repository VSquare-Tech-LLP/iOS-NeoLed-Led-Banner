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
                        
                        Text("Rating!")
                            .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(45)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.primaryApp)
                    }
                    
                    Text("Your rating helps people design\nLED banners, one rating at a time.")
                        .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(18)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.primaryApp.opacity(0.7))
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
                        }
                   
                    
         
                  
            }
            .padding(.top, ScaleUtility.scaledSpacing(54))
            
            Spacer()
        }

        .onAppear
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                showRatingPopup()
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
