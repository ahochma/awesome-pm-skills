import SwiftUI

// MARK: - Design System

enum AppTheme {
    // MARK: Spacing (8px grid)
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacing2XL: CGFloat = 48

    // MARK: Corner Radius
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 20

    // MARK: Person Colors
    static let personColors: [Color] = [
        .blue, .purple, .orange, .pink, .teal, .indigo, .mint, .cyan
    ]

    static func color(for index: Int) -> Color {
        personColors[index % personColors.count]
    }

    // MARK: Category Colors
    static func categoryColor(for category: String?) -> Color {
        guard let cat = category?.lowercased() else { return .gray }
        switch cat {
        case "kitchen": return .orange
        case "cleaning": return .blue
        case "laundry": return .purple
        case "shopping": return .green
        case "general": return .gray
        default: return .teal
        }
    }

    // MARK: Category Icons
    static func categoryIcon(for category: String?) -> String {
        guard let cat = category?.lowercased() else { return "circle.fill" }
        switch cat {
        case "kitchen": return "fork.knife"
        case "cleaning": return "sparkles"
        case "laundry": return "washer"
        case "shopping": return "cart"
        case "general": return "house"
        default: return "tag"
        }
    }
}

// MARK: - Haptics

enum Haptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var padding: CGFloat = AppTheme.spacingMD

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
    }
}

struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.spacingMD)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
    }
}

extension View {
    func cardStyle(padding: CGFloat = AppTheme.spacingMD) -> some View {
        modifier(CardStyle(padding: padding))
    }

    func glassCard() -> some View {
        modifier(GlassCardStyle())
    }
}

// MARK: - Reusable Components

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionLabel: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.secondary)
                .padding(.bottom, AppTheme.spacingSM)

            Text(title)
                .font(.title3.weight(.semibold))

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let actionLabel, let action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, AppTheme.spacingLG)
                        .padding(.vertical, AppTheme.spacingSM)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, AppTheme.spacingSM)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacing2XL)
    }
}

struct PointsBadge: View {
    let points: Int
    var color: Color = .accentColor

    var body: some View {
        Text("+\(points)")
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.spacingSM)
            .padding(.vertical, AppTheme.spacingXS)
            .background(color, in: Capsule())
    }
}

struct SectionHeaderView: View {
    let title: String
    var icon: String?

    var body: some View {
        HStack(spacing: AppTheme.spacingSM) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .textCase(nil)
    }
}

// MARK: - Success Toast

struct SuccessToast: View {
    let message: String
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            HStack(spacing: AppTheme.spacingSM) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(message)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .padding(.vertical, AppTheme.spacingMD)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isShowing = false
                    }
                }
            }
        }
    }
}

// MARK: - Greeting Helper

enum GreetingHelper {
    static func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    static func greetingIcon() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "sun.max.fill"
        case 12..<17: return "sun.min.fill"
        case 17..<22: return "sunset.fill"
        default: return "moon.stars.fill"
        }
    }
}
