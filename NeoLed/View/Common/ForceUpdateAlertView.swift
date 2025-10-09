//
//  ForceUpdateAlertView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 09/10/25.
//


import Foundation
import SwiftUI

struct ForceUpdateAlertView: View {
    @Environment(\.colorScheme) var colorScheme

    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    
    var body: some View {
        ZStack {
            Color.secondaryApp.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: ScaleUtility.scaledSpacing(20) ) {
                // Header
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(50)))
                    .foregroundColor(Color.red)
                    .padding(.top, ScaleUtility.scaledSpacing(30))
                
                Text("Update Required")
                    .font(FontManager.bricolageGrotesqueBoldFont(size:.scaledFontSize(18)))
                    .foregroundColor(Color.secondaryApp)
                
                Text("A new version is available. Please update to continue using the app.")
                    .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(15)))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .scaledFontSize(20))
                    .foregroundColor(Color.secondaryApp)
                
                Divider()
                    .background(Color.secondaryApp)
                    .offset(y:.scaledFontSize(10))
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    self.openAppInAppStore()
                    AnalyticsManager.shared.log(.noOfUserUpdatedApp)
                })
                {
                    Text("Update Now")
                        .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(20)))
                        .foregroundColor(Color.blue)
                }
                .padding(.top, .scaledFontSize(10))
                .padding(.bottom, .scaledFontSize(30))
                .buttonStyle(.plain)
            }
            .frame(width: UIScreen.main.bounds.width - 60)
            .background(Color.primaryApp.ignoresSafeArea(.all))
            .cornerRadius(25)
            .shadow(radius: 10)
        }
        .ignoresSafeArea()
    }
    
    private func openAppInAppStore() {
        if let appStoreUrl = URL(string: AppConstant.shareAppIDURL) {
            UIApplication.shared.open(appStoreUrl)
        }
    }
}

#Preview {
    ForceUpdateAlertView()
}

