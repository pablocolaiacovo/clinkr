#!/usr/bin/env swift
// Renders the app icon PNGs into both asset catalogs. Run from the repo root: swift scripts/make-app-icons.swift
// Colors come from Shared/Palette.swift (see DESIGN.md); the mark is two chunky circles touching, a "clink".
import AppKit
import UniformTypeIdentifiers

struct Look {
    let file: String
    let background: UInt32
    let big: UInt32
    let small: UInt32
}

let looks = [
    Look(file: "AppIcon.png", background: 0xFF5C39, big: 0xFFF7EC, small: 0xFFB81C),
    Look(file: "AppIcon-dark.png", background: 0x000000, big: 0xFF5C39, small: 0xFFB81C),
    Look(file: "AppIcon-tinted.png", background: 0x000000, big: 0xFFFFFF, small: 0x8C8C8C),
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
    // Big circle r270 and small circle r150 touch on a diagonal; the pair is centered so the Watch's circular crop keeps it.
    let big = CGRect(x: 423.5 - 270, y: 1024 - 600.5 - 270, width: 540, height: 540)
    let small = CGRect(x: 720.5 - 150, y: 1024 - 303.5 - 150, width: 300, height: 300)
    ctx.setFillColor(color(look.big))
    ctx.fillEllipse(in: big)
    ctx.setFillColor(color(look.small))
    ctx.fillEllipse(in: small)
    let data = NSMutableData()
    let dest = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
    CGImageDestinationFinalize(dest)
    return data as Data
}

// The Watch has one icon; the iPhone also gets dark and tinted.
for look in looks { try render(look).write(to: URL(fileURLWithPath: "\(phone)/\(look.file)")) }
try render(looks[0]).write(to: URL(fileURLWithPath: "\(watch)/AppIcon.png"))
