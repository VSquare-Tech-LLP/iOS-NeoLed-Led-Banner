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
                        .frame(height: isIPad ?  ScaleUtility.scaledValue(42) * heightRatio : ScaleUtility.scaledValue(42) )
                        .background(Color.accent)
                        .cornerRadius(10)
                        .overlay {
                            Text(selectedIndex == 0 ? "Get Started" : "Continue")
                                .font(FontManager.bricolageGrotesqueSemiBoldFont(size: .scaledFontSize(14)))
                                .kerning(0.14)
                                .foregroundColor(Color.secondaryApp)
                               
                        }
                        .padding(.horizontal, ScaleUtility.scaledValue(52))
                }
                .padding(.bottom, ScaleUtility.scaledSpacing(36))
                .buttonStyle(.plain)
            
        }
        .background {
          
                Image(.background)
                    .resizable()
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
            
        }
        .edgesIgnoringSafeArea(.all)
        
    }
}

