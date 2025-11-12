//
//  PurchaseManager.swift
//  iOS-Word-Vibe
//
//  Created by Darsh Viroja on 20/05/25.
//

import Foundation
import StoreKit

@MainActor
class PurchaseManager: NSObject, ObservableObject {
    @Published var products: [Product] = []
    @Published var productIds: [String] = SubscriptionPlan.allCases.map { $0.rawValue }
    
    @Published var userSettings = UserSettings()
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published var hasPro: Bool = false {
        didSet { userSettings.isPaid = hasPro }
    }

    @Published var isInProgress = true
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private var productsLoaded = false

    override init() {
        super.init()
        observeTransactionUpdates()
        Task {
            await fetchProducts()
            await updatePurchaseProducts()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc func appDidBecomeActive() {
        Task { await updatePurchaseProducts() }
    }

    func fetchProducts() async {
        guard !productsLoaded else {
            print("Products already loaded.")
            return
        }
        isInProgress = true
        do {
            products = try await Product.products(for: productIds)
            productsLoaded = true
        } catch {
            print("Failed to load products: \(error)")
        }
        isInProgress = false
    }

    func purchase(_ product: Product) async throws {
        isInProgress = true
        let result = try await product.purchase()

        guard !purchasedProductIDs.contains(product.id) else {
            showAlert(message: "You've already purchased this plan")
            isInProgress = false
            userSettings.isPaid = true
            return
        }

        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            updateUserSettings(for: transaction.productID)
            await updatePurchaseProducts()

        case .success(.unverified(_, _)):
            showAlert(message: "Transaction/receipt can't be verified, phone might be jailbroken!")
            
        case .userCancelled:
            resetUserStatus()

        case .pending:
            showAlert(message: "Transaction pending Strong Customer Authentication!")

        @unknown default:
            resetUserStatus()
        }
        isInProgress = false
    }

    func updatePurchaseProducts(isRestore: Bool = false) async {
        isInProgress = true
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                print("Unverified transaction: \(result)")
                continue
            }

            let productID = transaction.productID
            if transaction.revocationDate == nil {
                purchasedProductIDs.insert(productID)
                updateUserSettings(for: productID)
            } else {
                purchasedProductIDs.remove(productID)
                showAlert(message: "Your subscription has been cancelled or expired.")
            }

            if isRestore {
                do {
                    _ = try await Product.products(for: [productID])
                } catch {
                    print("Restore failed: \(error)")
                }
            }
        }

        if isRestore && purchasedProductIDs.isEmpty {
            showAlert(message: "Subscription does not exist!")
        }

        let isPaid = !purchasedProductIDs.isEmpty
        hasPro = isPaid
        userSettings.isPaid = isPaid
        isInProgress = false
    }

    private func updateUserSettings(for productID: String) {
        guard let plan = SubscriptionPlan(rawValue: productID) else { return }
        userSettings.planType = plan.planName
        userSettings.planId = plan.rawValue
        userSettings.isPaid = true
    }

    private func resetUserStatus() {
        hasPro = false
        userSettings.isPaid = false
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }

    private func observeTransactionUpdates() {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await updatePurchaseProducts()
            }
        }
    }
}

enum SubscriptionPlan: String, CaseIterable {
    case weekly = "com.neoled.weekly"
    case yearly = "com.neoled.yearly"
    case lifetime = "com.neoled.lifetime"
    case gift = "com.neoled.lifetimegiftplan"
    
    // Add new product IDs here as new cases:
    // case monthly = "com.zyric.monthly"

    var planName: String {
        switch self {
        case .weekly: return "Weekly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        case .gift: return "Gift - Lifetime"
        }
    }

    var planSubTitle: String {
        switch self {
        case .weekly: return "Start with the cheapest"
        case .yearly: return "Free for 3 days, then only $9.99/year"
        case .lifetime: return "One-time offer. Redeem Now"
        case .gift: return ""
        }
    }

    var price: String {
        switch self {
        case .weekly: return "$3.99/week"
        case .yearly: return "$9.99/year"
        case .lifetime: return "$9.99 Once"
        case .gift: return ""
        }
    }
}



enum PremiumFeature: CaseIterable {
    case first
    case second
    case third
    case fourth
    
    
    var title: String {
        switch self {
        case .first:
            "Create Unlimited Banners"
        case .second:
            "Unlock All Customization"
        case .third:
            "No Ads, No Distractions"
        case .fourth:
            "Access All Templates"
        }
    }
    
    var image: String {
        switch self {
        case .first:
            "magnifierIcon"
        case .second:
            "infiniteIcon"
        case .third:
            "noAdsIcon"
        case .fourth:
            "energyIcon"
        }
    }

}

struct PlanDetails: Codable {
    let planName: String

    init(planName: String) {
           self.planName = planName
       }
}

