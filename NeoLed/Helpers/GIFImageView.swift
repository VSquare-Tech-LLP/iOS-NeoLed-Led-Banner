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


import UIKit
import ImageIO

class GIFFrameManager {
    static let instance = GIFFrameManager()  // Changed from 'shared' to 'instance'
    private var frameCache: [String: [UIImage]] = [:]
    
    private init() {}
    
    func getFrames(for gifName: String) -> [UIImage] {
        // Return cached frames if available
        if let cachedFrames = frameCache[gifName] {
            print("Using cached frames for: \(gifName)")
            return cachedFrames
        }
        
        // Extract frames if not cached
        let frames = extractFrames(from: gifName)
        frameCache[gifName] = frames
        print("Extracted and cached \(frames.count) frames for: \(gifName)")
        return frames
    }
    
    private func extractFrames(from gifName: String) -> [UIImage] {
        // Try different extensions
        let extensions = ["gif", "GIF"]
        
        for ext in extensions {
            if let gifPath = Bundle.main.path(forResource: gifName, ofType: ext),
               let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
               let source = CGImageSourceCreateWithData(gifData as CFData, nil) {
                
                let frameCount = CGImageSourceGetCount(source)
                var frames: [UIImage] = []
                
                for i in 0..<frameCount {
                    if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                        frames.append(UIImage(cgImage: cgImage))
                    }
                }
                
                if !frames.isEmpty {
                    return frames
                }
            }
        }
        
        print("Warning: Failed to load GIF '\(gifName)'")
        return []
    }
    
    func clearCache() {
        frameCache.removeAll()
        print("GIF frame cache cleared")
    }
    
    func getFrameDurations(for gifName: String) -> [Double] {
        guard let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif"),
              let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            return []
        }
        
        let frameCount = CGImageSourceGetCount(source)
        var durations: [Double] = []
        
        for i in 0..<frameCount {
            var frameDuration: Double = 0.1 // Default duration
            
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                
                if let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double {
                    frameDuration = delayTime
                } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double {
                    frameDuration = delayTime
                }
            }
            
            durations.append(frameDuration)
        }
        
        return durations
    }
    
    func getTotalDuration(for gifName: String) -> Double {
        let durations = getFrameDurations(for: gifName)
        return durations.reduce(0, +)
    }
}
