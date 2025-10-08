//
//  SettingsCardsView.swift
//  EveCraft
//
//  Created by Purvi Sancheti on 28/08/25.
//

import Foundation
import SwiftUI

struct SettingsCardsView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var userDefault: UserSettings
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    @State var isShowPayWall: Bool = false

 

    var body: some View {
        VStack(spacing: ScaleUtility.scaledSpacing(30)) {
            //MARK: - SECOND CARD
            
            VStack(spacing: ScaleUtility.scaledSpacing(12)) {
//                
//                HStack {
//                    
//                    CommonRowView(rowText: "User ID", rowImage: "userIcon")
//                    
//                    Spacer()
//                    
//                    Text("XR" + userDefault.userId + "P")
//                        .font(FontManager.bricolageGrotesqueLightFont(size: .scaledFontSize(12)))
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(Color.primaryApp.opacity(0.5))
//                }
//                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
//                
//                Rectangle()
//                    .foregroundColor(Color.dividerBg)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: ScaleUtility.scaledValue(1.5))
                
                
                Button {
                    impactfeedback.impactOccurred()
                    if let url = URL(string: AppConstant.ratingPopupURL) {
                        openURL(url)
                    }
                } label: {
                    CommonRowView(rowText: "Rate Us", rowImage: "rateUsIcon")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                
                Rectangle()
                    .foregroundColor(Color.dividerBg)
                    .frame(maxWidth: .infinity)
                    .frame(height: ScaleUtility.scaledValue(1.5))
                
                ShareLink(item: URL(string: AppConstant.shareAppIDURL)!)
                {
                    CommonRowView(rowText: "Share App", rowImage: "shareIcon2")
                }
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                
                Rectangle()
                    .foregroundColor(Color.dividerBg)
                    .frame(maxWidth: .infinity)
                    .frame(height: ScaleUtility.scaledValue(1.5))
                
                Button(action: {
                    impactfeedback.impactOccurred()
                    let url = URL(string: AppConstant.aboutAppURL)!
                    openURL(url)
                }) {
                    HStack {
                        
                        CommonRowView(rowText: "About App", rowImage: "aboutIcon")
                        
                        Text("App Version \(Bundle.appVersion)")
                            .font(FontManager.bricolageGrotesqueLightFont(size: .scaledFontSize(12)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.primaryApp.opacity(0.5))
                        
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                
            }
            .padding(.vertical,ScaleUtility.scaledSpacing(12))
            .background(Color.cardBg)
            .cornerRadius(10)
            .padding(.horizontal,ScaleUtility.scaledSpacing(15))
            
            //MARK: - THIRD CARD
            
            VStack(spacing: ScaleUtility.scaledSpacing(12)) {
                
                Button(action: {
                    impactfeedback.impactOccurred()
                    let url = URL(string: AppConstant.contactUSURL)!
                    openURL(url)
                }) {
                    CommonRowView(rowText: "Contact Us", rowImage: "contactIcon")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                
                Rectangle()
                    .foregroundColor(Color.dividerBg)
                    .frame(maxWidth: .infinity)
                    .frame(height: ScaleUtility.scaledValue(1.5))
                
                Button(action: {
                    impactfeedback.impactOccurred()
                    let url = URL(string: AppConstant.supportURL)!
                    openURL(url)
                }) {
                    CommonRowView(rowText: "Support", rowImage: "supportIcon")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                
                Rectangle()
                    .foregroundColor(Color.dividerBg)
                    .frame(maxWidth: .infinity)
                    .frame(height: ScaleUtility.scaledValue(1.5))
                
                Button(action: {
                    impactfeedback.impactOccurred()
                    let url = URL(string: AppConstant.privacyURL)!
                    openURL(url)
                }) {
                    
                    CommonRowView(rowText: "Privacy Policies", rowImage: "privacyIcon")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                
                Rectangle()
                    .foregroundColor(Color.dividerBg)
                    .frame(maxWidth: .infinity)
                    .frame(height: ScaleUtility.scaledValue(1.5))
                
                Button(action: {
                    impactfeedback.impactOccurred()
                    let url = URL(string: AppConstant.termsAndConditionURL)!
                    openURL(url)
                }) {
                    CommonRowView(rowText: "Terms & Conditions", rowImage: "termsIcon")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal,ScaleUtility.scaledSpacing(14))
                
            }
            .padding(.vertical,ScaleUtility.scaledSpacing(12))
            .background(Color.cardBg)
            .cornerRadius(10)
            .padding(.horizontal,ScaleUtility.scaledSpacing(15))
            
        }
        .padding(.top,ScaleUtility.scaledSpacing(30))
    }
}
extension Bundle {
    static var appVersion: String {
        (main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "-"
    }
    static var buildNumber: String {
        (main.infoDictionary?["CFBundleVersion"] as? String) ?? "-"
    }
}
