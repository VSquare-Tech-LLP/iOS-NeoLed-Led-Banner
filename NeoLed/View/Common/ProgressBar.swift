//
//  ProgressBar.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 08/10/25.
//

import Foundation
import SwiftUI

struct ProgressBar: View {
    @Binding var progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 10)
                
                Capsule()
                    .fill(Color.blue) // You can change the color of the progress bar
                    .frame(width: geometry.size.width * CGFloat(progress), height: 10)
                    .animation(.linear(duration: 0.5), value: progress) // Smooth animation
            }
        }
    }
}
