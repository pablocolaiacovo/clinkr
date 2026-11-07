#!/usr/bin/env swift
// Writes Shared/AppIcon.icon, the layered Icon Composer icon both apps use. Run from the repo root:
// swift scripts/make-app-icons.swift
// The colors are copies of Shared/Palette.swift values; scripts/test.sh lint checks they still match.
import Foundation

// Named after their DESIGN.md slugs: ink is the dark-mode ink (cream), bg the dark background.
let fizz = 0xFF5C39
let ink = 0xFFF7EC
let bg = 0x000000
let beer = 0xFFB81C
let water = 0x4FD8FF
let shot = 0xB98CFF

func solid(_ hex: Int) -> [String: Any] {
    let parts = [hex >> 16, hex >> 8, hex].map { String(format: "%.5f", Double($0 & 0xFF) / 255) }
    return ["solid": "srgb:\(parts.joined(separator: ",")),1.00000"]
}

struct Shape {
    let name: String
    let svg: String
    let color: Int
    var dark: Int? = nil
    var dimmedWhenTinted = false
}

func tile(_ name: String, x: Int, y: Int, degrees: Double, color: Int, dark: Int? = nil, dimmed: Bool = false) -> Shape {
    let svg = "<rect x=\"-170\" y=\"-170\" width=\"340\" height=\"340\" rx=\"100\" "
        + "transform=\"translate(\(x) \(y)) rotate(\(degrees))\"/>"
    return Shape(name: name, svg: svg, color: color, dark: dark, dimmedWhenTinted: dimmed)
}

func bubble(_ name: String, x: Int, y: Int, radius: Int, color: Int, dimmed: Bool = false) -> Shape {
    Shape(name: name, svg: "<circle cx=\"\(x)\" cy=\"\(y)\" r=\"\(radius)\"/>", color: color, dimmedWhenTinted: dimmed)
}

let tiles = [
    tile("left-tile", x: 350, y: 620, degrees: -11.459, color: ink, dark: fizz),
    tile("right-tile", x: 694, y: 590, degrees: 11.459, color: beer, dimmed: true),
]
let bubbles = [
    bubble("water", x: 505, y: 345, radius: 90, color: water),
    bubble("shot", x: 660, y: 265, radius: 58, color: shot, dimmed: true),
]

func layer(_ shape: Shape) -> [String: Any] {
    var layer: [String: Any] = ["name": shape.name, "image-name": "\(shape.name).svg", "glass": true, "fill": solid(shape.color)]
    if let dark = shape.dark {
        layer["fill-specializations"] = [["appearance": "dark", "value": solid(dark)]]
    }
    // Tinted icons lose their hues, so a lower opacity is what keeps neighboring shapes apart.
    if shape.dimmedWhenTinted {
        layer["opacity-specializations"] = [["appearance": "tinted", "value": 0.55]]
    }
    return layer
}

// The tiles are drink colors, so they stay solid (DESIGN.md, The Content Stays Solid Rule); the bubbles are glass.
func group(_ name: String, _ shapes: [Shape], translucent: Bool) -> [String: Any] {
    [
        "name": name, "layers": shapes.map(layer), "shadow": ["kind": "neutral", "opacity": 0.5],
        "translucency": ["enabled": translucent, "value": translucent ? 0.4 : 0], "specular": true,
    ]
}

let icon: [String: Any] = [
    "fill": solid(fizz),
    "fill-specializations": [["appearance": "dark", "value": solid(bg)]],
    // The first group is drawn on top.
    "groups": [group("Bubbles", bubbles, translucent: true), group("Tiles", tiles, translucent: false)],
    "supported-platforms": ["circles": ["watchOS"], "squares": "shared"],
]

let bundle = URL(fileURLWithPath: "Shared/AppIcon.icon")
let assets = bundle.appendingPathComponent("Assets")
// Cleared first, so a renamed shape leaves no old SVG behind.
try? FileManager.default.removeItem(at: assets)
try FileManager.default.createDirectory(at: assets, withIntermediateDirectories: true)
for shape in tiles + bubbles {
    let svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1024\" height=\"1024\">\(shape.svg)</svg>\n"
    try svg.write(to: assets.appendingPathComponent("\(shape.name).svg"), atomically: true, encoding: .utf8)
}
let json = try JSONSerialization.data(withJSONObject: icon, options: [.prettyPrinted, .sortedKeys])
try json.write(to: bundle.appendingPathComponent("icon.json"))
