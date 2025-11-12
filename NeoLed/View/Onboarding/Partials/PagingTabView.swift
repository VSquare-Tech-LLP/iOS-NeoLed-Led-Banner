//
//  PagingTabView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 25/09/25.
//

import Foundation
import SwiftUI


struct PagingTabView<Content: View>: View {
    @Binding var selectedIndex: Int
    let tabCount: Int
    let spacing: CGFloat
    var indicatorRequired: Bool = true
    let content: () -> Content
    var buttonAction: () -> Void

    @State private var isPressed = false
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    
    var body: some View {
        ZStack(alignment:.top) {
            
            //Custom Page Indicator
            
            // TabView with Paging Style
            TabView(selection: $selectedIndex) {
                content()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default dots
            
            HStack(spacing: ScaleUtility.scaledSpacing(10)) {
                HStack(spacing: ScaleUtility.scaledSpacing(8)) {
                    ForEach(0..<tabCount, id: \.self) { index in
                        Group {
                            if selectedIndex == index {
                                
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: ScaleUtility.scaledValue(14.90671), height: ScaleUtility.scaledValue(5))
                                    .background(Color.accent)
                                    .cornerRadius(5)
                                
                            } else {
                                Circle()
                                    .frame(width: ScaleUtility.scaledValue(5),height: ScaleUtility.scaledValue(5))
                                    .foregroundColor(Color.primaryApp.opacity(0.35))
                            }
                        }
                    }
                }
                .padding(.top, isIPad ? ScaleUtility.scaledSpacing(40) :  ScaleUtility.scaledSpacing(64))
                
            }
            .animation(.easeInOut, value: selectedIndex)
            .frame(maxWidth: .infinity)
            .padding(.bottom, isSmallDevice ? ScaleUtility.scaledSpacing(20) : ScaleUtility.scaledSpacing(52))
            .zIndex(1)
            .opacity(indicatorRequired ? 1 : 0)
            
            
      
        }
        .overlay(alignment: .bottom) {
                Button(action: {
                    impactFeedback.impactOccurred()
                    buttonAction()
                }) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth:.infinity)
                        .frame(height: isIPad ?  ScaleUtility.scaledValue(52) * heightRatio : ScaleUtility.scaledValue(52) )
                        .background(Color.accent)
                        .cornerRadius(10)
                        .overlay {
                            Text(selectedIndex == 0 ? "Get Started" : "Continue")
                                .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(16)))
                                .kerning(0.16)
                                .foregroundColor(Color.secondaryApp)
                               
                        }
                        .shadow(
                            color: isPressed ? Color.black.opacity(0.1) : Color.black.opacity(0.3),
                            radius: isPressed ? 4 : 10,
                            x: 0,
                            y: isPressed ? 2 : 6
                        )
                        .scaleEffect(isPressed ? 0.96 : 1.0)
                        .offset(y: isPressed ? 2 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                        .padding(.horizontal, ScaleUtility.scaledValue(42))
                }
                .padding(.bottom, ScaleUtility.scaledSpacing(40))
                .buttonStyle(PressButtonStyle(isPressed: $isPressed))
            
        }
        .background {
                Image(.background)
                    .resizable()
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
        .edgesIgnoringSafeArea(.all)
        
    }
}

