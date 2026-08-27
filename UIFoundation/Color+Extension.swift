//
//  Color+Extension.swift
//  UIFoundation
//
//  Created by Porter McGary on 9/17/23.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias NativeColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias NativeColor = NSColor
#else
#error("UIFoundation needs either UIKit or AppKit for its colour conversions.")
#endif

// MARK: Components

public extension NativeColor {
    /// The colour's components in sRGB, or `nil` if it cannot be represented there — a pattern or
    /// catalog colour, for instance.
    var rgbaComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0

        #if canImport(UIKit)
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        #elseif canImport(AppKit)
        // `NSColor.getRed` traps outside an RGB colour space, so convert first rather than
        // assuming the colour arrived in one.
        guard let converted = usingColorSpace(.sRGB) else { return nil }
        converted.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif

        return (red, green, blue, alpha)
    }
}

// MARK: Mixing

// Credit to https://stackoverflow.com/a/63003757/12726577
public extension NativeColor {
    /// Blends this colour towards `target`, keeping this colour's alpha.
    /// - Parameter amount: How far to travel, from `0` (unchanged) to `1` (fully `target`).
    /// - Returns: The blended colour, or this colour unchanged if either side has no sRGB
    ///   representation.
    func mix(with target: NativeColor, amount: CGFloat) -> Self {
        guard let base = rgbaComponents, let other = target.rgbaComponents else { return self }
        let amount = min(max(amount, 0), 1)

        return Self(
            red: base.red * (1 - amount) + other.red * amount,
            green: base.green * (1 - amount) + other.green * amount,
            blue: base.blue * (1 - amount) + other.blue * amount,
            alpha: base.alpha
        )
    }

    func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: .white, amount: amount) }
    func darker(by amount: CGFloat = 0.2) -> Self { mix(with: .black, amount: amount) }
}

public extension Color {
    func lighter(by amount: CGFloat = 0.2) -> Self { Self(NativeColor(self).lighter(by: amount)) }
    func darker(by amount: CGFloat = 0.2) -> Self { Self(NativeColor(self).darker(by: amount)) }
}

// MARK: Hex

public extension Color {
    /// Creates a colour from a hex string.
    ///
    /// Accepts `RGB`, `RGBA`, `RRGGBB` and `RRGGBBAA`, with or without a leading `#`, in either
    /// case. Shorthand digits are doubled, so `"#F90"` is `"#FF9900"`.
    ///
    /// Failable rather than substituting a fallback colour: a typo in a hex string used to produce
    /// a silently wrong colour, which is far harder to notice than a `nil`. Call sites that want a
    /// fallback can say so — `Color(hex: token) ?? .accentColor`.
    ///
    /// - Parameter hex: The hex string to parse.
    init?(hex: String) {
        let digits = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingPrefix("#")

        // `UInt64(_:radix:)` rejects the whole string unless every character is a hex digit.
        // `Scanner.scanHexInt64` instead stops at the first one that is not and reports success,
        // so `"FFZZZZ"` parsed as `0xFF` and was laid out as if it were six digits — a silently
        // wrong colour rather than a rejected one.
        guard let value = UInt64(digits, radix: 16) else { return nil }

        /// Expands a shorthand nibble the way CSS does: `F` becomes `FF`.
        func doubled(_ nibble: UInt64) -> Double { Double(nibble << 4 | nibble) / 255 }
        func byte(_ shifted: UInt64) -> Double { Double(shifted & 0xFF) / 255 }

        switch digits.count {
        case 3:
            self.init(red: doubled(value >> 8 & 0xF),
                      green: doubled(value >> 4 & 0xF),
                      blue: doubled(value & 0xF),
                      opacity: 1)
        case 4:
            self.init(red: doubled(value >> 12 & 0xF),
                      green: doubled(value >> 8 & 0xF),
                      blue: doubled(value >> 4 & 0xF),
                      opacity: doubled(value & 0xF))
        case 6:
            self.init(red: byte(value >> 16),
                      green: byte(value >> 8),
                      blue: byte(value),
                      opacity: 1)
        case 8:
            self.init(red: byte(value >> 24),
                      green: byte(value >> 16),
                      blue: byte(value >> 8),
                      opacity: byte(value))
        default:
            return nil
        }
    }

    /// The colour as an uppercase hex string, without a leading `#`.
    ///
    /// Six digits when the colour is fully opaque, eight when it is not. `nil` for a colour with no
    /// sRGB representation.
    var hexValue: String? {
        guard let components = NativeColor(self).rgbaComponents else { return nil }

        func channel(_ value: CGFloat) -> Int { lroundf(Float(min(max(value, 0), 1)) * 255) }

        let red = channel(components.red)
        let green = channel(components.green)
        let blue = channel(components.blue)
        let alpha = channel(components.alpha)

        guard alpha < 255 else {
            return String(format: "%02lX%02lX%02lX", red, green, blue)
        }
        return String(format: "%02lX%02lX%02lX%02lX", red, green, blue, alpha)
    }
}
