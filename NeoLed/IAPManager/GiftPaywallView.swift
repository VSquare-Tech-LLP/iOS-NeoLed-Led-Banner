//
//  GiftView.swift
//  iOS-Word-Vibe
//
//  Created by Darsh Viroja on 20/05/25.
//

import Foundation
import SwiftUI

struct GiftPaywallView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Binding var isCollectGift: Bool
    @State var plan = SubscriptionPlan.yearlygift
    let closeGift: () -> Void
    let giftPurchaseComplete: () -> Void
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    
    var body: some View {
        
        ZStack {
            Image(.giftScreenBg)
                .resizable()
                .frame(maxWidth:.infinity,maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            VStack {
                
                VStack {
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(111.34)) {
                        
                        
                        
                        VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                            
                            HStack {
                                
                                Spacer()
                                
                            
                                Image(.crossIcon2)
                                  .resizable()
                                  .frame(width: ScaleUtility.scaledValue(23), height: ScaleUtility.scaledValue(23))
                                  .onTapGesture {
//                                      AnalyticsManager.shared.log(.giftScreenXClicked)
                                      withAnimation(.easeOut(duration: 0.1)) {
                                          closeGift()
                                          
                                      }
                                  }
                                
                            }
                            .padding(.trailing,ScaleUtility.scaledSpacing(20))
                            
                            Text("Congratulations!!")
                                .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(25)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.accent)
                                .offset(y:-ScaleUtility.scaledSpacing(8))
                            
                            Text("We have a\n gift for\n you!")
                                .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(45)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.primaryApp)
                        }
                        .offset(y:ScaleUtility.scaledSpacing(-27))
                        
                        
                        
                        
                        VStack(spacing: isIPad ?  ScaleUtility.scaledSpacing(220.5) :  ScaleUtility.scaledSpacing(120.5)) {
                            
           
                                Image(.giftIcon)
                                .resizable()
                                .frame(width: isIPad ? 240.25439 :  140.25439, height: isIPad ? 250.26335 : 150.26335)
                            
                            

                                
                                Button {
                                    self.isCollectGift = true
                                    impactfeedback.impactOccurred()
                                    
                                } label: {
                                    
                                    Text("Collect Gift")
                                      .font(FontManager.bricolageGrotesqueSemiBoldFont(size: .scaledFontSize(14)))
                                      .kerning(0.14)
                                      .foregroundColor(Color.secondaryApp)
                                      .frame(maxWidth: .infinity)
                                      .frame(height: 42)
                                      .background(Color.accent)
                                      .cornerRadius(10)
                     
                                }
                                .padding(.horizontal, ScaleUtility.scaledValue(52))
                                
                                
                            
                        }
                        
                    }
                    .padding(.top,ScaleUtility.scaledSpacing(50))
                    
                    
                    Spacer()
                }
                
            }
        }
        .blur(radius: isCollectGift ? 25 : 0 )
        .sheet(isPresented: $isCollectGift) {
        
        
                GiftPaywallCollectView(
                    closeGiftSheet: {
                        self.isCollectGift = false
//                        AnalyticsManager.shared.log(.giftBottomSheetXClicked)
                    }, purchaseConfirm: giftPurchaseComplete)
                .frame(height: isIPad ? ScaleUtility.scaledValue(750) : ScaleUtility.scaledValue(520) )
                .background(Color.secondaryApp)
                .presentationDetents([.height( isIPad ? ScaleUtility.scaledValue(750) : ScaleUtility.scaledValue(520))])
                .presentationBackground(Color.secondaryApp)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
        }
    }
}
