//
//  Life.swift
//  EveCraft
//
//  Created by Purvi Sancheti on 02/09/25.
//

import Foundation

import SwiftUI


struct LifeTimeGiftOfferBannerView: View {
    
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var userDefaultSetting: UserSettings
 
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        
        if let product = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.yearlygift.productId }),
           let lifetimePlan = purchaseManager.products.first(where: { $0.id == SubscriptionPlan.yearly.productId }) {
            
            let discountPrice = product.displayPrice
            let originalPrice = lifetimePlan.displayPrice
            
            let discountedPriceValue = Double(discountPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
            let originalPriceValue = Double(originalPrice.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
            
            let discountPercentage = originalPriceValue > 0 ? round((originalPriceValue - discountedPriceValue) / originalPriceValue * 100) : 0
            
            HStack(spacing: ScaleUtility.scaledSpacing(12)) {
                VStack(alignment: .leading, spacing: ScaleUtility.scaledSpacing(4)) {
                    HStack(alignment: .bottom, spacing: ScaleUtility.scaledSpacing(7)) {
                        Text("\(Int(discountPercentage))%")
                            .font(FontManager.bricolageGrotesqueExtraBold(size: .scaledFontSize(35)))
                            .foregroundColor(Color.primaryApp)
                        Text("OFF")
                            .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(14)))
                            .foregroundColor(Color.primaryApp)
                            .offset(y:  ScaleUtility.scaledSpacing(-2))
                    }

                    Text("On Yearly Plan")
                        .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(14)))
                        .foregroundColor(Color.primaryApp)
                        .offset(x:ScaleUtility.scaledSpacing(2),y:ScaleUtility.scaledSpacing(3))
                }
                .padding(.leading, ScaleUtility.scaledSpacing(10))
                Spacer()
                VStack(spacing:  ScaleUtility.scaledSpacing(0)) {
                    Text("\(timerManager.hours) : \(String(format: "%02d", timerManager.minutes)) : \(String(format: "%02d", timerManager.seconds))")
                        .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(15.53623)))
                        .foregroundColor(Color.primaryApp)
                        .frame(width: isIPad ? ScaleUtility.scaledValue(130) : 96 * widthRatio, height: ScaleUtility.scaledValue(12))
                        .padding(.vertical, ScaleUtility.scaledValue(10))
                        .padding(.horizontal, ScaleUtility.scaledValue(4))
                        .background {
                            UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(bottomLeading: ScaleUtility.scaledSpacing(12), bottomTrailing: ScaleUtility.scaledSpacing(12)),
                                style: .circular)
                            .fill(Color.secondaryApp.opacity(0.6))
                        }
                        .padding(.trailing, ScaleUtility.scaledSpacing(21))
                        .padding(.bottom, isIPad ? ScaleUtility.scaledSpacing(15) : 0 )
                        .opacity(remoteConfigManager.showLifeTimeBannerAtHome ? 1 : 0)
                    Spacer()
                    
                    Button {
                        print("clicked")
                        impactfeedback.impactOccurred()
                        Task {
                            do {
                                try await purchaseManager.purchase(product)
                                AnalyticsManager.shared.log(.giftBannerPlanPurchase)
                                
                            } catch {
                                print("Purchase failed: \(error)")
                                purchaseManager.isInProgress = false
                                purchaseManager.alertMessage = "Purchase Failed! Please try again or check your payment method."
                                purchaseManager.showAlert = true
                            }
                        }
                    }
                    label: {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primaryApp)
                            .frame(width: isIPad ?  ScaleUtility.scaledValue(156.32716)  : ScaleUtility.scaledValue(116.32716)  , height: ScaleUtility.scaledValue(35))
                            .overlay {
                                if purchaseManager.isInProgress {
                                    ProgressView()
                                        .tint(Color.primaryApp)
                                }
                                else{
                                    HStack(spacing: 0) {
                                        Text(originalPrice)
                                            .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(10)))
                                            .foregroundColor(.secondaryApp)
                                            .opacity(0.5)
                                            .strikethrough()
                                        
                                        Text(discountPrice)
                                            .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(14)))
                                            .foregroundColor(.secondaryApp)
                                            .padding(.leading, ScaleUtility.scaledSpacing(5))
                                        
                                        Image(.rightArrowIcon2)
                                            .resizable()
                                            .frame(width: ScaleUtility.scaledValue(15.53623), height: ScaleUtility.scaledValue(15.53623))
                                            .padding(.leading, ScaleUtility.scaledSpacing(5))
                                    }
                                }
                            }
                            .zIndex(1)
                        
                    }
                    .zIndex(1)
                    .disabled(purchaseManager.isInProgress)
                    .padding(.bottom, isIPad ?  ScaleUtility.scaledSpacing(10)  : ScaleUtility.scaledSpacing(16))
                    .padding(.trailing, ScaleUtility.scaledSpacing(23))
                    .offset(x:ScaleUtility.scaledSpacing(3),y:ScaleUtility.scaledSpacing(3))
                }
            }
            .alert(isPresented: $purchaseManager.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(purchaseManager.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .frame(maxWidth:.infinity)
            .frame(height: isIPad ?  ScaleUtility.scaledValue(121) * ipadHeightRatio  : ScaleUtility.scaledValue(101) )
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 9.71014)
                        .frame(height: isIPad ?  ScaleUtility.scaledValue(121) * ipadHeightRatio  : ScaleUtility.scaledValue(101))
                        .foregroundColor(Color.clear)
                        .background {
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.47, green: 0.39, blue: 0.02), location: 0.44),
                                    Gradient.Stop(color: Color(red: 0.04, green: 0.04, blue: 0.04), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: -0.21),
                                endPoint: UnitPoint(x: 0.5, y: 1.11)
                            )
                            .frame(height: isIPad ?  ScaleUtility.scaledValue(121) * ipadHeightRatio  : ScaleUtility.scaledValue(101))
                            .clipShape(RoundedRectangle(cornerRadius: 9.71014))
                            .contentShape(RoundedRectangle(cornerRadius: 9.71014))
                        }
                 
                    
                    Image(.ribbonIcon)
                        .resizable()
                        .scaledToFill()
                        .frame(height: isIPad ?  ScaleUtility.scaledValue(124) * ipadHeightRatio  : ScaleUtility.scaledValue(104))
                        .clipShape(RoundedRectangle(cornerRadius: 9.71014))
                        .contentShape(RoundedRectangle(cornerRadius: 9.71014))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 9.71014)
                    .stroke(Color.primaryApp.opacity(0.3), lineWidth: 1)
               }
            .cornerRadius(9.71014)
            .padding(.horizontal, ScaleUtility.scaledSpacing(20))
           
        }
    }
}

