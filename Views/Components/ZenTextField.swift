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

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background card layers
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
            // Focus ring: animates in/out on focus state change
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isFocused ? ZenColor.zenSage : Color.white.opacity(0.2),
                    lineWidth: 1
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)

            VStack(spacing: 0) {
                if multiline {
                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(ZenFont.body())
                                .foregroundColor(ZenColor.zenBrown.opacity(0.4))
                                .padding(.horizontal, 20)
                                .padding(.top, 18)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $text)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .font(ZenFont.body())
                            .foregroundColor(ZenColor.zenBrown)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .frame(minHeight: 100)
                            .focused($isFocused)
                            .onChange(of: text) { _, newValue in
                                if let limit = limit, newValue.count > limit {
                                    text = String(newValue.prefix(limit))
                                }
                            }
                    }
                } else {
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

                // Inline character counter — bottom-right inside the field
                if let limit = limit {
                    HStack {
                        Spacer()
                        Text("\(text.count) / \(limit)")
                            .font(ZenFont.caption2())
                            .foregroundColor(
                                text.count >= limit
                                    ? ZenColor.zenGold
                                    : ZenColor.zenBrown.opacity(0.4)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                    }
                }
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .frame(minHeight: 44)
    }
}
