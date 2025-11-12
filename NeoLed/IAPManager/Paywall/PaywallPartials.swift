//
//  PaywallPartials.swift
//  EveCraft
//
//  Created by Purvi Sancheti on 02/09/25.
//

import Foundation
import SwiftUI
import StoreKit

struct PaywallHeaderView: View {
    
    @Binding var isShowCloseButton: Bool
    @Binding var isDisable: Bool
    let restoreAction: () -> Void
    let closeAction: () -> Void
    var isInternalOpen: Bool = false
    
    var delayCloseButton: Bool = false
    var delaySeconds: Double
    
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    
    @State private var isRestorePressed = false
    @State private var isCrossPressed = false
    
    @State private var isCountdownFinished = false   // NEW
    @State private var hasStartedCountdown = false   // NEW
    
    @State private var closeProgress: CGFloat = 0
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Image(.dimondIcon)
                .resizable()
                .frame(width: isIPad ? ScaleUtility.scaledValue(260) : ScaleUtility.scaledValue(173.88),
                       height:  isIPad ? ScaleUtility.scaledValue(225) : ScaleUtility.scaledValue(150))
                .padding(.top,ScaleUtility.scaledSpacing(87))
           
          

                HStack(spacing: 0) {
                    Button {
                        impactfeedback.impactOccurred()
                        restoreAction()
                    } label: {
                        Text("Restore")
                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(10)))
                            .foregroundStyle(.primaryApp)
                            .padding(.horizontal, ScaleUtility.scaledSpacing(8))
                            .padding(.vertical, ScaleUtility.scaledSpacing(6))
                            .background(Color.primaryApp.opacity(0.3))
                            .cornerRadius(500)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(isRestorePressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isRestorePressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isRestorePressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isRestorePressed = false
                                }
                            }
                    )
                    
                    
                    
                    Spacer()
                    
                    Button {
                        impactfeedback.impactOccurred()
                        closeAction()
                    } label: {
                        Image(.crossIcon1)
                            .resizable()
                            .frame(width: ScaleUtility.scaledValue(15.24138), height: ScaleUtility.scaledValue(15.24138))
                            .padding(.all,ScaleUtility.scaledSpacing(5.38))
                            .overlay(
                                ZStack {
                                    // Base ring
                                    Circle()
                                        .stroke(
                                            delayCloseButton ? Color.secondaryApp.opacity(0.2) : .primaryApp,
                                            lineWidth: 2
                                        )
                                    
                                    // Animated white progress ring (only when delaying)
                                    if delayCloseButton {
                                        Circle()
                                            .trim(from: 0, to: closeProgress)
                                            .stroke(Color.primaryApp, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                            .rotationEffect(.degrees(-90)) // start at top
                                    }
                                }
                            )
                    }
                    .disabled(isDisable || (delayCloseButton && closeProgress < 1))
                    .buttonStyle(PlainButtonStyle())
                    .opacity(isShowCloseButton ? 1 : 0)
                    .scaleEffect(isCrossPressed ? 0.95 : 1.0)
                    .disabled(isDisable || (delayCloseButton && !isCountdownFinished)) // CHANGED
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isCrossPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isCrossPressed = false
                                }
                            }
                        
                    )
                    .onAppear {
                        guard !hasStartedCountdown else { return }  // prevent multiple starts
                        hasStartedCountdown = true
                        
                        if delayCloseButton {
                            isCountdownFinished = false
                            closeProgress = 0
                            
                            // Animate the ring visually
                            withAnimation(.linear(duration: delaySeconds)) {
                                closeProgress = 1
                            }
                            
                            // Flip the gate AFTER the duration
                            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
                                withAnimation { isCountdownFinished = true }
                            }
                        } else {
                            closeProgress = 1
                            isCountdownFinished = true
                        }
                    }
                    
                }
                .frame(height: 24 * heightRatio)
                .disabled(isDisable || (delayCloseButton && closeProgress < 1))
                .padding(.top,ScaleUtility.scaledSpacing(55))
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                
        }
        .ignoresSafeArea(.all)

    }
}


struct PaywallProFeatureView: View {
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(17)) {
            
            Image(.neoledPro)
                .resizable()
                .frame(width: ScaleUtility.scaledValue(225),height: ScaleUtility.scaledValue(47))
            
            
            
            VStack(alignment: .leading, spacing: isIPad ? ScaleUtility.scaledSpacing(20) : ScaleUtility.scaledSpacing(10)) {
                ForEach(Array(PremiumFeature.allCases.enumerated()), id: \.element.title) { index, feature in
                    PaywallPremiumFeatureContainerView(feature: feature, index: index)
                }
            }
        }
    }
}


struct PaywallPremiumFeatureContainerView: View {
    let feature: PremiumFeature
    let index: Int
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: ScaleUtility.scaledSpacing(8)) {
            Image(feature.image)
                .resizeImage()
                .frame(width: 22 * widthRatio, height: 22 * heightRatio)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(feature.title)
                    .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(14)))
                    .foregroundColor(Color.primaryApp)
      
            }
         }
         .opacity(isVisible ? 1 : 0)
         .offset(x: isVisible ? 0 : -20)
         .onAppear {
             withAnimation(.easeOut(duration: 0.5).delay(Double(index) * 0.50)) {
                 isVisible = true
             }
         }
     }
}



struct SubscriptionOption: View {
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Binding var selectedPlan: SubscriptionPlan
    let plan: SubscriptionPlan


    let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        if  let product = purchaseManager.products.first(where: { $0.id == plan.rawValue }) {
        Button {
            withAnimation {
                selectionFeedback.selectionChanged()
                selectedPlan = plan
            }
        } label: {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity)
                .frame(height: isIPad ?  ScaleUtility.scaledValue(231) : ScaleUtility.scaledValue(154))
                .cornerRadius(16)
                .overlay {
                    ZStack(alignment: .center) {
                        
                        ZStack(alignment: .bottom) {
                            
                            VStack(spacing: 0)
                            {
                                
                                VStack(spacing: ScaleUtility.scaledSpacing(0))
                                {
                                    Text(plan.planName.capitalized)
                                        .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(16)))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color.primaryApp)
                                        .padding(.top, ScaleUtility.scaledSpacing(12))
                                    
                                    Spacer()
                                    
                                    VStack(spacing: ScaleUtility.scaledSpacing(5)) {
                                        
                                        Text(displayPriceText(for: plan, product: product))
                                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(20)))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(Color.primaryApp)
                                        
                                        
                                        Text(planSubtitle)
                                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(14)))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(Color.primaryApp)
                                    }
                                    .padding(.bottom, ScaleUtility.scaledSpacing(11))
                                    
                                    
                                }
                                
                            }
                            .zIndex(1)
                            
                            Rectangle()
                                .fill(selectedPlan == plan ? Color.accent.opacity(0.5) : Color.appDarkGrey)
                                .frame(height: isIPad ? ScaleUtility.scaledValue(130) : ScaleUtility.scaledValue(87))
                                .frame(maxWidth:.infinity)
                             
                            
                        }
                        
                        if plan.planName != "Weekly" {
                            
                            Text(trialPeriodText(for: plan, product: product))
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(10)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(selectedPlan == plan ? Color.secondaryApp : Color.primaryApp)
                                .background {
                                    Rectangle()
                                        .fill(selectedPlan == plan ? Color.accent : Color.appLightGrey)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(20))
                                        .frame(width:  isIPad ? ScaleUtility.scaledValue(140) : ScaleUtility.scaledValue(93))
                                        .cornerRadius(20)
                                }
                                .padding(.bottom, ScaleUtility.scaledSpacing(18))
                        }
                        
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .background(
                RoundedRectangle(cornerRadius: 14) // Increase for a more rounded look
                    .fill(Color.dividerBg)
                  
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke( selectedPlan == plan ? Color.accent : .primaryApp.opacity(0.2), lineWidth: 1)
            )
         }
      }
    }
    
    
    func displayPriceText(for plan: SubscriptionPlan, product: Product) -> String {
        switch plan {
        case .weekly:
          return product.displayPrice
        case .yearly:
          let price = product.price
            if remoteConfigManager.isApproved {
            let weekPrice = price / 52
            return weekPrice.formatted(product.priceFormatStyle)
          } else {
            return product.displayPrice
          }
        case .lifetime:
          return product.displayPrice
        case .gift:
            return product.displayPrice
        }
      }
    
    var planSubtitle: String {
        switch plan {
        case .weekly:
          return "Per Week"
        case .yearly:
          if remoteConfigManager.isApproved {
            return "Per Year"
          } else {
            return "Per Year"
          }
        case .lifetime:
          return "One Time"
        case .gift:
          return "One Time"

        }
      }
    
    func trialPeriodText(for plan: SubscriptionPlan, product: Product) -> String {
        let trialPeriod = product.subscription?.introductoryOffer?.period
         
        switch plan {
        case .weekly:
          if let trialPeriod = trialPeriod {
            return "\(trialPeriod) Free Trial"
          } else {
            return "Start for Cheap"
          }
        case .yearly:
          if let trialPeriod = trialPeriod {
            return "\(trialPeriod) Free Trial"
          } else {
            return "For Full Year"
          }
        case .lifetime:
          return "No Renewals"
            
        case .gift:
          return "Yours forever, No subscription needed!"

        }
      }
    
}





//MARK: - Paywall Bottom View



struct PaywallBottomView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @Environment(\.openURL) var openURL
    let isProcess: Bool
    let isWeekly: Bool
    let once: Bool
    let isYearly: Bool
    let tryForFreeAction: () -> Void
    let restoreAction: () -> Void

    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    let plan: SubscriptionPlan
    
    @State private var isPressed = false
 
    var body: some View {
        
        VStack(spacing: 0) {
            VStack(spacing: isIPad ? ScaleUtility.scaledSpacing(25) : ScaleUtility.scaledSpacing(20)) {
                
                VStack(spacing: isIPad ? ScaleUtility.scaledSpacing(20) :  ScaleUtility.scaledSpacing(15)) {
                    
                    
                    if let product = purchaseManager.products.first(where: { $0.id == plan.rawValue }) {
                        
                        VStack(spacing:  ScaleUtility.scaledSpacing(9)) {
                            
                            Text(trialPeriodText(for: plan, product: product))
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(12)))
                                .foregroundColor(Color.primaryApp.opacity(0.5))
                                .frame(maxWidth:.infinity)
                            
                        }
                    }
                    
                    
                    Button {
                        tryForFreeAction()
                        impactFeedback.impactOccurred()
                    
                    } label: {
                        
                        HStack {
                            if isProcess {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .tint(.dividerBg)
                            }
                            else
                            {
                                HStack(spacing: ScaleUtility.scaledSpacing(5)) {
                                    
                                    if let product = purchaseManager.products.first {
                                        let zeroDecimal = Decimal(0.0)
                                        
                                        Text(isYearly && remoteConfigManager.freeTrialPlan ? "Continue For Free" : "Continue" )
                                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(16)))
                                            .kerning(0.48)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(Color.dividerBg)
                                            .animation(.easeInOut(duration: 0.2), value: isYearly)
                                        
                                        
                                    } else {
                                        Text("Continue")
                                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(16)))
                                            .foregroundColor(Color.dividerBg)
                                            .kerning(0.48)
                                            .multilineTextAlignment(.center)
                                        
                                    }
                                    
                                    Image(.rightIcon2)
                                        .resizable()
                                        .frame(width: ScaleUtility.scaledValue(18), height:  ScaleUtility.scaledValue(18))
                                    
                                    
                                    
                                }
                                .frame(width: isIPad  ? ScaleUtility.scaledValue(295) : ScaleUtility.scaledValue(195))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: ScaleUtility.scaledValue(52))
                        .background(.accent)
                        .cornerRadius(10)
                        .opacity(isProcess ? 0.5 : 1)
                        .disabled(isProcess)
                        .contentShape(Rectangle())
                        .shadow(
                            color: isPressed ? Color.black.opacity(0.1) : Color.black.opacity(0.3),
                            radius: isPressed ? 4 : 10,
                            x: 0,
                            y: isPressed ? 2 : 6
                        )
                        .scaleEffect(isPressed ? 0.96 : 1.0)
                        .offset(y: isPressed ? 2 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                        .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                        .zIndex(1)
                 
                    }
                    .buttonStyle(PressButtonStyle(isPressed: $isPressed))
               
                    
                    if isYearly  {
                        
                        if let product = purchaseManager.products.first(where: { $0.id == plan.rawValue }) {
                            Text(buttonTopTitle(for: plan, product: product))
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(12)))
                                .foregroundColor(Color.primaryApp)
                                .frame(maxWidth:.infinity)
                        }
                    }
                    
                }
           
                    
                    HStack(spacing: ScaleUtility.scaledSpacing(6)) {
 
                        Button {
                            impactFeedback.impactOccurred()
                            openURL(URL(string: AppConstant.privacyURL)!)
                        } label: {
                            Text("Privacy policy")
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(10)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.primaryApp.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                        
                        Text("|")
                            .foregroundColor(Color.primaryApp)
                            .opacity(0.5)
                            .font(FontManager.bricolageGrotesqueMediumFont(size:.scaledFontSize(10)))
                          
                        
                        Button {
                            impactFeedback.impactOccurred()
                            openURL(URL(string: AppConstant.termsAndConditionURL)!)
                        } label: {
                            Text("Terms of use")
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(10)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.primaryApp.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                       
                    }
              
            }
        }
 
//        Text("Premium membership unlocks all the packs and content. This is an auto-renew subscription. Subscriptions will automatically renew and you will be charged for renewal within 24 hours prior to the end of each period unless auto-renew is turned off at least 24-hours before the end of each period. You can manage your subscription settings and auto-renewal may be turned off by going to Apple ID Account Settings after purchase.")
//            .font(FontManager.hankenGroteskregular(size: .scaledFontSize(8)))
//            .multilineTextAlignment(.center)
//            .frame(maxWidth: UIScreen.main.bounds.width - ScaleUtility.scaledValue(40))
//            .fixedSize(horizontal: false, vertical: true)
//            .padding(.horizontal, ScaleUtility.scaledSpacing(10))
//            .foregroundColor(Color.appText)
//            .opacity(0.5)
//            .padding(.top, ScaleUtility.scaledSpacing(11))

    }

    func displayPriceText(for plan: SubscriptionPlan, product: Product) -> String {
        switch plan {
        case .weekly:
          return product.displayPrice
        case .yearly:
            return product.displayPrice
        case .lifetime:
          return product.displayPrice
        case .gift:
          return product.displayPrice

        }
      }
    
    func trialPeriodText(for plan: SubscriptionPlan, product: Product) -> String {
        let trialPeriod = product.subscription?.introductoryOffer?.period
         
        switch plan {
        case .weekly:
          if let trialPeriod = trialPeriod {
            return "Free for \(trialPeriod), Auto renews at \(product.displayPrice) / Week "
          } else {
            return "Auto renews at \(product.displayPrice) / Week"
          }
        case .yearly:
          if let trialPeriod = trialPeriod {
            return "Free for \(trialPeriod), Auto renews at \(product.displayPrice) / Year "
          } else {
            return "Hassle-Free Auto Renewal"
          }
        case .lifetime:
          return "🔥 One time payment only"
            
        case .gift:
          return "Yours forever, No subscription needed!"
 
        }
      }
    
    func buttonTopTitle(for plan: SubscriptionPlan, product: Product) -> String {
        let trialPeriod = product.subscription?.introductoryOffer?.period
         
        switch plan {
        case .weekly:
          if let _ = trialPeriod {
            return "🔥 No Payment Now"
          } else {
            return "⚡️ Get Started for Cheap"
          }
        case .yearly:
          if let _ = trialPeriod {
            return "🔥 No Payment Now"
          } else {
            return "Secured by Apple. Cancel Anytime."
          }
        case .lifetime:
          return "✨ Pay Once, Yours Forever"
            
        case .gift:
          return "Yours forever, No subscription needed!"

        }
      }
    
}
