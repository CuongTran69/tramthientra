import SwiftUI

// MARK: - ZenSquareButton component
//
// Designed for a 2x2 Grid layout.
// Displays a larger icon centered above the text.

struct ZenSquareButton: View {
    enum Variant {
        case primary
        case secondary
    }

    let title: String
    let variant: Variant
    var icon: String?
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel

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
            buttonContent
        }
        .buttonStyle(ZenSquareButtonStyle(
            variant: variant,
            isPressed: $isPressed,
            reduceMotion: reduceMotion,
            primaryGradientStart: thoiGianVM.current.primaryButtonGradientStart,
            primaryGradientEnd: thoiGianVM.current.primaryButtonGradientEnd,
            secondaryStroke: thoiGianVM.current.secondaryButtonStroke,
            secondaryFill: thoiGianVM.current.secondaryButtonFill
        ))
    }

    @ViewBuilder
    private var buttonContent: some View {
        VStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
            }
            Text(title)
                .font(ZenFont.subheadline())
        }
        .foregroundColor(variant == .primary ? .white : thoiGianVM.current.secondaryButtonText)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, minHeight: 96)
    }
}

// MARK: - ZenSquareButtonStyle

private struct ZenSquareButtonStyle: ButtonStyle {
    let variant: ZenSquareButton.Variant
    @Binding var isPressed: Bool
    let reduceMotion: Bool
    let primaryGradientStart: Color
    let primaryGradientEnd: Color
    let secondaryStroke: Color
    let secondaryFill: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                switch variant {
                case .primary:
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [primaryGradientStart, primaryGradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                case .secondary:
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                configuration.isPressed
                                    ? secondaryFill
                                    : Color.clear
                            )
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(secondaryStroke, lineWidth: 1)
                    }
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(
                (!reduceMotion && configuration.isPressed) ? 0.94 : 1.0
            )
            .animation(
                reduceMotion
                    ? nil
                    : .spring(response: 0.3, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "F5F0E8").ignoresSafeArea()
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ZenSquareButton("Biết ơn", variant: .primary, icon: "drop.fill") {}
            ZenSquareButton("Buông bỏ", variant: .secondary, icon: "leaf.fill") {}
            ZenSquareButton("Thiền Thở", variant: .secondary, icon: "wind") {}
            ZenSquareButton("Sám hối", variant: .secondary, icon: "hands.sparkles.fill") {}
        }
        .padding(20)
    }
    .environmentObject(ThoiGianViewModel())
}
