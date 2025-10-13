//
//  UserSettings.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 24/09/25.
//

import Foundation
import SwiftUI
import Security

class UserSettings: ObservableObject {
    
    static let shared = UserSettings()
    private let defaults: UserDefaults
    private let userIdKeychainKey = "user_id_keychain"
    //UserDefaults keys
    private struct Keys {
        static let userId = "user_id"
        static let isPaid = "is_paid"
        static let isTrial = "is_trial"
        static let planType = "plan_type"
        static let planId = "plan_id"
        static let firstPurchaseDate = "firstPurchaseDate"
        static let trialStartDate = "trial_start_date"
        static let ratingPopupCount = "rating_popup_count"
        static let hasFinishedOnboarding = "has_finished_onboarding"
        static let hasShownPaywall = "has_finished_paywall"
        static let hasShownGiftPaywall = "has_finished_paywall"
        static let isShowPayWall = "is_show_payWall"
        static let designCreated = "design_created"
        static let designDownloaded = "design_downloaded"
    }
    
    @Published var userId: String {
          didSet { KeychainHelper.save(userId, for: userIdKeychainKey) }
      }

    @Published var isPaid: Bool {
        didSet {
            defaults.set(isPaid, forKey: Keys.isPaid)
        }
    }
    
    @Published var isTrial: Bool {
        didSet {
            defaults.set(isTrial, forKey: Keys.isTrial)
        }
    }
    
    @Published var planType: String {
        didSet {
            defaults.set(planType, forKey: Keys.planType)
        }
    }
    
    @Published var planId: String {
        didSet {
            defaults.set(planId, forKey: Keys.planId)
        }
    }
    
    @Published var firstPurchaseDate: Date? {
        didSet {
            defaults.set(firstPurchaseDate, forKey: Keys.firstPurchaseDate)
        }
    }
    
    
    @Published var ratingPopupCount: Int {
        didSet {
            defaults.set(ratingPopupCount, forKey: Keys.ratingPopupCount)
        }
    }

    
    @Published var hasFinishedOnboarding: Bool {
        didSet {
            defaults.set(hasFinishedOnboarding, forKey: Keys.hasFinishedOnboarding)
        }
    }
    
    @Published var hasShownPaywall: Bool {
        didSet {
            defaults.set(hasShownPaywall, forKey: Keys.hasShownPaywall)
        }
    }
    
    @Published var hasShownGiftPaywall: Bool {
        didSet {
            defaults.set(hasShownGiftPaywall, forKey: Keys.hasShownGiftPaywall)
        }
    }
    

    @Published var isShowPayWall: Bool {
        didSet {
            defaults.set(isShowPayWall, forKey: Keys.isShowPayWall)
        }
    }
    
    @Published var designCreated: Int {
        didSet {
            defaults.set(designCreated, forKey: Keys.designCreated)
        }
    }
    
    @Published var designDownloaded: Int {
        didSet {
            defaults.set(designDownloaded, forKey: Keys.designDownloaded)
        }
    }
    
    
    
    


    init() {
        self.defaults = UserDefaults.standard
        
        //Load saved value or defaults
        self.userId = defaults.string(forKey: Keys.userId) ?? UserSettings.generateShortUUID()
        self.isPaid = defaults.bool(forKey: Keys.isPaid)
        self.isTrial = defaults.bool(forKey: Keys.isTrial)
        self.planType = defaults.string(forKey: Keys.planType) ?? ""
        self.planId = defaults.string(forKey: Keys.planId) ?? ""
        
        self.ratingPopupCount = defaults.integer(forKey: Keys.ratingPopupCount)
        self.hasFinishedOnboarding = defaults.bool(forKey: Keys.hasFinishedOnboarding)
        self.hasShownPaywall = defaults.bool(forKey: Keys.hasShownPaywall)
        self.hasShownGiftPaywall = defaults.bool(forKey: Keys.hasShownGiftPaywall)
        self.isShowPayWall = defaults.bool(forKey: Keys.isShowPayWall)
        self.designCreated = defaults.integer(forKey: Keys.designCreated)
        self.designDownloaded = defaults.integer(forKey: Keys.designDownloaded)
        
        if let saveData = defaults.object(forKey: Keys.firstPurchaseDate) as? Date {
            self.firstPurchaseDate = saveData
        }
        
        if let savedId = KeychainHelper.read(for: userIdKeychainKey) {
            self.userId = savedId
        }
        else {
                let newId = UserSettings.generateShortUUID()
                self.userId = newId
                KeychainHelper.save(newId, for: userIdKeychainKey)
         }
        

    }
    

    
    static func generateShortUUID(length: Int = 8) -> String {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return String(uuid.prefix(length))
    }
    
}

enum KeychainHelper {
    static func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        // Delete old if exists
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: key] as CFDictionary
        SecItemDelete(query)

        // Add new
        let addQuery = [kSecClass: kSecClassGenericPassword,
                        kSecAttrAccount: key,
                        kSecValueData: data,
                        kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock] as CFDictionary
        SecItemAdd(addQuery, nil)
    }

    static func read(for key: String) -> String? {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: key,
                     kSecReturnData: kCFBooleanTrue!,
                     kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
