

import Foundation
import SwiftUI

struct TryProContainerView: View {
    
    @State var isShowPayWall: Bool = false
    let notificationfeedback = UINotificationFeedbackGenerator()
    let impactfeedback = UIImpactFeedbackGenerator(style: .heavy)
    let selectionfeedback = UISelectionFeedbackGenerator()
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var isProContainerButtonPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                impactfeedback.impactOccurred()
                if !purchaseManager.hasPro {
                    isShowPayWall = true
                }
            } label: {
                HStack {
                    VStack(alignment: .leading,spacing:ScaleUtility.scaledSpacing(4)) {
                    
                        Text("Access All Features")
                            .font(FontManager.bricolageGrotesqueMediumFont(size: .scaledFontSize(16)))
                            .foregroundColor(Color.secondaryApp)
                        
                        Text("Upgrade to pro")
                            .font(FontManager.bricolageGrotesqueRegularFont(size: .scaledFontSize(12)))
                            .foregroundColor(Color.secondaryApp.opacity(0.8))
                        
                    }
                    .padding(.leading,ScaleUtility.scaledSpacing(20))
                    
                    Spacer()
                    
                    Image(.tryProIcon)
                        .resizable()
                        .frame(width:ScaleUtility.scaledValue(107.0396),
                               height:  ScaleUtility.scaledValue(35))
                        .padding(.trailing,ScaleUtility.scaledSpacing(15.44))
                    
                }
                .frame(maxWidth: .infinity)
                .background {
                    Color.accent
                        .frame(maxWidth: .infinity)
                        .frame(height: ScaleUtility.scaledValue(67))
                        .cornerRadius(10)
                }
                .padding(.horizontal,ScaleUtility.scaledSpacing(15))
                
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isProContainerButtonPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isProContainerButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation {
                            isProContainerButtonPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            isProContainerButtonPressed = false
                        }
                    }
            )
            .fullScreenCover(isPresented: $isShowPayWall) {
                
                PaywallView(isInternalOpen: true) {
                    isShowPayWall = false
                } purchaseCompletSuccessfullyAction: {
                    isShowPayWall = false
                }
            }
        }
        .padding(.top, ScaleUtility.scaledSpacing(30))
    }
}

