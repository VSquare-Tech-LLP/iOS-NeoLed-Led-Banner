//
//  CreateView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 24/09/25.
//

import Foundation
import SwiftUI

struct CreateView: View {
    @StateObject private var viewModel = LEDDesignViewModel()
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    @Binding var backgroundResultImage: String
    @Binding var text: String
    @Binding var backgroundImage: String
    @Binding var textSize: CGFloat
    @Binding var strokeSize: CGFloat
    @Binding var selectedFont: String
    @Binding var selectedColor: ColorOption
    @Binding var selectedOutlineColor: OutlineColorOption
    @Binding var outlineEnabled: Bool
    @Binding var backgroundEnabled: Bool
    @Binding var hasCustomTextColor: Bool
    @Binding var customTextColor: UIColor
    @Binding var selectedEffects: Set<String>
    @Binding var hasUnsavedChanges: Bool  // ✅ KEEP ONLY THIS ONE
    @Binding var showUnsavedDialog: Bool  // ✅ ADD THIS
    @FocusState private var inputFocused: Bool
    
    @State var selectedEditOption: String = "Text"
    var editOptions = ["Text", "Effect", "Background"]
    
    @State private var selectedBgColor: OutlineColorOption = OutlineColorOption.predefinedOutlineColors[0]
    
    // Effect customization states
    @State private var selectedAlignment: String = "None"
    @State private var selectedShape: String = "None"
    @State private var selectedLiveBg: String = "None"
    @State private var frameBg: String = "None"
    @State var frameResultBg: String = "None"
    @State private var textSpeed: CGFloat = 1.0
    @State var showPreview: Bool = false
    @State var isHD: Bool = false
    @State var selectedTab: Int = 0
    
    // Add video generation states
    @State var videoURL: URL? = nil
    @State var showShareSheet: Bool = false
    @State var showSaveAlert: Bool = false
    @State var saveAlertMessage: String = ""
    @State var isProcessing: Bool = false
    @State var progress: Double = 0.0
    @State var isExporting: Bool = false
    
    // ✅ ADD THESE CALLBACKS
    var onSaveAndContinue: () -> Void
    var onDiscardAndContinue: () -> Void
    
    var isBold: Bool { selectedEffects.contains("Bold") }
    var isItalic: Bool { selectedEffects.contains("Italic") }
    var isLight: Bool { selectedEffects.contains("Blink") }
    var isFlash: Bool { selectedEffects.contains("Glow") }
    var isMirror: Bool { selectedEffects.contains("Mirror") }
 
    var body: some View {
        VStack(spacing:0) {
            
            VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                
                TopView(
                    backgroundImage: $backgroundImage,
                    text: $text,
                    selectedFont: $selectedFont,
                    textSize: $textSize,
                    strokeSize: $strokeSize,
                    selectedColor: $selectedColor,
                    selectedOutlineColor: $selectedOutlineColor,
                    outlineEnabled: $outlineEnabled,
                    hasCustomTextColor: $hasCustomTextColor,
                    customTextColor: $customTextColor,
                    selectedEffects: $selectedEffects,
                    selectedAlignment: $selectedAlignment,
                    selectedShape: $selectedShape,
                    textSpeed: $textSpeed,
                    isHD: $isHD,
                    selectedBgColor: $selectedBgColor,
                    backgroundEnabled: $backgroundEnabled,
                    selectedLiveBg: $selectedLiveBg,
                    frameBg: $frameBg,
                    isInputFocused: $inputFocused) {
                        if text != "" {
                            showPreview = true
                        }
                    } onSave: {
                        saveDesignToHistory()
                    } onDownload: {
                        AnalyticsManager.shared.log(.downloaded)
                        impactFeedback.impactOccurred()
                        
                        if text.isEmpty {
                            saveAlertMessage = "Please enter text first"
                            showSaveAlert = true
                            return
                        }
                        isExporting = true
                        convertViewToVideo(isShare: false)
                    }
                  onValueChange: {
                    markAsUnsaved()
                }

                
                CustomTabPicker(selectedTab: $selectedTab, tabs: ["Text","Background"])
            }
                  
            ScrollView {
                
                Spacer()
                    .frame(height: ScaleUtility.scaledValue(25))
                
                if selectedTab == 0 {
                    EditTextView(
                        selectedEffect: $selectedEffects,
                        textSize: $textSize,
                        strokeSize: $strokeSize,
                        selectedFont: $selectedFont,
                        selectedColor: $selectedColor,
                        selectedOutlineColor: $selectedOutlineColor,
                        outlineEnabled: $outlineEnabled,
                        hasCustomTextColor: $hasCustomTextColor,
                        customTextColor: $customTextColor,
                        textSpeed: $textSpeed,
                        selectedAlignment: $selectedAlignment,
                        selectedLiveBg: $selectedLiveBg,
                        selectedBgColor: $selectedBgColor,
                        onValueChange: {
                            markAsUnsaved()
                        }
                    )
                }
                else {
                    EditBackgroundView(
                        isHD: $isHD,
                        selectedShape: $selectedShape,
                        selectedBgColor: $selectedBgColor,
                        backgroundEnabled: $backgroundEnabled,
                        selectedLiveBg: $selectedLiveBg,
                        frameBg: $frameBg,
                        frameResultBg: $frameResultBg,
                        onValueChange: {
                            markAsUnsaved()
                        }
                    )
                }
                
                Spacer()
                    .frame(height: ScaleUtility.scaledValue(105))
            }
            
            Spacer()
        }
        // ✅ REMOVE .onReceive - it's not needed anymore
        .background {
            Image(.background)
                .resizable()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = videoURL {
                ShareSheet(items: [url], filename: "NeoLed Video")
            }
        }
        .alert("Video Status", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveAlertMessage)
        }
        .confirmationDialog(
            "Uh-Oh!",
            isPresented: $showUnsavedDialog,
            titleVisibility: .visible
        ) {
            Button("Save Design") {
                saveDesignToHistory()
                onSaveAndContinue()
            }
            
            Button("Don’t Save", role: .destructive) {
                hasUnsavedChanges = false
                onDiscardAndContinue()
            }
            
            Button("Cancel", role: .cancel) {
                // Just close the dialog
            }
      
        } message: {
            Text("You have unsaved changes. Please check if you want to save the design.")
        }
        .preferredColorScheme(.dark)
        .tint(.blue)
        .overlay {
            if isExporting {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(20)) {
                        Text("Exporting Video...")
                            .font(.system(size: .scaledFontSize(20), weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: .scaledFontSize(16), weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: ScaleUtility.scaledValue(250), height: ScaleUtility.scaledValue(8))
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: ScaleUtility.scaledValue(250) * CGFloat(progress), height: ScaleUtility.scaledValue(8))
                                .animation(.linear(duration: 0.3), value: progress)
                        }
                    }
                    .padding(ScaleUtility.scaledSpacing(40))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.8))
                            .shadow(radius: 10)
                    )
                }
            }
        }
        .navigationDestination(isPresented: $showPreview) {
            ResultView(
                backgroundResultImage: backgroundResultImage,
                backgroundImage: backgroundImage,
                text: text,
                selectedFont: selectedFont,
                textSize: textSize,
                strokeSize: strokeSize,
                selectedColor: selectedColor,
                selectedOutlineColor: selectedOutlineColor,
                selectedBgColor: selectedBgColor,
                backgroundEnabled: backgroundEnabled,
                outlineEnabled: outlineEnabled,
                hasCustomTextColor: hasCustomTextColor,
                customTextColor: customTextColor,
                selectedEffects: selectedEffects,
                selectedAlignment: selectedAlignment,
                selectedShape: selectedShape,
                textSpeed: textSpeed,
                isHD: isHD,
                selectedLiveBg: selectedLiveBg,
                frameResultBg: frameResultBg,
                frameBg: frameBg,
                isSaved: true,
                onBack: {
                    showPreview = false
                }
            )
            .background {
                Image(.background)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func markAsUnsaved() {
        hasUnsavedChanges = true
    }
    
    private func invalidateVideoCache() {
        videoURL = nil
        print("Video cache invalidated - will regenerate on next download/share")
    }
    
    private func saveVideoToPhotos(_ url: URL) {
        let videoSaver = VideoSaver()
        videoSaver.successHandler = {
            saveAlertMessage = "Video successfully saved"
            showSaveAlert = true
        }
        videoSaver.errorHandler = { error in
            saveAlertMessage = "Error saving video: \(error.localizedDescription)"
            showSaveAlert = true
        }
        videoSaver.saveVideo(url)
    }
    
    private func saveDesignToHistory() {
        viewModel.saveDesign(
            backgroundResultImage: backgroundResultImage,
            backgroundImage: backgroundImage,
            text: text,
            selectedFont: selectedFont,
            textSize: textSize,
            strokeSize: strokeSize,
            selectedColor: selectedColor,
            selectedOutlineColor: selectedOutlineColor,
            selectedBgColor: selectedBgColor,
            backgroundEnabled: backgroundEnabled,
            outlineEnabled: outlineEnabled,
            hasCustomTextColor: hasCustomTextColor,
            customTextColor: customTextColor,
            selectedEffects: selectedEffects,
            selectedAlignment: selectedAlignment,
            selectedShape: selectedShape,
            textSpeed: textSpeed,
            isHD: isHD,
            selectedLiveBg: selectedLiveBg,
            frameResultBg: frameResultBg,
            frameBg: frameBg
        )
        
        hasUnsavedChanges = false
        saveAlertMessage = "Design saved Successfully!"
        showSaveAlert = true
    }
    
    private func convertViewToVideo(isShare: Bool) {
        isProcessing = true
        progress = 0.0
        
        VideoGenerationHelper.generateVideo(
            text: text,
            selectedFont: selectedFont,
            textSize: textSize,
            strokeSize: strokeSize,
            selectedColor: selectedColor,
            selectedOutlineColor: selectedOutlineColor,
            selectedBgColor: selectedBgColor,
            outlineEnabled: outlineEnabled,
            backgroundEnabled: backgroundEnabled,
            selectedEffects: selectedEffects,
            selectedAlignment: selectedAlignment,
            selectedShape: selectedShape,
            textSpeed: textSpeed,
            isHD: isHD,
            selectedLiveBg: selectedLiveBg,
            backgroundResultImage: backgroundResultImage,
            frameResultBg: frameResultBg,
            progressHandler: { generationProgress in
                self.progress = generationProgress
            },
            completion: { result in
                self.isProcessing = false
                switch result {
                case .success(let url):
                    self.videoURL = url
                    self.progress = 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isExporting = false
                        if isShare {
                            self.showShareSheet = true
                        } else {
                            self.saveVideoToPhotos(url)
                        }
                    }
                case .failure(let error):
                    self.isExporting = false
                    self.progress = 0.0
                    self.saveAlertMessage = "Failed to generate video: \(error.localizedDescription)"
                    self.showSaveAlert = true
                }
            }
        )
    }
}
