//
//  HistoryView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 24/09/25.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State var navToSettings: Bool = false
    @StateObject private var viewModel = LEDDesignViewModel()
    @State private var selectedDesign: LEDDesignEntity?
    @State private var navigateToResult = false
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    let columns = [
        GridItem(.flexible(), spacing: ScaleUtility.scaledSpacing(15)),
        GridItem(.flexible(), spacing: ScaleUtility.scaledSpacing(15))
    ]
    
    @State var isShowPayWall: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
           // MARK: - Header Section
            
            HStack {
              
                Text("History")
                    .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(25.56818)))
                    .foregroundColor(Color.primaryApp)
                
                Spacer()
                
                HStack(spacing: ScaleUtility.scaledSpacing(12)) {
                    
                    Button {
                        impactFeedback.impactOccurred()
                        isShowPayWall = true
                    } label: {
                        
                        Image(.crownIcon)
                            .resizable()
                            .frame(width: isIPad ? ScaleUtility.scaledValue(30.45455) : ScaleUtility.scaledValue(20.45455),
                                   height: isIPad ? ScaleUtility.scaledValue(30.45455) : ScaleUtility.scaledValue(20.45455))
                            .padding(.all, ScaleUtility.scaledSpacing(6.77))
                            .background(Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(Color.accent, lineWidth: 1)
                            )
                    }
                    .opacity(purchaseManager.hasPro ? 0 : 1)
                    
                    Button {
                        impactFeedback.impactOccurred()
                        navToSettings = true
                    } label: {
                        Image(.settingIcon)
                            .resizable()
                            .frame(width: isIPad ? ScaleUtility.scaledValue(28.57641) : ScaleUtility.scaledValue(19.57641),
                                   height: isIPad ? ScaleUtility.scaledValue(30) : ScaleUtility.scaledValue(20))
                            .padding(.all, ScaleUtility.scaledSpacing(8))
                            .background{
                                Circle()
                                    .fill( Color.primaryApp.opacity(0.1))
                               
                            }
                    }
                }
                
            }
            .padding(.horizontal, ScaleUtility.scaledSpacing(20))
            .padding(.top, ScaleUtility.scaledSpacing(62))
            
            
            // Content
            if viewModel.designs.isEmpty {
                   EmptyView()
                     
               } else {
                   ScrollView {
                       
                       Spacer()
                           .frame(height: ScaleUtility.scaledValue(20))
                       
                       VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                           ForEach(viewModel.designs, id: \.id) { design in
                               HistoryCardViewCoreData(
                                   design: design,
                                   onTap: {
                                       selectedDesign = design
                                       navigateToResult = true
                                   },
                                   onDelete: {
                                       viewModel.deleteDesign(design)
                                   }
                               )
                               .padding(.horizontal, ScaleUtility.scaledSpacing(20))
                           }
                       }

                       Spacer()
                           .frame(height: ScaleUtility.scaledValue(150))
                   }
               }
            
            Spacer()
            
        }
        .background {
            Image(.background)
                .resizable()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
        .onAppear {
            viewModel.fetchDesigns()
        }
        .navigationDestination(isPresented: $navToSettings) {
            SettingsView {
                navToSettings = false
            }
            .background {
                Image(.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let design = selectedDesign {
                ResultView(
                    backgroundResultImage: design.backgroundResultImage ?? "",
                    backgroundImage: design.backgroundImage ?? "",
                    text: design.text ?? "",
                    selectedFont: design.selectedFont ?? FontManager.bricolageGrotesqueRegularFont,
                    textSize: design.textSize,
                    strokeSize: design.strokeSize,
                    selectedColor: design.toEffectiveTextColorOption(),
                    selectedOutlineColor: design.toOutlineColor(),
                    selectedBgColor: design.toBgColor(),
                    backgroundEnabled: design.backgroundEnabled,
                    outlineEnabled: design.outlineEnabled,
                    hasCustomTextColor: design.hasCustomTextColor,
                    customTextColor: design.decodedCustomColor ?? .white,
                    selectedEffects: Set(design.effectsArray),
                    selectedAlignment: design.selectedAlignment ?? "None",
                    selectedShape: design.selectedShape ?? "None",
                    textSpeed: design.textSpeed,
                    isHD: design.isHD,
                    selectedLiveBg: design.selectedLiveBg ?? "None",
                    frameResultBg: design.frameResultBg ?? "None",
                    frameBg: design.frameBg ?? "None",
                    isSaved: false,
                    onBack: {
                        navigateToResult = false
                        selectedDesign = nil
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $isShowPayWall) {
            
            PaywallView(isInternalOpen: true) {
                isShowPayWall = false
            } purchaseCompletSuccessfullyAction: {
                isShowPayWall = false
            }
            .background {
                Image(.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            }
        }
    }
}
