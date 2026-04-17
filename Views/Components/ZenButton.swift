import SwiftUI

// MARK: - ZenButton component
//
// Two variants:
//   .primary  — zenBrownDark gradient fill, white label, optional leading icon,
//               scale-to-0.96 spring animation on press, medium haptic on main thread.
//   .secondary — ghost style: transparent fill, 1 pt zenSage border, zenBrown label,
//                subtle zenSage.opacity(0.1) fill while pressed.
//
// Reduce-motion: scale animation is skipped; haptic still fires.
// IMPORTANT: UIImpactFeedbackGenerator must be called on the main thread.

struct ZenButton: View {
    enum Variant {
        case primary
        case secondary
    }

    let title: String
    let variant: Variant
    var icon: String?
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        _ title: String,
        variant: Variant = .primary,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(ZenFont.headline())
            }
            .foregroundColor(variant == .primary ? .white : ZenColor.zenBrown)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ZenButtonStyle(variant: variant, reduceMotion: reduceMotion))
    }
}

// MARK: - ZenButtonStyle

private struct ZenButtonStyle: ButtonStyle {
    let variant: ZenButton.Variant
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                switch variant {
                case .primary:
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [ZenColor.zenBrown, ZenColor.zenBrownDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                case .secondary:
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                configuration.isPressed
                                    ? ZenColor.zenSage.opacity(0.1)
                                    : Color.clear
                            )
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(ZenColor.zenSage, lineWidth: 1)
                    }
                }
            }
            .frame(minHeight: 44)
            .contentShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(
                (!reduceMotion && configuration.isPressed) ? 0.96 : 1.0
            )
            .animation(
                reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}
