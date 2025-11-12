//
//  UserCommentsView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 25/09/25.
//

import Foundation
import SwiftUI

struct UserCommentsView: View {
    var isActive: Bool
    
    @State var isShowImage: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Image(.userCommentVew)
                .resizable()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .scaleEffect(isShowImage ? 1.0 : 0.5)
                .opacity(isShowImage ? 1.0 : 0.0)
                
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                performAnimation()
            }
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
