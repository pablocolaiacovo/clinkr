#!/usr/bin/env swift
// Renders the app icon PNGs into both asset catalogs. Run from the repo root: swift scripts/make-app-icons.swift
// The mark is the Watch's tally ring: five round-capped segments in the drink colors around a tap dot.
// Colors come from Shared/Palette.swift (see DESIGN.md).
import AppKit
import UniformTypeIdentifiers

struct Look {
    let file: String
    let background: UInt32
    let disc: UInt32?
    let segments: [UInt32]
    let dot: UInt32
}

// Segment order is the order of the drinks in the app: beer, wine, cocktail, shot, water.
let looks = [
    Look(
        file: "AppIcon.png", background: 0xFF5C39, disc: 0x1A1220,
        segments: [0xFFB81C, 0xE8478F, 0xC6F432, 0xB98CFF, 0x4FD8FF], dot: 0xFFF7EC),
    Look(
        file: "AppIcon-dark.png", background: 0x000000, disc: nil,
        segments: [0xFFB81C, 0xE8478F, 0xC6F432, 0xB98CFF, 0x4FD8FF], dot: 0xFF5C39),
    // iOS recolors the tinted icon from its brightness, so the segments differ in gray, not hue.
    Look(
        file: "AppIcon-tinted.png", background: 0x000000, disc: nil,
        segments: [0xE6E6E6, 0xBDBDBD, 0x949494, 0x6E6E6E, 0xFFFFFF], dot: 0xFFFFFF),
]
let phone = "Clinkr/Assets.xcassets/AppIcon.appiconset"
let watch = "Clinkr Watch App/Assets.xcassets/AppIcon.appiconset"

func color(_ hex: UInt32) -> CGColor {
    let c = [CGFloat((hex >> 16) & 0xFF) / 255, CGFloat((hex >> 8) & 0xFF) / 255, CGFloat(hex & 0xFF) / 255, 1]
    return CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: c)!
}

func render(_ look: Look) -> Data {
    let size = 1024
    let mid = CGFloat(size) / 2
    // noneSkipLast gives a PNG with no alpha channel, which the App Store requires for icons.
    let ctx = CGContext(
        data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setFillColor(color(look.background))
    ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
    // Everything sits inside a 800pt circle, so the Watch's circular crop never touches it.
    if let disc = look.disc {
        ctx.setFillColor(color(disc))
        ctx.fillEllipse(in: CGRect(x: mid - 400, y: mid - 400, width: 800, height: 800))
    }
    let radius: CGFloat = 290
    let stroke: CGFloat = 100
    let step = 2 * CGFloat.pi / CGFloat(look.segments.count)
    // The round caps stick out by half the stroke on each end, so shorten each arc to leave a visible gap.
    let capAngle = (stroke / 2) / radius
    let arc = step - 2 * capAngle - 0.2
    ctx.setLineWidth(stroke)
    ctx.setLineCap(.round)
    for (i, hex) in look.segments.enumerated() {
        let start = CGFloat.pi / 2 + capAngle + 0.1 - CGFloat(i) * step - 0.2
        ctx.setStrokeColor(color(hex))
        ctx.addArc(center: CGPoint(x: mid, y: mid), radius: radius, startAngle: start, endAngle: start - arc, clockwise: true)
        ctx.strokePath()
    }
    ctx.setFillColor(color(look.dot))
    ctx.fillEllipse(in: CGRect(x: mid - 125, y: mid - 125, width: 250, height: 250))
    let data = NSMutableData()
    let dest = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
    CGImageDestinationFinalize(dest)
    return data as Data
}

// The Watch has one icon; the iPhone also gets dark and tinted.
for look in looks { try render(look).write(to: URL(fileURLWithPath: "\(phone)/\(look.file)")) }
try render(looks[0]).write(to: URL(fileURLWithPath: "\(watch)/AppIcon.png"))
