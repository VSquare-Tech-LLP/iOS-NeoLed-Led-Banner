//
//  ColorOption.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 29/09/25.
//

import SwiftUI

struct ColorOption: Identifiable {
    let id: String
    let name: String
    let type: ColorType
    
    enum ColorType {
        case solid(Color)
        case linearGradient(LinearGradientData)
    }
    
    struct LinearGradientData {
        let stops: [Gradient.Stop]
        let startPoint: UnitPoint
        let endPoint: UnitPoint
        
        var gradient: LinearGradient {
            LinearGradient(
                stops: stops,
                startPoint: startPoint,
                endPoint: endPoint
            )
        }
    }
    
    // Get the view for color picker display
    @ViewBuilder
    func colorPreview(size: CGFloat = 28) -> some View {
        switch type {
        case .solid(let color):
            Rectangle()
                .foregroundColor(color)
                .frame(width: size, height: size)
                .cornerRadius(5.83333)
                
        case .linearGradient(let gradientData):
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: size, height: size)
                .background(gradientData.gradient)
                .cornerRadius(5)
        }
    }
    
    // Apply color to text
    @ViewBuilder
    func applyToText<Content: View>(_ content: Content) -> some View {
        switch type {
        case .solid(let color):
            content.foregroundColor(color)
            
        case .linearGradient(let gradientData):
            content.foregroundStyle(gradientData.gradient)
        }
    }
}

// MARK: - Predefined Colors
extension ColorOption {
    static let predefinedColors: [ColorOption] = [
        // Solid Colors
        ColorOption(
            id: "white",
            name: "White",
            type: .solid(Color.white)
        ),
        
        ColorOption(
            id: "White",
            name: "white",
            type: .solid(Color.white)
        ),
        
        
        ColorOption(
            id: "yellow",
            name: "Yellow",
            type: .solid(Color.appYellow)
        ),
        
//        ColorOption(
//            id: "lightRed",
//            name: "Light Red",
//            type: .solid(Color.appLightRed)
//        ),
        
        ColorOption(
            id: "cyan",
            name: "cyan",
            type: .solid(Color.appCyan)
        ),
        
        ColorOption(
            id: "limeGreen",
            name: "limeGreen",
            type: .solid(Color.appLimeGreen)
        ),
        
        ColorOption(
            id: "indigoBlue",
            name: "indigoBlue",
            type: .solid(Color.appIndigoBlue)
        ),
        
        ColorOption(
            id: "persian",
            name: "persian",
            type: .solid(Color.appPersian)
        ),
        
        ColorOption(
            id: "orange",
            name: "orange",
            type: .solid(Color.appOrange)
        ),
        
        ColorOption(
            id: "darkBlue",
            name: "darkBlue",
            type: .solid(Color.appDarkBlue)
        ),
        
        ColorOption(
            id: "red",
            name: "red",
            type: .solid(Color.appRed)
        ),
        
        ColorOption(
            id: "pink",
            name: "pink",
            type: .solid(Color.appPink)
        ),
        
        ColorOption(
            id: "purple",
            name: "purple",
            type: .solid(Color.appPurple)
        ),
        
        // Linear Gradients
        ColorOption(
            id: "blueGreen",
            name: "bluegreen",
            type: .linearGradient(
                LinearGradientData(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.32, green: 0.5, blue: 0.73), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.23, green: 0.69, blue: 0.43), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
                
            )
        ),
        
        ColorOption(
            id: "creamRed",
            name: "creamred",
            type: .linearGradient(
                LinearGradientData(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.92, green: 0.72, blue: 0.72), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.98, green: 0.42, blue: 0.42), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        ),
        
        ColorOption(
            id: "pinkPurple",
            name: "pinkPurple",
            type: .linearGradient(
                LinearGradientData(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.98, green: 0.18, blue: 0.71), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.19, green: 0, blue: 0.51), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
                
            )
        ),
        
        ColorOption(
            id: "pinkCream",
            name: "pinkCream",
            type: .linearGradient(
                LinearGradientData(
                    stops: [
                        Gradient.Stop(color: Color(red: 1, green: 0.72, blue: 0.81), location: 0.00),
                        Gradient.Stop(color: Color(red: 1, green: 0.85, blue: 0.58), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        ),
        
        ColorOption(
            id: "orangePurple",
            name: "orangePurple",
            type: .linearGradient(
                LinearGradientData(
                    stops: [
                        Gradient.Stop(color: Color(red: 1, green: 0.57, blue: 0.39), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.69, green: 0.57, blue: 0.93), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        ),
        
        ColorOption(
            id: "yellowOrange",
            name: "yellowOrange",
            type: .linearGradient(
                LinearGradientData(
                    stops: [
                        Gradient.Stop(color: Color(red: 1, green: 0.92, blue: 0.19), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.92, green: 0.63, blue: 0.17), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
                
            )
        ),
        
        ColorOption(
            id: "lightPurple",
            name: "lightPurple",
            type: .linearGradient(
                LinearGradientData(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.9, green: 0.78, blue: 0.98), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.65, green: 0.26, blue: 0.87), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        ),
        
        ColorOption(
            id: "darkGreen",
            name: "darkGreen",
            type: .linearGradient(
                LinearGradientData(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.45, green: 1, blue: 0.33), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.27, green: 0.6, blue: 0.2), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        ),
        
        ColorOption(
            id: "mint",
            name: "Mint",
            type: .linearGradient(
                LinearGradientData(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.4, green: 0.98, blue: 0.88), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.25, green: 0.84, blue: 0.56), location: 1.00)
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        )
    ]
}
