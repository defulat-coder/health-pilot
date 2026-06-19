import SwiftUI

enum DS {
    static let background = Color(red: 0.975, green: 0.976, blue: 0.980)
    static let panel = Color.white
    static let chip = Color.black.opacity(0.045)
    static let text = Color(red: 0.07, green: 0.07, blue: 0.08)
    static let secondary = Color.black.opacity(0.48)
    static let tertiary = Color.black.opacity(0.30)
    static let divider = Color.black.opacity(0.08)
    static let blue = Color(red: 0.16, green: 0.39, blue: 0.98)
    static let sidebar = Color(red: 0.974, green: 0.974, blue: 0.974)
    static let softBlue = Color(red: 0.91, green: 0.95, blue: 1.0)

    static let composerRadius: CGFloat = 24
    static let menuRadius: CGFloat = 12
    static let rowRadius: CGFloat = 10

    static func panelShadow() -> some ViewModifier {
        ShadowModifier(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 8)
    }
}

struct ShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: x, y: y)
    }
}

extension View {
    func cardShadow() -> some View {
        modifier(ShadowModifier(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 8))
    }

    func smallShadow() -> some View {
        modifier(ShadowModifier(color: Color.black.opacity(0.14), radius: 16, x: 0, y: 6))
    }
}
