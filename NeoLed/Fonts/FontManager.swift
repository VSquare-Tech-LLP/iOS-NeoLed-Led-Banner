//
//  FontManager.swift
//  EveCraft
//
//  Created by Purvi Sancheti on 26/08/25.
//

import Foundation
import SwiftUI

struct FontManager {
    
    static var bricolageGrotesqueRegularFont = "BricolageGrotesque-Regular"
    static var bricolageGrotesqueMediumFont = "BricolageGrotesque-Medium"
    static var bricolageGrotesqueSemiBoldFont = "HanBricolageGrotesquekenGrotesk-SemiBold"
    static var bricolageGrotesqueBoldFont = "BricolageGrotesque-Bold"
    static var bricolageGrotesqueLightFont = "BricolageGrotesque-Light"
    static var bricolageGrotesqueExtraBold = "BricolageGrotesque-ExtraBold"
    
    static var arvoBoldFont = "Arvo-Bold"
    static var arvoItalicFont = "Arvo-Italic"
    static var arvoRegularFont = "Arvo-Regular"
    static var arvoBoldItalicFont = "Arvo-BoldItalic"
    
    static var balsamiqSansBoldFont = "BalsamiqSans-Bold"
    static var balsamiqSansItalicFont = "BalsamiqSans-Italic"
    static var balsamiqSansRegularFont = "BalsamiqSans-Regular"
    static var balsamiqSansBoldItalicFont = "BalsamiqSans-BoldItalic"
    
    static var dmSerifDisplayRegularFont = "DMSerifDisplay-Regular"
    static var dmSerifDisplayItalicFont = "DMSerifDisplay-Italic"

    static var dotoBoldFont = "Doto-Bold"
    static var dotoRegularFont = "Doto-Regular"
    
    static var dynaPuffBold = "DynaPuff-Bold"
    static var dynaPuffRegular = "DynaPuff-Regular"
    
    static var economicaBoldFont = "Economica-Bold"
    static var economicaItalicFont = "Economica-Italic"
    static var economicaRegularFont = "Economica-Regular"
    static var economicaBoldItalicFont = "Economica-BoldItalic"
    
    static var lobsterTwoBoldFont = "LobsterTwo-Bold"
    static var lobsterTwoItalicFont = "LobsterTwo-Italic"
    static var lobsterTwoRegularFont = "LobsterTwo-Regular"
    static var lobsterTwoBoldItalicFont = "LobsterTwo-BoldItalic"
    
    static var montserratBoldFont = "Montserrat-Bold"
    static var montserratItalicFont = "Montserrat-Italic"
    static var montserratRegularFont = "Montserrat-Regular"
    static var montserratBoldItalicFont = "Montserrat-BoldItalic"
    
    static var nunitoBoldFont = "Nunito-Bold"
    static var nunitoItalicFont = "Nunito-Italic"
    static var nunitoRegularFont = "Nunito-Regular"
    static var nunitoBoldItalicFont = "Nunito-BoldItalic"
    
    static var openSansBoldFont = "OpenSans-Bold"
    static var openSansItalicFont = "OpenSans-Italic"
    static var openSansRegularFont = "OpenSans-Regular"
    static var openSansBoldItalicFont = "OpenSans-BoldItalic"
    
    static var poppinsBoldFont = "Poppins-Bold"
    static var poppinsItalicFont = "Poppins-Italic"
    static var poppinsRegularFont = "Poppins-Regular"
    static var poppinsBoldItalicFont = "Poppins-BoldItalic"
    
    static var ralewayBoldFont = "Raleway-Bold"
    static var ralewayItalicFont = "Raleway-Italic"
    static var ralewayRegularFont = "Raleway-Regular"
    static var ralewayBoldItalicFont = "Raleway-BoldItalic"
    
    static var ribeyeRegularFont = "Ribeye-Regular"
    
    static var robotoBoldFont = "Roboto-Bold"
    static var robotoItalicFont = "Roboto-Italic"
    static var robotoRegularFont = "Roboto-Regular"
    static var robotoBoldItalicFont = "Roboto-BoldItalic"
    
    static var zillaSlabBoldFont = "ZillaSlab-Bold"
    static var zillaSlabItalicFont = "ZillaSlab-Italic"
    static var zillaSlabRegularFont = "ZillaSlab-Regular"
    static var zillaSlabBoldItalicFont = "ZillaSlab-BoldItalic"

    // MARK: - BricolageGrotesque
    

    static func bricolageGrotesqueRegularFont(size: CGFloat) -> Font {
        .custom(bricolageGrotesqueRegularFont, size: size)
    }
    static func bricolageGrotesqueBoldFont(size: CGFloat) -> Font {
        .custom(bricolageGrotesqueBoldFont, size: size)
    }
    static func bricolageGrotesqueSemiBoldFont(size: CGFloat) -> Font {
        .custom(bricolageGrotesqueSemiBoldFont, size: size)
    }
    static func bricolageGrotesqueMediumFont(size: CGFloat) -> Font {
        .custom(bricolageGrotesqueMediumFont, size: size)
    }
    static func bricolageGrotesqueLightFont(size: CGFloat) -> Font {
        .custom(bricolageGrotesqueLightFont, size: size)
    }

    static func bricolageGrotesqueExtraBold(size: CGFloat) -> Font {
        .custom(bricolageGrotesqueExtraBold, size: size)
    }

    // MARK: - Arvo

    static func arvoBoldFont(size: CGFloat) -> Font {
        .custom(arvoBoldFont, size: size)
    }
    static func arvoItalicFont(size: CGFloat) -> Font {
        .custom(arvoItalicFont, size: size)
    }
    static func arvoRegularFont(size: CGFloat) -> Font {
        .custom(arvoRegularFont, size: size)
    }
    static func arvoBoldItalicFont(size: CGFloat) -> Font {
        .custom(arvoBoldItalicFont, size: size)
    }
    // MARK: - BalsamiqSans
    
    static func balsamiqSansBoldFont(size: CGFloat) -> Font {
        .custom(balsamiqSansBoldFont, size: size)
    }
    static func balsamiqSansItalicFont(size: CGFloat) -> Font {
        .custom(balsamiqSansItalicFont, size: size)
    }
    static func balsamiqSansRegularFont(size: CGFloat) -> Font {
        .custom(balsamiqSansRegularFont, size: size)
    }
    static func balsamiqSansBoldItalicFont(size: CGFloat) -> Font {
        .custom(balsamiqSansBoldItalicFont, size: size)
    }
    
    // MARK: - DMSerifDisplay
    
    static func dmSerifDisplayRegularFont(size: CGFloat) -> Font {
        .custom(dmSerifDisplayRegularFont, size: size)
    }
    static func dmSerifDisplayItalicFont(size: CGFloat) -> Font {
        .custom(dmSerifDisplayItalicFont, size: size)
    }

    // MARK: - Doto
    
    static func dotoBoldFont(size: CGFloat) -> Font {
        .custom(dotoBoldFont, size: size)
    }
    static func dotoRegularFont(size: CGFloat) -> Font {
        .custom(dotoRegularFont, size: size)
    }
   
    // MARK: - Economica
    
    static func economicaBoldFont(size: CGFloat) -> Font {
        .custom(economicaBoldFont, size: size)
    }
    static func economicaItalicFont(size: CGFloat) -> Font {
        .custom(economicaItalicFont, size: size)
    }
    static func economicaRegularFont(size: CGFloat) -> Font {
        .custom(economicaRegularFont, size: size)
    }
    static func economicaBoldItalicFont(size: CGFloat) -> Font {
        .custom(economicaBoldItalicFont, size: size)
    }
    
    // MARK: - LobsterTwo
    
    static func lobsterTwoBoldFont(size: CGFloat) -> Font {
        .custom(lobsterTwoBoldFont, size: size)
    }
    static func lobsterTwoItalicFont(size: CGFloat) -> Font {
        .custom(lobsterTwoItalicFont, size: size)
    }
    static func lobsterTwoRegularFont(size: CGFloat) -> Font {
        .custom(lobsterTwoRegularFont, size: size)
    }
    static func lobsterTwoBoldItalicFont(size: CGFloat) -> Font {
        .custom(lobsterTwoBoldItalicFont, size: size)
    }
    
    // MARK: - Montserrat
    
    static func montserratBoldFont(size: CGFloat) -> Font {
        .custom(montserratBoldFont, size: size)
    }
    static func montserratItalicFont(size: CGFloat) -> Font {
        .custom(montserratItalicFont, size: size)
    }
    static func montserratRegularFont(size: CGFloat) -> Font {
        .custom(montserratRegularFont, size: size)
    }
    static func montserratBoldItalicFont(size: CGFloat) -> Font {
        .custom(montserratBoldItalicFont, size: size)
    }
    // MARK: - Nunito
    
    static func nunitoBoldFont(size: CGFloat) -> Font {
        .custom(nunitoBoldFont, size: size)
    }
    static func nunitoItalicFont(size: CGFloat) -> Font {
        .custom(nunitoItalicFont, size: size)
    }
    static func nunitoRegularFont(size: CGFloat) -> Font {
        .custom(nunitoRegularFont, size: size)
    }
    static func nunitoBoldItalicFont(size: CGFloat) -> Font {
        .custom(nunitoBoldItalicFont, size: size)
    }
    // MARK: - OpenSans
    
    static func openSansBoldFont(size: CGFloat) -> Font {
        .custom(openSansBoldFont, size: size)
    }
    static func openSansItalicFont(size: CGFloat) -> Font {
        .custom(openSansItalicFont, size: size)
    }
    static func openSansRegularFont(size: CGFloat) -> Font {
        .custom(openSansRegularFont, size: size)
    }
    static func openSansBoldItalicFont(size: CGFloat) -> Font {
        .custom(openSansBoldItalicFont, size: size)
    }
    
    // MARK: - Poppins
    
    static func poppinsBoldFont(size: CGFloat) -> Font {
        .custom(poppinsBoldFont, size: size)
    }
    static func poppinsItalicFont(size: CGFloat) -> Font {
        .custom(poppinsItalicFont, size: size)
    }
    static func poppinsRegularFont(size: CGFloat) -> Font {
        .custom(poppinsRegularFont, size: size)
    }
    static func poppinsBoldItalicFont(size: CGFloat) -> Font {
        .custom(poppinsBoldItalicFont, size: size)
    }
    // MARK: - Raleway
    
    static func ralewayBoldFont(size: CGFloat) -> Font {
        .custom(ralewayBoldFont, size: size)
    }
    static func ralewayItalicFont(size: CGFloat) -> Font {
        .custom(ralewayItalicFont, size: size)
    }
    static func ralewayRegularFont(size: CGFloat) -> Font {
        .custom(ralewayRegularFont, size: size)
    }
    static func ralewayBoldItalicFont(size: CGFloat) -> Font {
        .custom(ralewayBoldItalicFont, size: size)
    }
    // MARK: - Ribeye
    
    static func ribeyeRegularFont(size: CGFloat) -> Font {
        .custom(ribeyeRegularFont, size: size)
    }
    
    // MARK: - Roboto
    
    static func robotoBoldFont(size: CGFloat) -> Font {
        .custom(robotoBoldFont, size: size)
    }
    static func robotoItalicFont(size: CGFloat) -> Font {
        .custom(robotoItalicFont, size: size)
    }
    static func robotoRegularFont(size: CGFloat) -> Font {
        .custom(robotoRegularFont, size: size)
    }
    static func robotoBoldItalicFont(size: CGFloat) -> Font {
        .custom(robotoBoldItalicFont, size: size)
    }
    // MARK: - ZillaSlab
    
    static func zillaSlabBoldFont(size: CGFloat) -> Font {
        .custom(zillaSlabBoldFont, size: size)
    }
    static func zillaSlabItalicFont(size: CGFloat) -> Font {
        .custom(zillaSlabItalicFont, size: size)
    }
    static func zillaSlabRegularFont(size: CGFloat) -> Font {
        .custom(zillaSlabRegularFont, size: size)
    }

    static func zillaSlabBoldItalicFont(size: CGFloat) -> Font {
        .custom(zillaSlabBoldItalicFont, size: size)
    }
    
    
    struct FontCapabilities {
         let hasBold: Bool
         let hasItalic: Bool
     }
     
     static func getFontCapabilities(for fontName: String) -> FontCapabilities {
         switch fontName {
         // Fonts with both bold and italic
         case bricolageGrotesqueRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: false)
         case arvoRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case balsamiqSansRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case lobsterTwoRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case montserratRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case nunitoRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case openSansRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case poppinsRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case ralewayRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case robotoRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case zillaSlabRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
         case economicaRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: true)
             
         // Fonts with only bold (no italic)
         case bricolageGrotesqueBoldFont:
             return FontCapabilities(hasBold: true, hasItalic: false)
         case dotoRegularFont:
             return FontCapabilities(hasBold: true, hasItalic: false)
         case dynaPuffRegular:
             return FontCapabilities(hasBold: true, hasItalic: false)
             
         // Fonts with only italic (no bold)
         case dmSerifDisplayRegularFont:
             return FontCapabilities(hasBold: false, hasItalic: true)
             
         // Fonts with neither bold nor italic
         case ribeyeRegularFont:
             return FontCapabilities(hasBold: false, hasItalic: false)
             
         default:
             // Default to supporting both if unknown
             return FontCapabilities(hasBold: true, hasItalic: true)
         }
     }
     
     // Helper method to check if an effect is available for a font
     static func isEffectAvailable(_ effectName: String, for fontName: String) -> Bool {
         let capabilities = getFontCapabilities(for: fontName)
         
         switch effectName {
         case "Bold":
             return capabilities.hasBold
         case "Italic":
             return capabilities.hasItalic
         default:
             return true // Other effects are always available
         }
     }
    
    // Add this method to FontManager struct
    static func getFontWithEffects(baseFontName: String, isBold: Bool, isItalic: Bool) -> String {
        let capabilities = getFontCapabilities(for: baseFontName)
        
        // If both effects are requested but font doesn't support both, prioritize based on availability
        if isBold && isItalic {
            // Check if BoldItalic variant exists
            if capabilities.hasBold && capabilities.hasItalic {
                return baseFontName
                    .replacingOccurrences(of: "-Regular", with: "-BoldItalic")
            }
            // If no BoldItalic, fall back to just Bold or just Italic
            else if capabilities.hasBold {
                return baseFontName.replacingOccurrences(of: "-Regular", with: "-Bold")
            } else if capabilities.hasItalic {
                return baseFontName.replacingOccurrences(of: "-Regular", with: "-Italic")
            }
        }
        // Only bold requested
        else if isBold && capabilities.hasBold {
            return baseFontName.replacingOccurrences(of: "-Regular", with: "-Bold")
        }
        // Only italic requested
        else if isItalic && capabilities.hasItalic {
            return baseFontName.replacingOccurrences(of: "-Regular", with: "-Italic")
        }
        
        // Default to regular
        return baseFontName
    }
    
}

extension Text {
    func conditionalItalic(_ apply: Bool) -> Text {
        apply ? self.italic() : self
    }
}
