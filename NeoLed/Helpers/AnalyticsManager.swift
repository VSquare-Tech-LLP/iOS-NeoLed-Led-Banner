//
//  AnalyticsManager.swift
//  EveCraft
//
//  Created by Purvi Sancheti on 03/09/25.
//


import Foundation
import FirebaseAnalytics

///Manager to handle firebase app anaytics
final class AnalyticsManager {
    private init() {}
    
    static let shared = AnalyticsManager()
    
    public func log(_ event: AnalyticsEvent) {
        switch event {
        case .firstPaywallPayButtonClicked(let plandDetails), .internalPaywallPayButtonClicked(let plandDetails):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            let eventName = "\(event.eventName)_Plan_Clicked"
            print("Event: \(eventName)")
            Analytics.logEvent(eventName, parameters: ["Plan":plandDetails.planName])
            break
        case .firstPaywallPlanPurchase(let plandDetails), .internalPaywallPlanPurchase(let plandDetails):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            let eventName = "\(event.eventName)_Plan_Purchased"
            print("Event: \(eventName)")
            Analytics.logEvent(eventName, parameters: ["Plan":plandDetails.planName])
            break
        case .firstPaywallPlanRestore(let plandDetails),  .internalPaywallPlanRestore(let plandDetails):
            let eventName = "\(event.eventName)"
            print("Event: \(eventName)")
            Analytics.logEvent(eventName, parameters: nil)
            break
            // Text customization events
        case .effectApplied(let effectName):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(effectName)")
            Analytics.logEvent(event.eventName, parameters: ["effect_name": effectName])
            
        case .fontSelected(let fontName):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(fontName)")
            Analytics.logEvent(event.eventName, parameters: ["font_name": fontName])
            
        case .textColorSelected(let colorName):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(colorName)")
            Analytics.logEvent(event.eventName, parameters: ["color_name": colorName])
            
        case .strokeColorSelected(let colorName):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(colorName)")
            Analytics.logEvent(event.eventName, parameters: ["stroke_color": colorName])
            
        case .scrollDirectionChanged(let direction):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(direction)")
            Analytics.logEvent(event.eventName, parameters: ["direction": direction])
            
            // Background customization events
        case .backgroundColorSelected(let colorName):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(colorName)")
            Analytics.logEvent(event.eventName, parameters: ["bg_color": colorName])
            
        case .liveBackgroundSelected(let backgroundName):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(backgroundName)")
            Analytics.logEvent(event.eventName, parameters: ["live_bg_name": backgroundName])
            
        case .frameBackgroundSelected(let frameName):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(frameName)")
            Analytics.logEvent(event.eventName, parameters: ["frame_name": frameName])
            
            // Display settings
        case .bannerTypeChanged(let bannerType):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(bannerType)")
            Analytics.logEvent(event.eventName, parameters: ["banner_type": bannerType])
            
        case .ledShapeSelected(let shapeName):
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName) - \(shapeName)")
            Analytics.logEvent(event.eventName, parameters: ["shape_name": shapeName])
            
        case .templateSelected(let templateName):
              print("\nEvent Logged\n")
              print("--------------------------------------------------\n")
              print("Event: \(event.eventName) - \(templateName)")
              Analytics.logEvent(event.eventName, parameters: ["template_name": templateName])
              
            
        default:
            print("\nEvent Logged\n")
            print("--------------------------------------------------\n")
            print("Event: \(event.eventName)")
            Analytics.logEvent(event.eventName, parameters: nil)
            break
        }
    }
}

enum AnalyticsEvent {
    //first paywall after on boarding
    case firstPaywallLoaded //
    case firstPaywallXClicked //
    case AdsClicked //
    
    case firstPaywallRestoreClicked //
    case firstPaywallPayButtonClicked(PlanDetails) //
    case firstPaywallPlanPurchase(PlanDetails) //
    case firstPaywallPlanRestore(PlanDetails) //
    
    //Internal paywall from validation and settings
    case internalPaywallLoaded //
    case internalPaywallXLoaded //
    case internalPaywallXClicked //
    case internalPaywallContinueWithAdsClicked //
    
    case internalPaywallRestoreClicked
    case internalPaywallPayButtonClicked(PlanDetails) //
    case internalPaywallPlanPurchase(PlanDetails) //
    case internalPaywallPlanRestore(PlanDetails) //
  
    
    //other events
   
    case giftScreenLoaded
    case giftScreenXClicked
    case giftScreenPlanPurchase
    case giftBottomSheetXClicked
    case giftBannerPlanPurchase
    
    // Text customization events
    case effectApplied(effectName: String)
    case fontSelected(fontName: String)
    case textColorSelected(colorName: String)
    case strokeColorSelected(colorName: String)
    case scrollDirectionChanged(direction: String)
    
    // Background customization events
    case backgroundColorSelected(colorName: String)
    case liveBackgroundSelected(backgroundName: String)
    case frameBackgroundSelected(frameName: String)
    
    // Display settings
    case bannerTypeChanged(bannerType: String)
    case ledShapeSelected(shapeName: String)

    case templateSelected(templateName: String)
        

    
    case firstRatingPopupDisplayed
    case secondRatingPopupDisplayed
    case thirdRatingPopupDisplayed
    
    case downloaded
    case shared
    case deleted
    
    case noOfUserUpdatedApp
    
    case getPremiumFromAlert
    case watchanAd
    
    var eventName: String {
        switch self {
        case .firstPaywallLoaded: return "on_boarding_paywall_opened"
        case .firstPaywallXClicked: return "first_paywall_x_clicked"
        case .firstPaywallPayButtonClicked: return "first_paywall"
        case .firstPaywallRestoreClicked: return "first_paywall_restore_clicked"
        case .firstPaywallPlanPurchase: return "on_boarding_paywall"
        case .firstPaywallPlanRestore: return "first_paywall_plan_restore"
        case .internalPaywallLoaded: return "internal_paywall_opened"
        case .internalPaywallXLoaded: return "internal_paywall_x_loaded"
        case .internalPaywallXClicked: return "internal_paywall_x_clicked"
        case .internalPaywallPayButtonClicked: return "internal_paywall"
        case .internalPaywallRestoreClicked: return "internal_paywall_restore_clicked"
        case .internalPaywallPlanPurchase: return "internal_paywall"
        case .internalPaywallPlanRestore: return "internal_paywall_plan_restore"
      
        case .effectApplied: return "effect_applied"
        case .fontSelected: return "font_selected"
        case .textColorSelected: return "text_color_selected"
        case .strokeColorSelected: return "stroke_color_selected"
        case .scrollDirectionChanged: return "scroll_direction_changed"
        case .backgroundColorSelected: return "background_color_selected"
        case .liveBackgroundSelected: return "live_background_selected"
        case .frameBackgroundSelected: return "frame_background_selected"
        case .bannerTypeChanged: return "banner_type_changed"
        case .ledShapeSelected: return "led_shape_selected"
           
        case .templateSelected: return "template_selected"
            
        case .firstRatingPopupDisplayed: return "first_rating_popup_displayed"
        case .secondRatingPopupDisplayed: return "second_rating_popup_displayed"
        case .thirdRatingPopupDisplayed: return "third_rating_popup_displayed"
            
            
        case .giftScreenLoaded: return "giftscreenLoaded"
        case .giftScreenXClicked: return "giftscreen_closed"
        case .giftScreenPlanPurchase: return "giftscreen_planpurchase"
        case .giftBottomSheetXClicked: return "giftscreenbottomsheet_closed"
        case .giftBannerPlanPurchase: return "giftbanner_planpurchase"
        
        case .downloaded: return "led_downloaded"
        case .shared: return "led_shared"
        case .deleted: return "led_deleted"
            
        case .AdsClicked: return "ads_clicked"
            
            
        case .internalPaywallContinueWithAdsClicked: return "i_paywall_continue_with_ads_clicked"
           
        case .noOfUserUpdatedApp: return "appupdated"
        case .getPremiumFromAlert: return "get_premium_pressed_from_alert"
        case .watchanAd: return "watch_an_ad_pressed"
        }
    }
    
}

