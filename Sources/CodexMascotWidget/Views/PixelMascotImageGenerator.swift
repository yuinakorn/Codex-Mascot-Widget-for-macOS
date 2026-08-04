import AppKit
import SwiftUI

public class PixelMascotImageGenerator {
    public static func generateNSImage(usagePercentage: Double, isError: Bool = false, size: CGFloat = 18.0) -> NSImage {
        let emotion = MascotEmotion.emotion(for: usagePercentage, isError: isError)
        let img = NSImage(size: NSSize(width: size, height: size))
        
        img.lockFocus()
        guard let context = NSGraphicsContext.current?.cgContext else {
            img.unlockFocus()
            return img
        }
        
        // 12 cols x 12 rows Mini Pixel Grid matching Blue Cloud Mascot
        // 1 = Outline, 2 = Cloud Blue, 5 = Screen, 6 = Cyan (> _), 9 = Feet
        let grid: [[Int]] = [
            [0,0,1,1,1,1,1,1,0,0],
            [0,1,2,2,2,2,2,2,1,0],
            [1,2,1,1,1,1,1,1,2,1],
            [1,2,1,5,5,5,5,1,2,1],
            [1,2,1,6,5,6,6,1,2,1], // Screen with > _
            [1,2,1,5,6,5,5,1,2,1],
            [1,2,1,1,1,1,1,1,2,1],
            [0,1,2,2,2,2,2,2,1,0],
            [0,1,1,9,1,1,9,1,1,0],
            [0,0,1,1,0,0,1,1,0,0],
        ]
        
        let cols = 10
        let rows = grid.count
        let pixelWidth = size / CGFloat(cols)
        let pixelHeight = size / CGFloat(rows)
        
        for r in 0..<rows {
            for c in 0..<cols {
                let val = grid[r][c]
                if val > 0 {
                    let rect = CGRect(
                        x: CGFloat(c) * pixelWidth,
                        y: size - CGFloat(r + 1) * pixelHeight,
                        width: pixelWidth + 0.3,
                        height: pixelHeight + 0.3
                    )
                    
                    switch val {
                    case 1: context.setFillColor(CGColor(red: 0.05, green: 0.07, blue: 0.12, alpha: 1.0))
                    case 2: context.setFillColor(CGColor(red: 0.26, green: 0.43, blue: 0.92, alpha: 1.0))
                    case 5: context.setFillColor(CGColor(red: 0.09, green: 0.11, blue: 0.18, alpha: 1.0))
                    case 6: context.setFillColor(CGColor(red: 0.30, green: 0.89, blue: 0.98, alpha: 1.0))
                    case 9: context.setFillColor(CGColor(red: 0.15, green: 0.27, blue: 0.68, alpha: 1.0))
                    default: break
                    }
                    context.fill(rect)
                }
            }
        }
        
        img.unlockFocus()
        img.isTemplate = false
        return img
    }
}
