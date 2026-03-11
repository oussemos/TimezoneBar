#!/usr/bin/swift
import AppKit

func drawIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else { image.unlockFocus(); return image }

    let margin = s * 0.04
    let faceRect = CGRect(x: margin, y: margin, width: s - margin * 2, height: s - margin * 2)
    let center = CGPoint(x: s / 2, y: s / 2)
    let radius = (s - margin * 2) / 2

    // Background circle — dark navy
    ctx.addEllipse(in: faceRect)
    ctx.setFillColor(NSColor(red: 0.09, green: 0.10, blue: 0.14, alpha: 1).cgColor)
    ctx.fillPath()

    // Subtle rim
    ctx.addEllipse(in: faceRect.insetBy(dx: 1, dy: 1))
    ctx.setStrokeColor(NSColor(red: 0.30, green: 0.45, blue: 1.00, alpha: 0.60).cgColor)
    ctx.setLineWidth(s * 0.035)
    ctx.strokePath()

    // Hour tick marks
    for i in 0..<12 {
        let angle = CGFloat(i) / 12 * .pi * 2 - .pi / 2
        let isMain = (i % 3 == 0)
        let tickLen = radius * (isMain ? 0.14 : 0.09)
        let innerR = radius * 0.84
        let outerR = innerR + tickLen
        let x1 = center.x + innerR * cos(angle)
        let y1 = center.y + innerR * sin(angle)
        let x2 = center.x + outerR * cos(angle)
        let y2 = center.y + outerR * sin(angle)
        ctx.move(to: CGPoint(x: x1, y: y1))
        ctx.addLine(to: CGPoint(x: x2, y: y2))
        ctx.setStrokeColor(NSColor(white: 1, alpha: isMain ? 0.70 : 0.35).cgColor)
        ctx.setLineWidth(s * (isMain ? 0.030 : 0.018))
        ctx.setLineCap(.round)
        ctx.strokePath()
    }

    // Hour hand — 10 o'clock
    let hourAngle: CGFloat = .pi / 2 - (.pi * 2) * (10.0 / 12.0)
    let hourLen = radius * 0.48
    ctx.move(to: center)
    ctx.addLine(to: CGPoint(x: center.x + hourLen * cos(hourAngle),
                             y: center.y + hourLen * sin(hourAngle)))
    ctx.setStrokeColor(NSColor.white.cgColor)
    ctx.setLineWidth(s * 0.075)
    ctx.setLineCap(.round)
    ctx.strokePath()

    // Minute hand — 2 o'clock (i.e. 10 minutes)
    let minuteAngle: CGFloat = .pi / 2 - (.pi * 2) * (10.0 / 60.0)
    let minuteLen = radius * 0.66
    ctx.move(to: center)
    ctx.addLine(to: CGPoint(x: center.x + minuteLen * cos(minuteAngle),
                             y: center.y + minuteLen * sin(minuteAngle)))
    ctx.setStrokeColor(NSColor.white.cgColor)
    ctx.setLineWidth(s * 0.050)
    ctx.setLineCap(.round)
    ctx.strokePath()

    // Second hand accent — blue
    let secondAngle: CGFloat = .pi / 2 - (.pi * 2) * (35.0 / 60.0)
    let secondLen = radius * 0.72
    ctx.move(to: center)
    ctx.addLine(to: CGPoint(x: center.x + secondLen * cos(secondAngle),
                             y: center.y + secondLen * sin(secondAngle)))
    ctx.setStrokeColor(NSColor(red: 0.30, green: 0.55, blue: 1.00, alpha: 1).cgColor)
    ctx.setLineWidth(s * 0.030)
    ctx.setLineCap(.round)
    ctx.strokePath()

    // Centre jewel
    let jewel = s * 0.055
    ctx.addEllipse(in: CGRect(x: center.x - jewel, y: center.y - jewel,
                               width: jewel * 2, height: jewel * 2))
    ctx.setFillColor(NSColor(red: 0.30, green: 0.55, blue: 1.00, alpha: 1).cgColor)
    ctx.fillPath()

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        fputs("Failed to write \(path)\n", stderr); return
    }
    try! png.write(to: URL(fileURLWithPath: path))
}

let iconsetDir = "AppIcon.iconset"
try! FileManager.default.createDirectory(atPath: iconsetDir,
                                         withIntermediateDirectories: true)

// iconutil expects these exact filenames
let specs: [(name: String, px: Int)] = [
    ("icon_16x16",       16),
    ("icon_16x16@2x",    32),
    ("icon_32x32",       32),
    ("icon_32x32@2x",    64),
    ("icon_128x128",    128),
    ("icon_128x128@2x", 256),
    ("icon_256x256",    256),
    ("icon_256x256@2x", 512),
    ("icon_512x512",    512),
    ("icon_512x512@2x",1024),
]

for spec in specs {
    let img = drawIcon(size: spec.px)
    writePNG(img, to: "\(iconsetDir)/\(spec.name).png")
    print("  \(spec.name).png  (\(spec.px)px)")
}

print("Done — run: iconutil -c icns AppIcon.iconset")
