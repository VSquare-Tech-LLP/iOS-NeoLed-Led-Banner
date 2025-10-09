//
//  GiftPaywallCollectView.swift
//  iOS-Word-Vibe
//
//  Created by Purvi Sancheti on 26/07/25.
//

import Foundation
import SwiftUI

struct GiftPaywallCollectView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var timerManager: TimerManager
    let closeGiftSheet: () -> Void
    let purchaseConfirm: () -> Void
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    

    var body: some View {
        
        if let product = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.yearlygift.productId }),
           let lifetimePlan = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.yearly.productId }) {
            
            let discountPrice = product.displayPrice
            let originalPrice = lifetimePlan.displayPrice
            
            //Extract numerical value from the prices
            let discountedPriceValue = Double(discountPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
            let originalPriceValue = Double(originalPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
            
            //calculate the discount percentage
            let discountPercentage = originalPriceValue > 0 ? round((originalPriceValue - discountedPriceValue) / originalPriceValue * 100) : 0
            
            ZStack(alignment: .topTrailing) {
                
                Color.secondaryApp.ignoresSafeArea(.all)
                
                VStack {
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(30)) {
                        
                        VStack(spacing: ScaleUtility.scaledSpacing(6)) {
                            
                            if discountPercentage == 100 {
                                Text("Free")
                                    .font(FontManager.bricolageGrotesqueExtraBold(size: .scaledFontSize(35)))
                                    .foregroundColor(Color.primaryApp)
                            } else {
                                Text("\(Int(discountPercentage))% OFF")
                                    .font(FontManager.bricolageGrotesqueExtraBold(size: .scaledFontSize(35)))
                                    .foregroundColor(Color.primaryApp)
                                
                                
                            }
                            
                            Text("On yearly plan")
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(18)))
                                .foregroundStyle(Color.accent)
                            
                            
                        }
                        .padding(.top,ScaleUtility.scaledSpacing(30))
                        
                        
                        HStack(spacing: ScaleUtility.scaledValue(6)) {
                            if timerManager.isExpired {
                                Text("Offer expired")
                                    .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(16)))
                                    .foregroundColor(Color.primaryApp)
                                  
                            }
                          
                                Text("Expires in")
                                    .font(FontManager.bricolageGrotesqueSemiBoldFont(size: .scaledFontSize(16)))
                                    .foregroundColor(Color.primaryApp  .opacity(0.4))
                                   
                                
                                Text("\(timerManager.hours) : \(String(format: "%02d", timerManager.minutes)) : \(String(format: "%02d", timerManager.seconds))")
                                  .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(16)))
                                  .foregroundColor(Color(red: 1, green: 0.38, blue: 0.38))
                              
                            
                        }
                        
                        
                        VStack(spacing: 0) {
                            
                            VStack(alignment: .leading,spacing: ScaleUtility.scaledSpacing(15)) {
                                Text("Limited time offer")
                                    .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(24)))
                                    .foregroundColor(Color.primaryApp)
                                
                                VStack(spacing: ScaleUtility.scaledSpacing(6)) {
                                    
                                    Text("Just \(discountPrice)")
                                        .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(32)))
                                        .foregroundColor(Color.primaryApp)
                                        .frame(maxWidth: .infinity, alignment: .topLeading)
                                    
                                    Text("Costs less than a coffee!")
                                        .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(12)))
                                        .foregroundColor(Color.primaryApp.opacity(0.5))
                                        .frame(maxWidth: .infinity, alignment: .topLeading)
                                     
                                }
                                 
                            }
                            
                            HStack {
                                
                                Spacer()
                                
                                Image(.tagIcon)
                                  .resizable()
                                  .frame(width: ScaleUtility.scaledValue(62), height: ScaleUtility.scaledValue(62))
                             
                            }
                            
                        }
                        .padding(.top, ScaleUtility.scaledSpacing(25))
                        .padding(.leading, ScaleUtility.scaledSpacing(25))
                        .padding(.trailing, ScaleUtility.scaledSpacing(15))
                        .padding(.bottom, ScaleUtility.scaledSpacing(15))
                        .background(Color.appGiftBox)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .inset(by: 0.5)
                                .stroke(.primaryApp.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, ScaleUtility.scaledSpacing(25))
                    }
                    
                    Spacer()
                    
                    Button {
                        impactfeedback.impactOccurred()
                        Task {
                            
                            do {
                                try await purchaseManager.purchase(product)
                                if purchaseManager.hasPro {
                                    purchaseConfirm()
                                    notificationfeedback.notificationOccurred(.success)
                                    AnalyticsManager.shared.log(.giftScreenPlanPurchase)
                                }
                            } catch {
                                notificationfeedback.notificationOccurred(.error)
                                print("Purchase failed: \(error)")
                                purchaseManager.isInProgress = false
                                purchaseManager.alertMessage = "Purchase Failed! Please try again or check your payment method."
                                purchaseManager.showAlert = true
                            }
                        }
                    } label: {
                        if purchaseManager.isInProgress {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .tint(.white)
                           
                        }
                        else {
                            Text("Claim Offer Now!")
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(14)))
                                .kerning(0.16)
                                .foregroundColor(Color.secondaryApp)
                                .frame(maxWidth: .infinity)
                        }
               
                           
                    }
                    .padding(.vertical, ScaleUtility.scaledSpacing(11))
                    .frame(maxWidth: .infinity)
                    .background(Color.accent)
                    .cornerRadius(10)
                    .opacity(purchaseManager.isInProgress ? 0.5 : 1)
                    .disabled(purchaseManager.isInProgress || timerManager.isExpired)
                    .padding(.horizontal, ScaleUtility.scaledSpacing(52))
                    .padding(.bottom, ScaleUtility.scaledSpacing(21))
                    
        
                    
                }
                .alert(isPresented: $purchaseManager.showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(purchaseManager.alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                Button {
                    impactfeedback.impactOccurred()
                    closeGiftSheet()
                } label: {
                    Image(.crossIcon2)
                        .resizable()
                        .frame(width: ScaleUtility.scaledValue(23), height: ScaleUtility.scaledValue(23))
                        .padding(.trailing,ScaleUtility.scaledSpacing(20))
                        .padding(.top,ScaleUtility.scaledSpacing(25))
                        .opacity(0.7)
                }

            }
            

        }
    }
}
