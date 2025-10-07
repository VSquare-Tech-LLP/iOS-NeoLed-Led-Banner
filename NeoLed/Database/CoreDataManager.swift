//
//  CoreDataManager.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 02/10/25.
//

import Foundation
import CoreData
import SwiftUI

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    private var ctx: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
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
    ) -> Bool {
        let entity = LEDDesignEntity(context: ctx)
        entity.id = UUID()
        entity.backgroundResultImage = backgroundResultImage
        entity.backgroundImage = backgroundImage
        entity.text = text
        entity.selectedFont = selectedFont
        entity.textSize = textSize
        entity.strokeSize = strokeSize
        entity.selectedColorId = selectedColor.id
        entity.selectedOutlineColorId = selectedOutlineColor.id
        entity.selectedBgColorId = selectedBgColor.id
        entity.backgroundEnabled = backgroundEnabled
        entity.outlineEnabled = outlineEnabled
        entity.hasCustomTextColor = hasCustomTextColor
        
        // Save custom color as data
        if hasCustomTextColor {
            entity.customTextColorData = try? NSKeyedArchiver.archivedData(
                withRootObject: customTextColor,
                requiringSecureCoding: false
            )
        }
        
        // Convert Set to JSON string
        if let effectsData = try? JSONEncoder().encode(Array(selectedEffects)),
           let effectsString = String(data: effectsData, encoding: .utf8) {
            entity.selectedEffects = effectsString
        }
        
        entity.selectedAlignment = selectedAlignment
        entity.selectedShape = selectedShape
        entity.textSpeed = textSpeed
        entity.isHD = isHD
        entity.selectedLiveBg = selectedLiveBg
        entity.frameResultBg = frameResultBg
        entity.frameBg = frameBg
        entity.createdAt = Date()
        
        return saveContext()
    }
    
    // MARK: - Fetch All Designs
    func fetchAllDesigns() -> [LEDDesignEntity] {
        let request: NSFetchRequest<LEDDesignEntity> = LEDDesignEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LEDDesignEntity.createdAt, ascending: false)]
        
        do {
            return try ctx.fetch(request)
        } catch {
            print("Error fetching designs: \(error)")
            return []
        }
    }
    
    // MARK: - Delete Design
    func deleteDesign(_ design: LEDDesignEntity) -> Bool {
        ctx.delete(design)
        return saveContext()
    }
    
    // MARK: - Delete All Designs
    func deleteAllDesigns() -> Bool {
        let request: NSFetchRequest<NSFetchRequestResult> = LEDDesignEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try ctx.execute(deleteRequest)
            return saveContext()
        } catch {
            print("Error deleting all designs: \(error)")
            return false
        }
    }
    
    // MARK: - Private Helper
    private func saveContext() -> Bool {
        guard ctx.hasChanges else { return true }
        
        do {
            try ctx.save()
            return true
        } catch {
            let nsError = error as NSError
            print("Error saving context: \(nsError), \(nsError.userInfo)")
            return false
        }
    }
}

// MARK: - Helper Extensions
extension LEDDesignEntity {
    var effectsArray: [String] {
        guard let effectsString = selectedEffects,
              let data = effectsString.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return ["None"]
        }
        return array
    }
    
    var decodedCustomColor: UIColor? {
        guard let data = customTextColorData else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }
    
    func toColorOption() -> ColorOption {
        ColorOption.predefinedColors.first(where: { $0.id == selectedColorId }) ?? ColorOption.predefinedColors[1]
    }
    
    func toOutlineColor() -> OutlineColorOption {
        OutlineColorOption.predefinedOutlineColors.first(where: { $0.id == selectedOutlineColorId }) ?? OutlineColorOption.predefinedOutlineColors[0]
    }
    
    func toBgColor() -> OutlineColorOption {
        OutlineColorOption.predefinedOutlineColors.first(where: { $0.id == selectedBgColorId }) ?? OutlineColorOption.predefinedOutlineColors[0]
    }
}
// CoreDataManager.swift (or a separate extension file on LEDDesignEntity)
extension LEDDesignEntity {
    func toEffectiveTextColorOption() -> ColorOption {
        if hasCustomTextColor, let ui = decodedCustomColor {
            return ColorOption(id: "custom_text", name: "Custom", type: .solid(Color(ui)))
        } else {
            return toColorOption()
        }
    }
}
