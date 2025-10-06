//
//  GIFImageView.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 04/10/25.
//




import SwiftUI
import Gifu

struct GifuGIFView: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> GIFImageView {
        let imageview = GIFImageView()
        imageview.contentMode = .scaleAspectFill  // Use aspectFill, not scaleToFill
        imageview.clipsToBounds = true
        imageview.animate(withGIFNamed: name)
        return imageview
    }
    
    func updateUIView(_ uiView: GIFImageView, context: Context) {
        uiView.animate(withGIFNamed: name)
    }
}
