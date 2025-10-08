//
//  SettingsView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 02/10/25.
//


import Foundation
import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading,spacing: ScaleUtility.scaledSpacing(20)) {
                
                HStack(spacing: ScaleUtility.scaledSpacing(13)) {
                    Button {
                        onBack()
                    } label: {
                        Image(.backIcon)
                            .resizable()
                            .frame(width: ScaleUtility.scaledValue(34), height: ScaleUtility.scaledValue(34))
                    }
                    
                    Text("Settings")
                        .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(25.56818)))
                        .foregroundColor(Color.primaryApp)
                    
                    
                    Spacer()
                    
                }
                .padding(.horizontal,ScaleUtility.scaledSpacing(15))
                .padding(.top,ScaleUtility.scaledSpacing(15))
                
                if remoteConfigManager.giftAfterOnBoarding {
                    if !timerManager.isExpired && !purchaseManager.hasPro && !remoteConfigManager.showLifeTimeBannerAtHome {
                        LifeTimeGiftOfferBannerView()
                        
                    }
                    
                }
                
                if !purchaseManager.hasPro {
                    
                    TryProContainerView()
                    
                }
                
                
                SettingsCardsView()
                
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .background {
            Image(.background)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
        }
        
    }
}

