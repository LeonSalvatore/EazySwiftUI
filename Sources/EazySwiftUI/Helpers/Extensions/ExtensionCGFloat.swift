//
//  ExtensionCGFloat.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 14.01.2026.
//

import SwiftUI

 struct CGDebug {

    nonisolated(unsafe) static var isDebugEnabled = true

    public static func logInvalidCGFloat(_ value: CGFloat, message: String = "", file: String = #file, line: Int = #line, function: String = #function) {
        guard isDebugEnabled else { return }

        if value.isNaN || value.isInfinite {
            let fileName = (file as NSString).lastPathComponent

            print("""
            🔴 CGDEBUG: INVALID CGFloat DETECTED
            ┌─────────────────────────────────────────────────────────
            │ Value: \(value)
            │ File: \(fileName):\(line)
            │ Function: \(function)
            │ Message: \(message)
            │ Thread: \(Thread.current)
            └─────────────────────────────────────────────────────────
            """)

            // Print call stack
            print("📞 Call Stack:")
            Thread.callStackSymbols.forEach { symbol in
                // Filter to show only your app's code
                if symbol.contains("CONVIVA") && !symbol.contains("CGDebug") {
                    print("   \(symbol)")
                }
            }
            print("")
        }
    }
}

public extension CGFloat {

    /// Returns half of the value.
    /// Commonly used to derive a radius from a size.
    var radius: CGFloat {
        self / 2
    }

    var safe: CGFloat {
        CGDebug.logInvalidCGFloat(self)
        if self.isNaN || self.isInfinite {
            return 0
        }
        return self
    }

    func clamped(between minValue: CGFloat, and maxValue: CGFloat) -> CGFloat {
        let safeMin = minValue.safe
        let safeMax = maxValue.safe
        let safeSelf = self.safe

        guard !safeMin.isNaN && !safeMax.isNaN else {
            print("⚠️ Invalid clamp bounds: min=\(minValue), max=\(maxValue)")
            return safeSelf
        }

        guard safeMin <= safeMax else {
            print("⚠️ Inverted clamp bounds: min=\(minValue) > max=\(maxValue)")
            return safeSelf
        }
        let result = Swift.min(Swift.max(safeSelf, safeMin), safeMax)

        return result
    }
}

// Also add for other numeric types
public extension Double {
    var safe: Double {
        CGDebug.logInvalidCGFloat(self)
        if self.isNaN || self.isInfinite {
            print("⚠️ Invalid Double detected: \(self)")
            return 0
        }
        return self
    }
}
