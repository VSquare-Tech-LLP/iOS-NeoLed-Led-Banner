//
//  TextShape.swift
//  NeoLed
//
//  Created by Purvi Sancheti on 06/10/25.
//

import Foundation
import SwiftUI


struct TextShape: Shape {
  var text: String
  var font: UIFont

  func path(in rect: CGRect) -> Path {
    let attr = NSAttributedString(string: text, attributes: [.font: font])
    let line = CTLineCreateWithAttributedString(attr)
    let runs = CTLineGetGlyphRuns(line) as! [CTRun]

    let path = CGMutablePath()

    for run in runs {
      let attrs = CTRunGetAttributes(run) as NSDictionary
      let runFont = attrs[kCTFontAttributeName as NSAttributedString.Key] as! CTFont

      let glyphCount = CTRunGetGlyphCount(run)
      for index in 0..<glyphCount {
        let glyphRange = CFRange(location: index, length: 1)
        var glyph = CGGlyph()
        var position = CGPoint()
        CTRunGetGlyphs(run, glyphRange, &glyph)
        CTRunGetPositions(run, glyphRange, &position)
        if let letter = CTFontCreatePathForGlyph(runFont, glyph, nil) {
          var t = CGAffineTransform(translationX: position.x, y: position.y)
          path.addPath(letter, transform: t)
        }
      }
    }

    // Get bounding box for scaling and centering
    let boundingBox = path.boundingBox

    // Flip vertically to match SwiftUI coordinates
    var transform = CGAffineTransform.identity
    transform = transform
      .translatedBy(x: 0, y: rect.height)
      .scaledBy(x: 1, y: -1)

    // Center the text
    transform = transform.translatedBy(x: -boundingBox.minX, y: -boundingBox.minY)

    let finalPath = CGMutablePath()
    finalPath.addPath(path, transform: transform)

    return Path(finalPath)
  }
}
