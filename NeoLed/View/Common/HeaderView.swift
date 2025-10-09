//
//  HeaderView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 26/09/25.
//

import Foundation
import SwiftUI

struct HeaderView: View {
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State var navToSettings: Bool = false
    @State var isShowPayWall: Bool = false
    
    var body: some View {
        HStack {
            Image(.appTitle)
                .resizable()
                .frame(width:  isIPad ? ScaleUtility.scaledValue(180) : ScaleUtility.scaledValue(120) ,
                       height: isIPad ? ScaleUtility.scaledValue(40) : ScaleUtility.scaledValue(20))
        
            Spacer()
            
            HStack(spacing: ScaleUtility.scaledSpacing(12)) {
                
                Button {
                    impactFeedback.impactOccurred()
                    isShowPayWall = true
                } label: {
                    
                    Image(.crownIcon)
                        .resizable()
                        .frame(width: isIPad ? ScaleUtility.scaledValue(30.45455) : ScaleUtility.scaledValue(20.45455),
                               height:  isIPad ? ScaleUtility.scaledValue(30.45455) : ScaleUtility.scaledValue(20.45455))
                        .padding(.all, ScaleUtility.scaledSpacing(6.77))
                        .background(Color.clear)
                        .overlay(
                            Circle()
                                .stroke(Color.accent, lineWidth: 1)
                        )
                }
                .opacity(purchaseManager.hasPro ? 0 : 1)
                
                Button {
                    impactFeedback.impactOccurred()
                    navToSettings = true
                } label: {
                    Image(.settingIcon)
                        .resizable()
                        .frame(width:  isIPad ? ScaleUtility.scaledValue(28.57641) : ScaleUtility.scaledValue(19.57641),
                               height:  isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(20))
                        .padding(.all, ScaleUtility.scaledSpacing(8))
                        .background{
                            Circle()
                                .fill( Color.primaryApp.opacity(0.1))
                           
                        }
                }

                
  
            }
        }
        .padding(.horizontal, ScaleUtility.scaledSpacing(20))
        .padding(.top, ScaleUtility.scaledSpacing(62))
        .navigationDestination(isPresented: $navToSettings) {
            SettingsView {
                navToSettings = false
            }
            .background {
                Image(.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            }
        }
        .fullScreenCover(isPresented: $isShowPayWall) {
            
            PaywallView(isInternalOpen: true) {
                isShowPayWall = false
            } purchaseCompletSuccessfullyAction: {
                isShowPayWall = false
            }
            .background {
                Image(.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            }
        }
    }
}
