//
//  NeoLedApp.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 24/09/25.
//

import SwiftUI
import Firebase

@main
struct NeoLedApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var purchaseManager = PurchaseManager()
    
    @StateObject private var userSettings = UserSettings()
    @StateObject private var timerManager = TimerManager()
    @StateObject var remoteConfigManager = RemoteConfigManager()
    
    
    init() {
          FirebaseApp.configure()
        
      }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(purchaseManager)
                .environmentObject(userSettings)
                .environmentObject(remoteConfigManager)
                .environmentObject(timerManager)
        }
    }
}
