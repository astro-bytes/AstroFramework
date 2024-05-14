//
//  Color+Hex.swift
//  UIFoundation
//
//  Created by Porter McGary on 9/17/23.
//

import SwiftUI
import LoggerFoundation

#if canImport(UIKit)
public typealias NativeColor = UIColor
#elseif canImport(AppKit)
public typealias NativeColor = NSColor
#endif

// Credit to https://stackoverflow.com/a/63003757/12726577
public extension NativeColor {
    func mix(with target: NativeColor, amount: CGFloat) -> Self {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        target.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return Self(
            red: r1 * (1.0 - amount) + r2 * amount,
            green: g1 * (1.0 - amount) + g2 * amount,
            blue: b1 * (1.0 - amount) + b2 * amount,
            alpha: a1
        )
    }

    func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: .white, amount: amount) }
    func darker(by amount: CGFloat = 0.2) -> Self { mix(with: .black, amount: amount) }
}

public extension Color {
    func lighter(by amount: CGFloat = 0.2) -> Self { Self(NativeColor(self).lighter(by: amount)) }
    func darker(by amount: CGFloat = 0.2) -> Self { Self(NativeColor(self).darker(by: amount)) }
}

// TODO: Learn how to encode colors to Data Objects
// https://nilcoalescing.com/blog/EncodeAndDecodeSwiftUIColor/
public extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            Logger.log(.warning, msg: "Failed to scan hex Int64 - \(hex)")
            self.init(red: 1, green: 1, blue: 1, opacity: 1)
            return
        }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            Logger.log(.warning, msg: "Invalid length of hex string - \(hex) - \(length)")
            self.init(red: 1, green: 1, blue: 1, opacity: 1)
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    var hexValue: String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            Logger.log(.warning, msg: "Failed to get components or components are too short - \(String(describing: self))")
            return ""
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX",
                          lroundf(r * 255),
                          lroundf(g * 255),
                          lroundf(b * 255),
                          lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX",
                          lroundf(r * 255),
                          lroundf(g * 255),
                          lroundf(b * 255))
        }
    }
}
