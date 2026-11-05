#!/usr/bin/env swift
// Renders the app icon PNGs into both asset catalogs. Run from the repo root: swift scripts/make-app-icons.swift
// The mark is two chunky tiles clinking (the drink button's shape) with two bubbles rising from where they meet.
// Colors come from Shared/Palette.swift (see DESIGN.md).
import AppKit
import UniformTypeIdentifiers

struct Look {
    let file: String
    let background: UInt32
    let left: UInt32
    let right: UInt32
    let water: UInt32
    let bubble: UInt32
}

let looks = [
    Look(file: "AppIcon.png", background: 0xFF5C39, left: 0xFFF7EC, right: 0xFFB81C, water: 0x4FD8FF, bubble: 0xB98CFF),
    Look(file: "AppIcon-dark.png", background: 0x000000, left: 0xFF5C39, right: 0xFFB81C, water: 0x4FD8FF, bubble: 0xB98CFF),
    // iOS recolors the tinted icon from its brightness, so the four shapes differ in gray, not hue.
    Look(file: "AppIcon-tinted.png", background: 0x000000, left: 0xFFFFFF, right: 0x8C8C8C, water: 0xD0D0D0, bubble: 0x6A6A6A),
]
let phone = "Clinkr/Assets.xcassets/AppIcon.appiconset"
let watch = "Clinkr Watch App/Assets.xcassets/AppIcon.appiconset"

func color(_ hex: UInt32) -> CGColor {
    let c = [CGFloat((hex >> 16) & 0xFF) / 255, CGFloat((hex >> 8) & 0xFF) / 255, CGFloat(hex & 0xFF) / 255, 1]
    return CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: c)!
}

func render(_ look: Look) -> Data {
    let size = 1024
    // noneSkipLast gives a PNG with no alpha channel, which the App Store requires for icons.
    let ctx = CGContext(
        data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setFillColor(color(look.background))
    ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
    // Coordinates below are from the top left; the whole mark stays inside the Watch's circular crop.
    func tile(_ x: CGFloat, _ y: CGFloat, _ angle: CGFloat, _ hex: UInt32) {
        ctx.saveGState()
        ctx.translateBy(x: x, y: CGFloat(size) - y)
        ctx.rotate(by: angle)
        ctx.setFillColor(color(hex))
        ctx.addPath(CGPath(roundedRect: CGRect(x: -170, y: -170, width: 340, height: 340), cornerWidth: 100, cornerHeight: 100, transform: nil))
        ctx.fillPath()
        ctx.restoreGState()
    }
    func bubble(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ hex: UInt32) {
        ctx.setFillColor(color(hex))
        ctx.fillEllipse(in: CGRect(x: x - r, y: CGFloat(size) - y - r, width: 2 * r, height: 2 * r))
    }
    tile(350, 620, 0.2, look.left)
    tile(694, 590, -0.2, look.right)
    bubble(505, 345, 90, look.water)
    bubble(660, 265, 58, look.bubble)
    let data = NSMutableData()
    let dest = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
    CGImageDestinationFinalize(dest)
    return data as Data
}

// The Watch has one icon; the iPhone also gets dark and tinted.
for look in looks { try render(look).write(to: URL(fileURLWithPath: "\(phone)/\(look.file)")) }
try render(looks[0]).write(to: URL(fileURLWithPath: "\(watch)/AppIcon.png"))
