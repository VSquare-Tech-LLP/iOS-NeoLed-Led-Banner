//
//  ExploreView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 24/09/25.
//

import Foundation
import SwiftUI

struct ExploreView: View {
    
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var timerManager: TimerManager
    
    @State var selectedOption: String = "LED"
    var onTemplateSelect: (LEDTemplate) -> Void  // Add callback
    
    // Function to get images based on selected filter
    private func getImagesForFilter(_ filter: String) -> [String] {
        switch filter {
        case "LED":
            return ["l1", "l2", "l3", "l4", "l5", "l6"]
        case "Business":
            return ["b1", "b2", "b3", "b4", "b5"]
        case "Holidays":
            return ["h1", "h2", "h3", "h4", "h5", "h6"]
        case "Celebrations":
            return ["c1", "c2", "c3", "c4", "c5"]
        case "Informational":
            return ["i1", "i2", "i3", "i4", "i5"]
        default:
            return []
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                
                HeaderView()
                
                BannerFilter(selectedOption: $selectedOption)
                
                if remoteConfigManager.giftAfterOnBoarding {
                    if !timerManager.isExpired && !purchaseManager.hasPro && remoteConfigManager.showLifeTimeBannerAtHome {
                        LifeTimeGiftOfferBannerView()
                    }
                }
                
            }
            
            ScrollView {
                
                Spacer()
                    .frame(height: ScaleUtility.scaledValue(15))
                
                LazyVStack(spacing: ScaleUtility.scaledSpacing(15)) {
                    ForEach(getImagesForFilter(selectedOption), id: \.self) { imageName in
                        CardView(imageName: imageName) {
                            // Get template and call callback
                            let template = TemplateDataManager.shared.getTemplate(for: imageName)
                            onTemplateSelect(template)
                        }
                    }
                }
                .padding(.horizontal, ScaleUtility.scaledSpacing(20))
              
                
                Spacer()
                    .frame(height: ScaleUtility.scaledValue(150))
                
            }
            .padding(.top, ScaleUtility.scaledSpacing(5))
            
            Spacer()
        }
        .background {
            Image(.background)
                .resizable()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
    }
}
