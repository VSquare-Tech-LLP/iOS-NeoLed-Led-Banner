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
                .frame(width: ScaleUtility.scaledValue(173.88), height: ScaleUtility.scaledValue(150))
                .padding(.top,ScaleUtility.scaledSpacing(87))
                .offset(x: ScaleUtility.scaledSpacing(10))
          
                HStack(spacing: 0) {
                    Button {
                        impactfeedback.impactOccurred()
                        restoreAction()
                    } label: {
                        Text("Restore")
                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(10)))
                            .foregroundStyle(.primaryApp)
                            .padding(.horizontal, ScaleUtility.scaledSpacing(12))
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
                .padding(.horizontal,ScaleUtility.scaledSpacing(15))
                
          
                
            
            
            
            
        }
        .ignoresSafeArea(.all)

    }
}


struct PaywallProFeatureView: View {
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(20)) {
            
            Image(.neoledPro)
                .resizable()
                .frame(width: ScaleUtility.scaledValue(225),height: ScaleUtility.scaledValue(47))
            
            
            VStack(alignment: .leading,spacing: ScaleUtility.scaledSpacing(10)) {
                ForEach(PremiumFeature.allCases, id: \.title) { feature in
                    HStack(spacing: ScaleUtility.scaledSpacing(8)) {
                        Image(feature.image)
                            .resizeImage()
                            .frame(width: 26 * widthRatio, height: 26 * heightRatio)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(feature.title)
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(14)))
                                .kerning(0.2)
                                .foregroundStyle(Color.primaryApp)
                  
                        }
                     }
                }
            }
        }
    }
}


struct PaywallPlanView: View {
    
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Binding var selectedPlan: SubscriptionPlan
    let plan: SubscriptionPlan


    let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        if let product = purchaseManager.products.first(where: { $0.id == plan.productId }) {
            VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                Button {
                    withAnimation {
                        selectionFeedback.selectionChanged()
                        selectedPlan = plan
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading,spacing: ScaleUtility.scaledSpacing(5)) {
                            Text(plan.planName.uppercased())
                                .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(14)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.primaryApp)
                            
                            
                            Text(displayPriceText(for: plan, product: product))
                                .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(15)))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.primaryApp.opacity(0.8))
                        }
                        
                        
                        Spacer()
                        
                        if plan.planName == "Yearly" && remoteConfigManager.isApproved {
                            
                            HStack(spacing: ScaleUtility.scaledSpacing(20)) {
                                Rectangle()
                                    .foregroundColor(Color.primaryApp.opacity(0.2))
                                    .frame(maxWidth: .infinity)
                                    .frame(width: ScaleUtility.scaledValue(1.5), height: ScaleUtility.scaledValue(40))
                                
                                Text("Save\n 85%")
                                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(16)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.primaryApp)
                                
                                
                            }
                        }
                    }
                    .padding(.top,ScaleUtility.scaledSpacing(10))
                    .padding(.bottom,ScaleUtility.scaledSpacing(10))
                    .padding(.leading,ScaleUtility.scaledSpacing(18))
                    .padding(.trailing,ScaleUtility.scaledSpacing(20))
                    .frame(height: ScaleUtility.scaledValue(70))
                    .frame(maxWidth: .infinity)
                    .background {
                        if selectedPlan != plan {
                           Color.clear
                        }
                        else {
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 1, green: 0.87, blue: 0.03), location: 0.00),
                                    Gradient.Stop(color: .black, location: 0.69),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: -0.57),
                                endPoint: UnitPoint(x: 0.5, y: 0.84)
                            )
                        }
                        
                    }
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedPlan == plan ? Color.accent : Color.primaryApp.opacity(0.5),
                                    lineWidth: selectedPlan == plan ? 2 : 1)
                    )
                    .padding(.leading,ScaleUtility.scaledSpacing(14))
                    .padding(.trailing,ScaleUtility.scaledSpacing(16))
                }
            }
        }
    }
    func displayPriceText(for plan: SubscriptionPlan, product: Product) -> String {
        switch plan {
          case .weekly:
            return  product.displayPrice + " / week"
          case .yearly:
            let price = product.price
              if remoteConfigManager.isApproved {
              let weekPrice = price / 52
              return weekPrice.formatted(product.priceFormatStyle) + " / week"
            } else {
              return product.displayPrice + " / year"
            }
         case .yearlygift:
            return product.displayPrice + " / year"

        }
    }
}



struct PaywallBottmView: View{
    let isProcess: Bool
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Binding var selectedPlan: SubscriptionPlan
    let tryForFreeAction: () -> Void
    @Environment(\.openURL) var openURL
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(10)) {
            
            if let product = purchaseManager.products.first(where: { $0.id == selectedPlan.productId }) {
                Text("Auto-Renews at \(displayPriceText(for: selectedPlan, product: product))")
                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(12)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primaryApp)
            }
            
            Button {
                impactFeedback.impactOccurred()
                tryForFreeAction()
            } label: {
                if isProcess {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(Color.secondaryApp)
                }
                else {
                    Text("Continue")
                        .font(FontManager.bricolageGrotesqueSemiBoldFont(size: .scaledFontSize(14)))
                        .foregroundColor(Color.secondaryApp)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: ScaleUtility.scaledValue(42))
            .frame(maxWidth: .infinity)
            .background(Color.accent)
            .cornerRadius(10)
            .padding(.horizontal,ScaleUtility.scaledSpacing(20))

            if let product = purchaseManager.products.first(where: { $0.id == selectedPlan.productId }) {
                Text(displayPriceText(for: selectedPlan, product: product))
                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(16)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primaryApp)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            

            HStack {
                
                HStack(spacing: ScaleUtility.scaledSpacing(8)) {
                    
                    Button {
                        impactFeedback.impactOccurred()
                        openURL(URL(string: AppConstant.privacyURL)!)
                    } label: {
                        Text("Privacy Policy")
                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(10)))
                            .foregroundColor(Color.primaryApp.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
             
                    Text(" | ")
                        .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(10)))
                        .foregroundColor(Color.primaryApp.opacity(0.3))
                    
                    Button {
                        impactFeedback.impactOccurred()
                        openURL(URL(string: AppConstant.termsAndConditionURL)!)
                    } label: {
                        Text("Terms of use")
                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(10)))
                            .foregroundColor(Color.primaryApp.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    
                }
                
                Spacer()
                
                Text("Cancel Anytime.")
                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(10)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primaryApp.opacity(0.5))
                
                
            }
            .padding(.horizontal, ScaleUtility.scaledSpacing(20))
            
         
        }
    }
    
    func displayPriceText(for plan: SubscriptionPlan, product: Product) -> String {
        switch plan {
          case .weekly:
            return  product.displayPrice + " / Week"
          case .yearly:
            return  product.displayPrice + " / Year"
         case .yearlygift:
            return product.displayPrice + " / Year"
        }
    }
}
