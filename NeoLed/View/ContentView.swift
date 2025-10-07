//
//  ContentView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 24/09/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userDefault: UserSettings
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
//    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        ZStack {
            if userDefault.hasFinishedOnboarding {
                MainView()
            }
            else if userDefault.hasShownPaywall {
                
                PaywallView(closePayAll: {
                    if purchaseManager.hasPro || !remoteConfigManager.giftAfterOnBoarding {
                        userDefault.hasFinishedOnboarding = true
                    }
                    else {
                        userDefault.hasShownGiftPaywall = true
                    }
                }, purchaseCompletSuccessfullyAction: {
                    userDefault.hasFinishedOnboarding = true
                })
            }
            else {
                SwipeView(showPaywall: {
                    if !purchaseManager.hasPro && remoteConfigManager.isShowOnboardingPaywall {
                        userDefault.hasShownPaywall = true
                    }
                    else {
                        userDefault.hasFinishedOnboarding = true
                    }
                })
            }
        }
        
        .onAppear {
            remoteConfigManager.fetchConfig { success in
                if success {
                    print("RemoteConfigManager initialized and data loaded successfully")
                } else {
                    print("RemoteConfigManager failed to load initial data")
                }
            }
//            timerManager.setupCountdown()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                await purchaseManager.updatePurchaseProducts()
            }
        }
    }
}

#Preview {
    ContentView()
}
