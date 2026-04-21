import SwiftUI
import SwiftData

// MARK: - SPEC §2.5 History detail — full gratitude log view (redesigned)
//
// Uses the shared design system: NenDongView background, ZenCard wrappers,
// ZenFont typography, ZenColor tokens. Text uses zenBrown / zenBrownDark
// to maintain WCAG AA contrast over the cream/sage gradients (≥ 4.5:1 for
// body, ≥ 3:1 for the numeric label).

struct HistoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let log: GratitudeLog

    @State private var showDeleteConfirmation = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd/MM/yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter
    }()

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Date header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nhật ký biết ơn")
                            .font(ZenFont.caption())
                            .tracking(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(ZenColor.zenBrown.opacity(0.6))

                        Text(dateFormatter.string(from: log.date).capitalized)
                            .font(ZenFont.title())
                            .foregroundColor(ZenColor.zenBrownDark)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .padding(.top, 8)
                    .accessibilityElement(children: .combine)

                    if log.items.isEmpty {
                        ZenCard {
                            Text("Không có nội dung được ghi lại trong ngày này.")
                                .font(ZenFont.body())
                                .foregroundColor(ZenColor.zenBrown.opacity(0.7))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        ForEach(Array(log.items.enumerated()), id: \.offset) { index, item in
                            ZenCard {
                                HStack(alignment: .top, spacing: 14) {
                                    // Numeric badge — sage circle, brown text
                                    Text("\(index + 1)")
                                        .font(ZenFont.subheadline())
                                        .foregroundColor(ZenColor.zenBrownDark)
                                        .frame(width: 28, height: 28)
                                        .background(
                                            Circle()
                                                .fill(ZenColor.zenSage.opacity(0.25))
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(ZenColor.zenSage.opacity(0.5), lineWidth: 1)
                                        )
                                        .accessibilityHidden(true)

                                    Text(item)
                                        .font(ZenFont.body())
                                        .foregroundColor(ZenColor.zenBrown)
                                        .lineSpacing(4)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .accessibilityLabel("Điều biết ơn thứ \(index + 1): \(item)")
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.red)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Xoá nhật ký")
                .accessibilityHint("Xoá nhật ký biết ơn này")
            }
        }
        .confirmationDialog(
            "Xoá kỷ niệm này?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Xoá", role: .destructive) {
                HapticService.shared.playWarning()
                modelContext.delete(log)
                try? modelContext.save()
                dismiss()
            }
            Button("Huỷ", role: .cancel) {}
        } message: {
            Text("Hành động này không thể hoàn tác.")
        }
    }
}