// generate-icon.swift — procedural Demiurge app icon (phase: packaging).
// Draws a 1024×1024 PNG: black rounded field + white cosmos ring + a
// craftsman's compass (the Platonic Demiurge — the divine craftsman who
// shapes matter to Forms). Apple-canonical AppKit/CoreGraphics only.
//
// Usage: swift generate-icon.swift <out.png>
// Honest: this is a procedural PLACEHOLDER mark — a hand-designed icon
// can replace icon-1024.png later; install.sh re-derives the .icns from
// whatever icon-1024.png contains.

import AppKit

let side = 1024
let image = NSImage(size: NSSize(width: side, height: side))
image.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else {
    FileHandle.standardError.write(Data("no CGContext\n".utf8)); exit(1)
}
let S = CGFloat(side)
let c = S / 2

// black rounded field
ctx.setFillColor(NSColor.black.cgColor)
ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: S, height: S),
                   cornerWidth: 180, cornerHeight: 180, transform: nil))
ctx.fillPath()

// white cosmos ring
ctx.setStrokeColor(NSColor.white.cgColor)
ctx.setLineWidth(26)
let r: CGFloat = 322
ctx.strokeEllipse(in: CGRect(x: c - r, y: c - r, width: 2 * r, height: 2 * r))

// craftsman's compass — two legs from a pivot
ctx.setStrokeColor(NSColor.white.cgColor)
ctx.setLineWidth(42)
ctx.setLineCap(.round)
let apex = CGPoint(x: c, y: c + 232)
let legL = CGPoint(x: c - 188, y: c - 196)
let legR = CGPoint(x: c + 188, y: c - 196)
ctx.move(to: apex); ctx.addLine(to: legL)
ctx.move(to: apex); ctx.addLine(to: legR)
ctx.strokePath()

// cross-bar of the compass
ctx.setLineWidth(26)
ctx.move(to: CGPoint(x: c - 96, y: c - 8))
ctx.addLine(to: CGPoint(x: c + 96, y: c - 8))
ctx.strokePath()

// pivot dot
ctx.setFillColor(NSColor.white.cgColor)
ctx.fillEllipse(in: CGRect(x: apex.x - 30, y: apex.y - 30, width: 60, height: 60))

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep  = NSBitmapImageRep(data: tiff),
      let png  = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write(Data("PNG encode failed\n".utf8)); exit(1)
}
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"
do {
    try png.write(to: URL(fileURLWithPath: out))
    print("wrote \(out) (\(side)×\(side))")
} catch {
    FileHandle.standardError.write(Data("write failed: \(error.localizedDescription)\n".utf8)); exit(1)
}
