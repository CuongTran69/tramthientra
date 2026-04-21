import SwiftUI

// MARK: - ZenTextField component
//
// Wraps a TextField or TextEditor in a ZenCard-style container.
// Features:
//   - Focus ring: 1 pt zenSage stroke when field is first responder
//   - Optional inline character counter (bottom-right) when `limit` is provided
//     Displayed as "n / limit" in ZenFont.caption2(), zenBrown.opacity(0.4)
//     Counter text turns zenGold when character count equals the limit
//   - Supports multiline (TextEditor) via `multiline: true`

struct ZenTextField: View {
    let placeholder: String
    @Binding var text: String
    var limit: Int? = nil
    var multiline: Bool = false
    /// Minimum height of the multiline text area. Default 64 pt.
    var minHeight: CGFloat = 64
    /// Maximum height of the multiline text area. Default 120 pt.
    var maxHeight: CGFloat = 120

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background card layers — match ZenCard for consistency
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.55))
            // Focus ring: 2 pt sage on focus, soft hairline otherwise
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isFocused ? ZenColor.zenSage : Color.white.opacity(0.6),
                    lineWidth: isFocused ? 2 : 1
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)

            VStack(spacing: 0) {
                if multiline {
                    // TextEditor for multi-line input
                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(ZenFont.body())
                                .foregroundColor(ZenColor.zenBrown.opacity(0.45))
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $text)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .font(ZenFont.body())
                            .foregroundColor(ZenColor.zenBrown)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .frame(minHeight: minHeight, maxHeight: maxHeight)
                            .focused($isFocused)
                            .onChange(of: text) { _, newValue in
                                if let limit = limit, newValue.count > limit {
                                    text = String(newValue.prefix(limit))
                                }
                            }
                    }
                } else {
                    // Single-line TextField
                    TextField(placeholder, text: $text)
                        .font(ZenFont.body())
                        .foregroundColor(ZenColor.zenBrown)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, limit != nil ? 28 : 16)
                        .focused($isFocused)
                        .onChange(of: text) { _, newValue in
                            if let limit = limit, newValue.count > limit {
                                text = String(newValue.prefix(limit))
                            }
                        }
                }

                // Inline character counter — bottom-right, fades in only when focused or populated
                if let limit = limit {
                    HStack {
                        Spacer()
                        Text("\(text.count) / \(limit)")
                            .font(ZenFont.caption2())
                            .monospacedDigit()
                            .foregroundColor(
                                text.count >= limit
                                    ? ZenColor.zenGold
                                    : ZenColor.zenBrown.opacity(0.45)
                            )
                            .padding(.horizontal, 18)
                            .padding(.bottom, 10)
                            .opacity(isFocused || !text.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                    }
                }
            }
        }
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .shadow(color: ZenColor.zenBrown.opacity(0.06), radius: 14, x: 0, y: 6)
        // Minimum 44 pt height for accessibility touch target compliance
        .frame(minHeight: 44)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: ThoiGian.suongSom.colors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 16) {
            ZenTextField(
                placeholder: "Điều bạn biết ơn...",
                text: .constant(""),
                limit: 300,
                multiline: true
            )

            ZenTextField(
                placeholder: "Tìm kiếm...",
                text: .constant("Hello"),
                limit: nil,
                multiline: false
            )
        }
        .padding(.horizontal, 24)
    }
}
