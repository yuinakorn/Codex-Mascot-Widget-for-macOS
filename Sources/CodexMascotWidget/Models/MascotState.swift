import SwiftUI

public enum MascotEmotion: String, CaseIterable, Codable {
    case happy      // 0% - 50%
    case neutral    // 50% - 80%
    case sweating   // 80% - 95%
    case exhausted  // > 95%
    case sleeping   // Error / Offline / No key
    
    public static func emotion(for percentage: Double, isError: Bool = false) -> MascotEmotion {
        if isError { return .sleeping }
        switch percentage {
        case 0.0..<0.50:
            return .happy
        case 0.50..<0.80:
            return .neutral
        case 0.80..<0.95:
            return .sweating
        default:
            return .exhausted
        }
    }
    
    // ─── Codex Purple-Blue Theme Palette ───
    public var themeColor: Color {
        switch self {
        case .happy:
            return Color(red: 0.44, green: 0.39, blue: 0.85) // Codex Periwinkle Purple (#7063D9)
        case .neutral:
            return Color(red: 0.42, green: 0.53, blue: 0.95) // Blue-Indigo
        case .sweating:
            return Color(red: 0.96, green: 0.62, blue: 0.04) // Amber Warning
        case .exhausted:
            return Color(red: 0.94, green: 0.27, blue: 0.27) // Crimson Red
        case .sleeping:
            return Color(red: 0.50, green: 0.48, blue: 0.62) // Muted Lavender Grey
        }
    }
    
    public var bodyColor: Color {
        switch self {
        case .happy:
            return Color(red: 0.55, green: 0.49, blue: 0.90) // Lavender Purple (#8C7DE6)
        case .neutral:
            return Color(red: 0.48, green: 0.58, blue: 0.98) // Periwinkle Blue
        case .sweating:
            return Color(red: 0.95, green: 0.72, blue: 0.20) // Warm Amber
        case .exhausted:
            return Color(red: 0.92, green: 0.35, blue: 0.40) // Hot Red
        case .sleeping:
            return Color(red: 0.55, green: 0.52, blue: 0.65) // Dim Lavender
        }
    }
    
    public var statusTitle: String {
        switch self {
        case .happy:
            return "Systems Nominal ✨"
        case .neutral:
            return "Moderate Traffic"
        case .sweating:
            return "High Rate Limit ⚠️"
        case .exhausted:
            return "Rate Limit Exceeded 🔥"
        case .sleeping:
            return "Standing By 💤"
        }
    }
}
