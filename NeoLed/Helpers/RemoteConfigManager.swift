//
//  RemoteConfigManager.swift
//  CarQ
//
//  Created by Purvi Sancheti on 16/09/25.
//


import Foundation
import Firebase
import FirebaseRemoteConfig

class RemoteConfigManager: ObservableObject {
    static var shared = RemoteConfigManager()
    

    @Published var defaultSubscriptionPlan: Int = 2
    @Published var isForceUpdateRequired: Bool = false
    @Published var minimumAppVersion: String = "1.0"

    @Published var showForceUpdateAlert: Bool = false
    @Published var isShowPaywallCloseButton: Bool = true
    @Published var isShowDelayPaywallCloseButton: Bool = false
    @Published var isShowOnboardingPaywall: Bool = true

    
    @Published var closeButtonDelayTime: Int = 5
    
    @Published var giftAfterOnBoarding: Bool = false
    @Published var showLifeTimeBannerAtHome: Bool = false
    @Published var isApproved: Bool = false
    
    @Published var totalFreeLED: Int = 2
    @Published var totalFreeDownload: Int = 2
//    @Published var freeConvertion: Int = 1
//    @Published var maximumRewardAd: Int = 3
//    @Published var showAds: Bool = false
    
//    @Published var temporaryAdsClosed: Bool = false
//    
//    @Published var extendedLimit: Int = 5
//    @Published var dailyLimit: Int = 5
//    
    init() {
        fetchConfig { success in
            if success {
                print("RemoteConfigManager initialized and data loaded successfully")
            } else {
                print("RemoteConfigManager failed to load initial data")
            }
        }
    }
    
    func fetchConfig(completion: @escaping (Bool) -> Void) {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        remoteConfig.fetch(withExpirationDuration: 3600) { status, error in
            if status == .success {
                print("Remote Config fetch succeeded")
                remoteConfig.activate { change, error in
                    if let error = error {
                        print("Failed to activate remote config: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Remote Config activated successfully")
                        self.updateValues()
                        completion(true)
                    }
                }
            } else {
                print("Failed to fetch Remote Config: \(error?.localizedDescription ?? "Unknown Error")")
                completion(false)
            }
        }
    }
    
    func updateValues() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        DispatchQueue.main.async {

            self.defaultSubscriptionPlan = remoteConfig.configValue(forKey: "defaultSubscriptionPlan").numberValue.intValue
            self.minimumAppVersion = remoteConfig.configValue(forKey: "minimumAppVersion").stringValue
            self.isForceUpdateRequired = remoteConfig.configValue(forKey: "isForceUpdateRequired").boolValue
           
            self.isShowPaywallCloseButton = remoteConfig.configValue(forKey: "isShowPaywallCloseButton").boolValue
            self.isShowDelayPaywallCloseButton = remoteConfig.configValue(forKey: "isShowDelayPaywallCloseButton").boolValue
            self.isShowOnboardingPaywall = remoteConfig.configValue(forKey: "isShowOnboardingPaywall").boolValue
     
            self.closeButtonDelayTime = remoteConfig.configValue(forKey: "closeButtonDelayTime").numberValue.intValue
           
            self.giftAfterOnBoarding = remoteConfig.configValue(forKey: "giftAfterOnBoarding").boolValue
            self.showLifeTimeBannerAtHome = remoteConfig.configValue(forKey: "showLifeTimeBannerAtHome").boolValue
            self.isApproved = remoteConfig.configValue(forKey: "isApproved").boolValue
            
            self.totalFreeLED = remoteConfig.configValue(forKey: "totalFreeLED").numberValue.intValue
            
            self.totalFreeDownload = remoteConfig.configValue(forKey: "totalFreeDownload").numberValue.intValue
            
            
            
//
//            self.freeConvertion = remoteConfig.configValue(forKey: "freeConvertion").numberValue.intValue
//            self.maximumRewardAd = remoteConfig.configValue(forKey: "maximumRewardAd").numberValue.intValue
//            self.showAds = remoteConfig.configValue(forKey: "showAds").boolValue
//            
//            self.temporaryAdsClosed = remoteConfig.configValue(forKey: "temporaryAdsClosed").boolValue
//            
//            self.extendedLimit = remoteConfig.configValue(forKey: "extendedLimit").numberValue.intValue
//            self.dailyLimit = remoteConfig.configValue(forKey: "dailyLimit").numberValue.intValue
            
            if self.isForceUpdateRequired && (currentVersion != self.minimumAppVersion) {
                self.showForceUpdateAlert = true
            }
        }
    }
    
}
