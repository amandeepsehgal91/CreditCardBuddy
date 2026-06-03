import SwiftUI

extension Color {
    static var platformSystemBackground: Color {
        #if canImport(UIKit)
        return Color(.systemBackground)
        #else
        return Color(nsColor: NSColor.windowBackgroundColor)
        #endif
    }

    static var platformSecondaryBackground: Color {
        #if canImport(UIKit)
        return Color(.secondarySystemBackground)
        #else
        return Color(nsColor: NSColor.underPageBackgroundColor)
        #endif
    }
}
