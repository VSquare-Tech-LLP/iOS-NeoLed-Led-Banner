//
//  LEDTemplate Model.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 07/10/25.
//


import SwiftUI

struct LEDTemplate: Identifiable {
    let id = UUID()
    let imageName: String
    let backgroundImage: String  // Background image name
    let selectedFont: String
    let text: String
    let textSize: CGFloat
    let customTextColorHex: String?  // NEW: Add this
    let strokeSize: CGFloat?  // Optional
    let strokeColorId: String?  // Keep this for stroke (predefined colors)
    let isBold: Bool
    let isItalic: Bool
    let backgroundResultImage: String
}

// Template Data Manager
class TemplateDataManager {
    static let shared = TemplateDataManager()
    
    private init() {}
    
    // Get template data for each image
    func getTemplate(for imageName: String) -> LEDTemplate {
        switch imageName {
        // LED Templates
        case "l1":
            return LEDTemplate(
                imageName: "LED1",
                backgroundImage: "l1",
                selectedFont: FontManager.dmSerifDisplayRegularFont,
                text: "Hello",
                textSize: 6.2,
                customTextColorHex: "#FFFFFF",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: false,
                isItalic: true,
                backgroundResultImage: "lr1"
            )
        
        case "l2":
            return LEDTemplate(
                imageName: "LED2",
                backgroundImage: "l2",
                selectedFont: FontManager.dotoRegularFont,
                text: "LETS DANCE",
                textSize: 4.8,
                customTextColorHex: "#FFFFFF",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "lr2"
            )
        
        case "l3":
            return LEDTemplate(
                imageName: "LED3",
                backgroundImage: "l3",
                selectedFont: FontManager.poppinsRegularFont,
                text: "DJ NIGHT",
                textSize: 4.8,
                customTextColorHex: "#FFFFFF",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "lr3"
            )
        
        case "l4":
            return LEDTemplate(
                imageName: "LED4",
                backgroundImage: "l4",
                selectedFont: FontManager.lobsterTwoRegularFont,
                text: "Party",
                textSize: 4.8,
                customTextColorHex: "#FFFFFF",
                strokeSize: 7.0,
                strokeColorId: "outlineBabyPink",
                isBold: true,
                isItalic: false,
                backgroundResultImage: "lr4"
            )
        
        case "l5":
            return LEDTemplate(
                imageName: "LED5",
                backgroundImage: "l5",
                selectedFont: FontManager.poppinsRegularFont,
                text: "BELIEVE",
                textSize: 4.8,
                customTextColorHex: "#FFFFFF",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "lr5"
            )
        
        case "l6":
            return LEDTemplate(
                imageName: "LED6",
                backgroundImage: "l6",
                selectedFont: FontManager.robotoRegularFont,
                text: "WELCOME",
                textSize: 4.8,
                customTextColorHex: "#FF9D14",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "lr6"
            )
        
        // Business Templates
        case "b1":
            return LEDTemplate(
                imageName: "business1",
                backgroundImage: "b1",
                selectedFont: FontManager.ralewayRegularFont,
                text: "AUTOMN SALE",
                textSize: 4.2,
                customTextColorHex: "##002B5F",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "br1"
            )
        
        case "b2":
            return LEDTemplate(
                imageName: "business2",
                backgroundImage: "b2",
                selectedFont: FontManager.montserratRegularFont,
                text: "BUY 1 GET 1",
                textSize: 4.2,
                customTextColorHex: "#FFFFFF",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "br2"
            )
        
        case "b3":
            return LEDTemplate(
                imageName: "business3",
                backgroundImage: "b3",
                selectedFont: FontManager.poppinsRegularFont,
                text: "OPEN",
                textSize: 6.8,
                customTextColorHex: "#0067E0",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "br3"
            )
        
        case "b4":
            return LEDTemplate(
                imageName: "business4",
                backgroundImage: "b4",
                selectedFont: FontManager.balsamiqSansRegularFont,
                text: "Happy Hour",
                textSize: 4.2,
                customTextColorHex: "#FFFFFF",
                strokeSize: 2.0,
                strokeColorId: "outlineBlue",
                isBold: true,
                isItalic: false,
                backgroundResultImage: "br4"
                
            )
        
        case "b5":
            return LEDTemplate(
                imageName: "business5",
                backgroundImage: "b5",
                selectedFont: FontManager.nunitoRegularFont,
                text: "SALE LIVE",
                textSize: 4.2,
                customTextColorHex: "#FFFFFF",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "br5"
            )
        
        // Holidays Templates
        case "h1":
            return LEDTemplate(
                imageName: "holiday1",
                backgroundImage: "h1",
                selectedFont: FontManager.ribeyeRegularFont,
                text: "Happy Halloween",
                textSize: 2.5,
                customTextColorHex: "#000000",
                strokeSize: 1.0,
                strokeColorId: "outlineWhite",
                isBold: false,
                isItalic: false,
                backgroundResultImage: "hr1"
            )
        
        case "h2":
            return LEDTemplate(
                imageName: "holiday2",
                backgroundImage: "h2",
                selectedFont: FontManager.arvoRegularFont,
                text: "Thank You",
                textSize: 3.5,
                customTextColorHex: "#4B725F",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "hr2"
            )
        
        case "h3":
            return LEDTemplate(
                imageName: "holiday3",
                backgroundImage: "h3",
                selectedFont: FontManager.dynaPuffRegular,
                text: "Happy Valentine’s",
                textSize: 3.0,
                customTextColorHex: "#FFFFFF",
                strokeSize: 2.0,
                strokeColorId: "outlineDarkRed",
                isBold: false,
                isItalic: false,
                backgroundResultImage: "hr3"
            )
        
        case "h4":
            return LEDTemplate(
                imageName: "holiday4",
                backgroundImage: "h4",
                selectedFont: FontManager.lobsterTwoRegularFont,
                text: "Merry Christmas",
                textSize: 2.5,
                customTextColorHex: "#104506",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: false,
                isItalic: true,
                backgroundResultImage: "hr4"
            )
        
        case "h5":
            return LEDTemplate(
                imageName: "holiday5",
                backgroundImage: "h5",
                selectedFont: FontManager.ralewayRegularFont,
                text: "Happy New Year",
                textSize: 3.5,
                customTextColorHex: "#CB6B09",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "hr5"
            )
        
        case "h6":
            return LEDTemplate(
                imageName: "holiday6",
                backgroundImage: "h6",
                selectedFont: FontManager.ralewayRegularFont,
                text: "Winter",
                textSize: 5.2,
                customTextColorHex: "#FFFFFF",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "hr6"
            )
        
        // Celebrations Templates
        case "c1":
            return LEDTemplate(
                imageName: "celebrational1",
                backgroundImage: "c1",
                selectedFont: FontManager.poppinsRegularFont,
                text: "Congratulations",
                textSize: 3.3,
                customTextColorHex: "#FF826F",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "cr1"
            )
        
        case "c2":
            return LEDTemplate(
                imageName: "celebrational2",
                backgroundImage: "c2",
                selectedFont: FontManager.dotoRegularFont,
                text: "Happy Birthday",
                textSize: 3.2,
                customTextColorHex: "#FFFFFF",
                strokeSize: 2.0,
                strokeColorId: "outlineDarkRed",
                isBold: true,
                isItalic: false,
                backgroundResultImage: "cr2"
            )
        
        case "c3":
            return LEDTemplate(
                imageName: "celebrational3",
                backgroundImage: "c3",
                selectedFont: FontManager.lobsterTwoRegularFont,
                text: "Engagement",
                textSize: 2.4,
                customTextColorHex: "#E1BA5C",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "cr3"
            )
        
        case "c4":
            return LEDTemplate(
                imageName: "celebrational4",
                backgroundImage: "c4",
                selectedFont: FontManager.dynaPuffRegular,
                text: "Baby Shower",
                textSize: 3.5,
                customTextColorHex: "#6B98F2",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "cr4"
            )
        
        case "c5":
            return LEDTemplate(
                imageName: "celebrational5",
                backgroundImage: "c5",
                selectedFont: FontManager.dmSerifDisplayRegularFont,
                text: "Wedding",
                textSize: 3.8,
                customTextColorHex: "#6B98F2",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: false,
                isItalic: true,
                backgroundResultImage: "cr5"
            )
        
        // Informational Templates
        case "i1":
            return LEDTemplate(
                imageName: "informational1",
                backgroundImage: "i1",
                selectedFont: FontManager.economicaRegularFont,
                text: "WELCOME",
                textSize: 6.0,
                customTextColorHex: "#FFFFFF",
                strokeSize: 1.5,
                strokeColorId: "outlineBabyPink",
                isBold: false,
                isItalic: false,
                backgroundResultImage: "ir1"
            )
        
        case "i2":
            return LEDTemplate(
                imageName: "informational2",
                backgroundImage: "i2",
                selectedFont: FontManager.poppinsRegularFont,
                text: "EXIT",
                textSize: 6.0,
                customTextColorHex: "#FFFFFF",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "ir2"
            )
        
        case "i3":
            return LEDTemplate(
                imageName: "informational3",
                backgroundImage: "i3",
                selectedFont: FontManager.poppinsRegularFont,
                text: "STOP",
                textSize: 6.0,
                customTextColorHex: "#E94444",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "ir3"
            )
        
        case "i4":
            return LEDTemplate(
                imageName: "informational4",
                backgroundImage: "i4",
                selectedFont: FontManager.poppinsRegularFont,
                text: "WARNNING",
                textSize: 4.2,
                customTextColorHex: "#000000",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "ir4"
            )
        
        case "i5":
            return LEDTemplate(
                imageName: "informational5",
                backgroundImage: "i5",
                selectedFont: FontManager.poppinsRegularFont,
                text: "ENTRY",
                textSize: 4.2,
                customTextColorHex: "#FF0000",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: true,
                isItalic: false,
                backgroundResultImage: "ir5"
            )
        
        // Default template
        default:
            return LEDTemplate(
                imageName: "LED1",
                backgroundImage: "l1",
                selectedFont: FontManager.dmSerifDisplayRegularFont,
                text: "Hello",
                textSize: 6.2,
                customTextColorHex: "#FFFFFF",
                strokeSize: nil,
                strokeColorId: nil,
                isBold: false,
                isItalic: true,
                backgroundResultImage: "lr1"
            )
        }
    }
}
