//
//  GiftView.swift
//  iOS-Word-Vibe
//
//  Created by Darsh Viroja on 20/05/25.
//

import Foundation
import SwiftUI

struct GiftPaywallView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Binding var isCollectGift: Bool
    @State var plan = SubscriptionPlan.gift
    let closeGift: () -> Void
    let giftPurchaseComplete: () -> Void
    
    @State var isShowImage: Bool = false
    @State private var isPressed = false
    
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .medium)
    let selectionfeedback = UISelectionFeedbackGenerator()
    
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            Image(.giftScreenBg)
                .resizable()
                .frame(maxWidth:.infinity,maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                
                
                
                VStack(spacing: ScaleUtility.scaledSpacing(79)) {
                    
                    
                    
                    VStack(spacing: ScaleUtility.scaledSpacing(15)) {
                        
                        HStack {
                            
                            Spacer()
                            
                            
                            Image(.crossIcon2)
                                .resizable()
                                .frame(width: ScaleUtility.scaledValue(23), height: ScaleUtility.scaledValue(23))
                                .onTapGesture {
                                    impactfeedback.impactOccurred()
                                    AnalyticsManager.shared.log(.giftScreenXClicked)
                                    withAnimation(.easeOut(duration: 0.1)) {
                                        closeGift()
                                        
                                    }
                                }
                            
                        }
                        .padding(.trailing,ScaleUtility.scaledSpacing(20))
                        
                        Text("Congratulations!!")
                            .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(25)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.accent)
                            .offset(y:-ScaleUtility.scaledSpacing(8))
                        
                        Text("We have a\n gift for\n you!")
                            .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(45)))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.primaryApp)
                    }
                    .offset(y:ScaleUtility.scaledSpacing(-27))
                    
                    
                    
                    Image(.giftIcon)
                        .resizable()
                        .frame(width: isIPad ? 240.25439 :  140.25439, height: isIPad ? 250.26335 : 150.26335)
                        .scaleEffect(isShowImage ? 1.0 : 0.5)
                        .opacity(isShowImage ? 1.0 : 0.0)
                    
                    
                }
                
                Spacer()
                
            }
            .padding(.top,ScaleUtility.scaledSpacing(50))
            
           
            
            Button {
                self.isCollectGift = true
                impactfeedback.impactOccurred()
                
            } label: {
                
                Text("Collect Gift")
                    .font(FontManager.bricolageGrotesqueBoldFont(size: .scaledFontSize(16)))
                    .kerning(0.16)
                    .foregroundColor(Color.secondaryApp)
                    .frame(maxWidth: .infinity)
                    .frame(height: ScaleUtility.scaledValue(52))
                    .background(Color.accent)
                    .cornerRadius(10)
                    .shadow(
                        color: isPressed ? Color.black.opacity(0.1) : Color.black.opacity(0.3),
                        radius: isPressed ? 4 : 10,
                        x: 0,
                        y: isPressed ? 2 : 6
                    )
                    .scaleEffect(isPressed ? 0.96 : 1.0)
                    .offset(y: isPressed ? 2 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            }
            .buttonStyle(PressButtonStyle(isPressed: $isPressed))
            .padding(.horizontal, ScaleUtility.scaledValue(42))
            .padding(.bottom, ScaleUtility.scaledValue(10))
            
            
        }
        .blur(radius: isCollectGift ? 25 : 0 )
        .sheet(isPresented: $isCollectGift) {
            
            
            GiftPaywallCollectView(
                closeGiftSheet: {
                    self.isCollectGift = false
                    AnalyticsManager.shared.log(.giftBottomSheetXClicked)
                }, purchaseConfirm: giftPurchaseComplete)
            .frame(height: isIPad ? ScaleUtility.scaledValue(620) : ScaleUtility.scaledValue(520) )
            .background(Color.secondaryApp)
            .presentationDetents([.height( isIPad ? ScaleUtility.scaledValue(620) : ScaleUtility.scaledValue(520))])
            .presentationBackground(Color.secondaryApp)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
        }
        .onAppear {
            performAnimation()
        }
    }
    func performAnimation() {
        self.isShowImage = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.2)) {
                isShowImage = true
            }
        }
        
    }
}
