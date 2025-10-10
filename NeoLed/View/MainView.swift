//
//  MainView.swift
//  NeoLed
//

import Foundation
import SwiftUI

enum TabSelection: Hashable {
    case explore
    case create
    case history
}

struct MainView: View {
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    @State var backgroundImage: String = ""
    @State var backgroundResultImage: String = ""
    @State private var selectedTab: TabSelection = .explore
    @State private var text: String = ""
    @State private var textSize: CGFloat = 4.0
    @State private var strokeSize: CGFloat = 0.0
    @State private var selectedFont: String = FontManager.bricolageGrotesqueRegularFont
    @State private var selectedColor: ColorOption = ColorOption.predefinedColors[1]
    @State private var selectedOutlineColor: OutlineColorOption = OutlineColorOption.predefinedOutlineColors[0]
    @State private var outlineEnabled = false
    @State private var backgroundEnabled = false
    @State private var hasCustomTextColor = false
    @State private var customTextColor: UIColor = .white
    @State private var selectedEffects: Set<String> = ["None"]
    @State private var hasUnsavedChanges = false
    
    // ✅ ADD THESE
    @State private var pendingTabChange: TabSelection? = nil
    @State private var showUnsavedDialog = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .explore:
                        ExploreView(
                            onTemplateSelect: { template in
                                loadTemplate(template)
                                selectedTab = .create
                                hasUnsavedChanges = false
                            }
                        )
                    case .create:
                        CreateView(
                            backgroundResultImage: $backgroundResultImage,
                            text: $text,
                            backgroundImage: $backgroundImage,
                            textSize: $textSize,
                            strokeSize: $strokeSize,
                            selectedFont: $selectedFont,
                            selectedColor: $selectedColor,
                            selectedOutlineColor: $selectedOutlineColor,
                            outlineEnabled: $outlineEnabled,
                            backgroundEnabled: $backgroundEnabled,
                            hasCustomTextColor: $hasCustomTextColor,
                            customTextColor: $customTextColor,
                            selectedEffects: $selectedEffects,
                            hasUnsavedChanges: $hasUnsavedChanges,
                            showUnsavedDialog: $showUnsavedDialog,
                            onSaveAndContinue: {
                                // Save was clicked in dialog
                                if let targetTab = pendingTabChange {
                                    switchToTab(targetTab)
                                    pendingTabChange = nil
                                }
                            },
                            onDiscardAndContinue: {
                                // Discard was clicked in dialog
                                if let targetTab = pendingTabChange {
                                    switchToTab(targetTab)
                                    pendingTabChange = nil
                                }
                            }
                        )
                    case .history:
                        HistoryView()
                    }
                }
                .frame(maxWidth:.infinity)
                .transition(.opacity)
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            impactFeedback.impactOccurred()
                            requestTabChange(to: .explore)
                        } label: {
                            VStack(spacing: ScaleUtility.scaledSpacing(4.88)) {
                                Image(.exploreIcon)
                                    .resizable()
                                    .frame(width: ScaleUtility.scaledValue(29.26829), height: ScaleUtility.scaledValue(29.26829))
                                
                                Text("Templates")
                                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.41463)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: isIPad ? ScaleUtility.scaledValue(95.36585) : ScaleUtility.scaledValue(85.36585))
                            }
                            .opacity(selectedTab != .explore ? 0.5 : 1)
                        }
                        
                        Spacer()
                        
                        Button {
                            impactFeedback.impactOccurred()
                            requestTabChange(to: .create)
                        } label: {
                            VStack(spacing: ScaleUtility.scaledSpacing(4.88)) {
                                Image(.createIcon)
                                    .resizable()
                                    .frame(width: ScaleUtility.scaledValue(29.26829), height: ScaleUtility.scaledValue(29.26829))
                                
                                Text("Create")
                                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.41463)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: ScaleUtility.scaledValue(85.36585))
                            }
                            .opacity(selectedTab != .create ? 0.5 : 1)
                        }
                        
                        Spacer()
                        
                        Button {
                            impactFeedback.impactOccurred()
                            requestTabChange(to: .history)
                        } label: {
                            VStack(spacing: ScaleUtility.scaledSpacing(4.88)) {
                                Image(.historyIcon)
                                    .resizable()
                                    .frame(width: ScaleUtility.scaledValue(24), height: ScaleUtility.scaledValue(24))
                                
                                Text("Saved")
                                    .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(13.41463)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: ScaleUtility.scaledValue(84))
                            }
                            .opacity(selectedTab != .history ? 0.5 : 1)
                        }
                    }
                    .padding(.horizontal, isIPad ? ScaleUtility.scaledSpacing(84) : ScaleUtility.scaledSpacing(34))
                    .padding(.bottom, ScaleUtility.scaledSpacing(10))
                    .frame(height: ScaleUtility.scaledValue(97))
                    .background {
                        Image(.tabBg)
                            .resizable()
                            .frame(height: ScaleUtility.scaledValue(97))
                            .frame(maxWidth:.infinity)
                    }
                    .cornerRadius(10)
                }
            }
            .ignoresSafeArea(.all)
        }
    }
    
    // MARK: - Helper Functions
    
    private func requestTabChange(to newTab: TabSelection) {
        if selectedTab == .create && newTab != .create && hasUnsavedChanges {
            pendingTabChange = newTab
            showUnsavedDialog = true
        } else {
            switchToTab(newTab)
        }
    }

    
    private func switchToTab(_ newTab: TabSelection) {
        selectedTab = newTab
        
        if newTab != .create {
            resetCreateData()
        }
        
        hasUnsavedChanges = false
    }
    
    private func resetCreateData() {
        backgroundImage = ""
        backgroundResultImage = ""
        text = ""
        textSize = 4.0
        strokeSize = 0.0
        selectedFont = FontManager.bricolageGrotesqueRegularFont
        selectedColor = ColorOption.predefinedColors[1]
        selectedOutlineColor = OutlineColorOption.predefinedOutlineColors[0]
        outlineEnabled = false
        backgroundEnabled = false
        hasCustomTextColor = false
        customTextColor = .white
        selectedEffects = ["None"]
    }
    
    private func loadTemplate(_ template: LEDTemplate) {
        text = template.text
        textSize = template.textSize
        strokeSize = template.strokeSize ?? 0.0
        backgroundImage = template.imageName
        backgroundResultImage = template.backgroundResultImage
        selectedFont = template.selectedFont
        if template.isBold {
            selectedEffects.insert("Bold")
            selectedEffects.remove("None")
        }
        if template.isItalic {
            selectedEffects.insert("Italic")
            selectedEffects.remove("None")
        }
        
        if let hexColor = template.customTextColorHex, !hexColor.isEmpty {
            customTextColor = UIColor(hex: hexColor) ?? .white
            hasCustomTextColor = true
            selectedColor = ColorOption(
                id: "custom_text",
                name: "Custom",
                type: .solid(Color(customTextColor))
            )
        } else {
            hasCustomTextColor = false
            customTextColor = .white
        }
        
        if let strokeSize = template.strokeSize, strokeSize > 0,
           let strokeColorId = template.strokeColorId,
           let strokeColor = OutlineColorOption.predefinedOutlineColors.first(where: { $0.id == strokeColorId }) {
            selectedOutlineColor = strokeColor
            outlineEnabled = true
        } else {
            outlineEnabled = false
        }
    }
}
