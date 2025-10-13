//
//  AppDelegate.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 09/10/25.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // MARK: - Notification Center Delegate Setup
      
        
        // MARK: - Keyboard Setup
        IQKeyboardManager.shared.isEnabled = false
        IQKeyboardManager.shared.enableAutoToolbar = true // enables "Done" button
        IQKeyboardManager.shared.resignOnTouchOutside = true // tap outside to dismiss
        IQKeyboardManager.shared.toolbarConfiguration.tintColor = UIColor.appBlue
        return true
    }
    
}
