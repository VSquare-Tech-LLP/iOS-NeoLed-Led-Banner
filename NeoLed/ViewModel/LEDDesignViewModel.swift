//
//  LEDDesignViewModel.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 02/10/25.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class LEDDesignViewModel: ObservableObject {
    @Published var designs: [LEDDesignEntity] = []
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchDesigns()
        setupNotificationObserver()
    }
    
    // MARK: - Fetch Designs
    func fetchDesigns() {
        designs = coreDataManager.fetchAllDesigns()
    }
    
    // MARK: - Save Design
    func saveDesign(
        backgroundResultImage: String,
        backgroundImage: String,
        text: String,
        selectedFont: String,
        textSize: CGFloat,
        strokeSize: CGFloat,
        selectedColor: ColorOption,
        selectedOutlineColor: OutlineColorOption,
        selectedBgColor: OutlineColorOption,
        backgroundEnabled: Bool,
        outlineEnabled: Bool,
        hasCustomTextColor: Bool,
        customTextColor: UIColor,
        selectedEffects: Set<String>,
        selectedAlignment: String,
        selectedShape: String,
        textSpeed: CGFloat,
        isHD: Bool,
        selectedLiveBg: String,
        frameResultBg: String,
        frameBg: String
    ) {
        let success = coreDataManager.saveDesign(
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
        
        if success {
            fetchDesigns()
        }
    }
    
    // MARK: - Delete Design
    func deleteDesign(_ design: LEDDesignEntity) {
        let success = coreDataManager.deleteDesign(design)
        if success {
            fetchDesigns()
        }
    }
    
    // MARK: - Delete All
    func deleteAllDesigns() {
        let success = coreDataManager.deleteAllDesigns()
        if success {
            fetchDesigns()
        }
    }
    
    // MARK: - Setup Notification Observer
    private func setupNotificationObserver() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchDesigns()
                }
            }
            .store(in: &cancellables)
    }
}
