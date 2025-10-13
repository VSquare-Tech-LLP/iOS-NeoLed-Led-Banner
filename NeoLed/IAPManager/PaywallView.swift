//
//  PaywallView.swift
//  EveCraft
//
//  Created by Purvi Sancheti on 02/09/25.
//

import Foundation
import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var userSettings = UserSettings()
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    
    @State var selectedPlan = SubscriptionPlan.yearly
    @State var isShowCloseButton: Bool = false
    var isInternalOpen: Bool = false
    let closePayAll: () -> Void
    let purchaseCompletSuccessfullyAction: () -> Void

    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        VStack(spacing:0) {
            
            VStack(spacing: ScaleUtility.scaledSpacing(25)) {
                
                PaywallHeaderView(
                    isShowCloseButton: $isShowCloseButton,
                    isDisable: $purchaseManager.isInProgress,
                    restoreAction: {
                        purchaseManager.isInProgress = false
                                AnalyticsManager.shared.log(isInternalOpen ? .internalPaywallRestoreClicked : .firstPaywallRestoreClicked)
                        Task {
                            defer {
                                purchaseManager.isInProgress = false
                            }
                            do {
                                notificationfeedback.notificationOccurred(.success)
                                purchaseManager.isInProgress = true
                                try await AppStore.sync()
                                await purchaseManager.updatePurchaseProducts(isRestore: true)
                                AnalyticsManager.shared.log(isInternalOpen ? .internalPaywallPlanRestore(PlanDetails(planName: userSettings.planType)) : .firstPaywallPlanRestore(PlanDetails(planName: userSettings.planType)))
                                if purchaseManager.hasPro {
                                    purchaseCompletSuccessfullyAction()
                                }
                            } catch {
                                notificationfeedback.notificationOccurred(.error)
                                purchaseManager.showAlert = true
                                purchaseManager.alertMessage = "Subscription Restore Failed!"
                                purchaseManager.isInProgress = false
                            }
                            
                        }
                    }, closeAction: {
                        closePayAll()
                        if isInternalOpen {
                            AnalyticsManager.shared.log(.internalPaywallXClicked)
                        }
                        else {
                            AnalyticsManager.shared.log(.firstPaywallXClicked)
                        }
                    },
                    delayCloseButton: remoteConfigManager.isShowDelayPaywallCloseButton,
                    delaySeconds: Double(remoteConfigManager.closeButtonDelayTime))
                
                PaywallProFeatureView()
                
                
                VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                    PaywallPlanView(purchaseManager: _purchaseManager, selectedPlan: $selectedPlan, plan: .weekly)
                    
                    PaywallPlanView(purchaseManager: _purchaseManager, selectedPlan: $selectedPlan, plan: .yearly)
                    
                    
                    PaywallBottmView(isProcess: purchaseManager.isInProgress,purchaseManager: _purchaseManager,
                                     selectedPlan: $selectedPlan,
                                     tryForFreeAction: {
                                                    AnalyticsManager.shared.log(isInternalOpen ? .internalPaywallPayButtonClicked(PlanDetails(planName: userSettings.planType)) : .firstPaywallPayButtonClicked(PlanDetails(planName: userSettings.planType)) )
                        
                        Task {
                            do {
                                if let product = purchaseManager.products.first(where: {
                                    $0.id == selectedPlan.productId
                                }) {
                                    try await purchaseManager.purchase(product)
                                    if purchaseManager.hasPro {
                                        purchaseCompletSuccessfullyAction()
                                        notificationfeedback.notificationOccurred(.success)
                                        AnalyticsManager.shared.log(isInternalOpen ? .internalPaywallPlanPurchase(PlanDetails(planName: userSettings.planType)) : .firstPaywallPlanPurchase(PlanDetails(planName: userSettings.planType)) )
                                    }
                                } else {
                                    print("No product")
                                    notificationfeedback.notificationOccurred(.error)
                                }
                            } catch {
                                print("Purchase failed: \(error)")
                                purchaseManager.alertMessage = "Purchase Failed! Please try again or check your payment method."
                                purchaseManager.showAlert = true
                                purchaseManager.isInProgress = false
                                notificationfeedback.notificationOccurred(.error)
                            }
                        }
                    })
                  
                }
                
            }
            
            
            Spacer()
        }
        .onAppear {
   
            self.selectPlan(of: remoteConfigManager.defaultSubscriptionPlan)
            
            paywallLoading()
        }
        .alert(isPresented: $purchaseManager.showAlert) {
            Alert(title: Text("Restore Failed"), message: Text(purchaseManager.alertMessage), dismissButton: .default(Text("OK")))
        }
        .ignoresSafeArea(.container, edges: [.bottom,.top])
        .toolbar(.hidden, for: .navigationBar)
        .background {
            Image(.background)
                .resizable()
                .frame(maxWidth: .infinity,maxHeight:.infinity)
                .ignoresSafeArea(.all)
        }
    }
    
    func selectPlan(of type: Int) {
        switch type {
        case 1:
            self.selectedPlan = SubscriptionPlan.weekly
        case 2:
            self.selectedPlan = SubscriptionPlan.yearly
        case 3:
            self.selectedPlan = SubscriptionPlan.yearlygift
        default:
            self.selectedPlan = SubscriptionPlan.yearly
        }
    }
    
    func paywallLoading() {
        if remoteConfigManager.isShowPaywallCloseButton {
              self.isShowCloseButton = true
          } else {
              self.isShowCloseButton = false
          }
    }
}
