import SwiftUI
import SwiftData

// MARK: - SPEC §2.5 History list — ZenCard rows, stagger animation, empty state, sticky headers (redesigned)

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GratitudeLog.date, order: .reverse) private var logs: [GratitudeLog]
    @State private var page = 0
    @State private var rowsAppeared = false
    @State private var pendingDelete: GratitudeLog?
    private let pageSize = Constants.historyPageSize

    private var paginatedLogs: [GratitudeLog] {
        Array(logs.prefix((page + 1) * pageSize))
    }

    // Group logs by date string for sticky section headers
    private var groupedLogs: [(key: String, value: [GratitudeLog])] {
        let grouped = Dictionary(grouping: paginatedLogs) { log in
            sectionDateFormatter.string(from: log.date)
        }
        return grouped
            .sorted { a, b in
                // Sort sections newest-first
                let dateA = sectionDateFormatter.date(from: a.key) ?? Date.distantPast
                let dateB = sectionDateFormatter.date(from: b.key) ?? Date.distantPast
                return dateA > dateB
            }
    }

    private let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    var body: some View {
        ZStack {
            NenDongView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.medium))
                            .foregroundColor(ZenColor.zenBrown)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Đóng")
                    .accessibilityHint("Đóng màn hình lịch sử")

                    Spacer()

                    Text("Lịch sử")
                        .font(ZenFont.headline())
                        .foregroundColor(ZenColor.zenBrownDark)
                        .accessibilityAddTraits(.isHeader)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)

                if logs.isEmpty {
                    // Empty state with teacup illustration and message
                    Spacer()
                    emptyStateView
                    Spacer()
                } else {
                    // List with ZenCard rows and sticky date section headers
                    List {
                        ForEach(Array(groupedLogs.enumerated()), id: \.element.key) { sectionIndex, section in
                            Section {
                                ForEach(Array(section.value.enumerated()), id: \.element.id) { rowIndex, log in
                                    let globalIndex = sectionIndex * 5 + rowIndex // approx stagger index
                                    NavigationLink(destination: HistoryDetailView(log: log)) {
                                        HistoryRowView(log: log, dateFormatter: sectionDateFormatter)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .modifier(
                                        StaggerAppearModifier(
                                            index: globalIndex,
                                            appeared: rowsAppeared
                                        )
                                    )
                                    // Long-press preview + quick actions
                                    .contextMenu {
                                        NavigationLink(destination: HistoryDetailView(log: log)) {
                                            Label("Xem chi tiết", systemImage: "doc.text.magnifyingglass")
                                        }
                                        Button(role: .destructive) {
                                            HapticService.shared.playLight()
                                            pendingDelete = log
                                        } label: {
                                            Label("Xoá", systemImage: "trash")
                                        }
                                    } preview: {
                                        HistoryRowPreview(log: log, dateFormatter: sectionDateFormatter)
                                    }
                                    // SPEC §2.7: swipe left → delete with confirmation
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            HapticService.shared.playLight()
                                            pendingDelete = log
                                        } label: {
                                            Label("Xoá", systemImage: "trash")
                                        }
                                        .tint(.red)
                                        .accessibilityLabel("Xoá nhật ký ngày \(sectionDateFormatter.string(from: log.date))")
                                    }
                                }
                            } header: {
                                // Sticky date header
                                Text(section.key)
                                    .font(ZenFont.caption())
                                    .foregroundColor(ZenColor.zenBrown.opacity(0.7))
                                    .textCase(.uppercase)
                                    .tracking(1.5)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 6)
                            }
                        }

                        if paginatedLogs.count < logs.count {
                            Button("Tải thêm...") {
                                page += 1
                            }
                            .font(ZenFont.body())
                            .foregroundColor(ZenColor.zenBrown.opacity(0.7))
                            .listRowBackground(Color.clear)
                            .frame(minHeight: 44)
                            .accessibilityLabel("Tải thêm")
                            .accessibilityHint("Hiển thị thêm lịch sử")
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.grouped)
                    .onAppear {
                        // Trigger stagger animation when list appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            rowsAppeared = true
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .confirmationDialog(
            "Xoá kỷ niệm này?",
            isPresented: Binding(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: pendingDelete
        ) { log in
            Button("Xoá", role: .destructive) {
                HapticService.shared.playWarning()
                modelContext.delete(log)
                try? modelContext.save()
                pendingDelete = nil
            }
            Button("Huỷ", role: .cancel) {
                pendingDelete = nil
            }
        } message: { _ in
            Text("Hành động này không thể hoàn tác.")
        }
    }

    // MARK: - Empty state

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            // Teacup illustration — layered soft sage halo + symbol
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ZenColor.zenSage.opacity(0.22),
                                ZenColor.zenSage.opacity(0.02)
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 92, height: 92)
                    .overlay(
                        Circle()
                            .stroke(ZenColor.zenSage.opacity(0.25), lineWidth: 1)
                    )

                Image(systemName: "cup.and.saucer")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(ZenColor.zenSage.opacity(0.75))
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("Góc nhỏ này vẫn đang chờ đợi những ân tình")
                    .font(ZenFont.subheadline())
                    .foregroundColor(ZenColor.zenBrownDark)
                    .multilineTextAlignment(.center)

                Text("Hãy bắt đầu gom nhặt những điều biết ơn nhỏ bé ngày hôm nay.")
                    .font(ZenFont.caption())
                    .foregroundColor(ZenColor.zenBrown.opacity(0.55))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - History row using ZenCard

struct HistoryRowView: View {
    let log: GratitudeLog
    let dateFormatter: DateFormatter

    var body: some View {
        ZenCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(dateFormatter.string(from: log.date))
                    .font(ZenFont.subheadline())
                    .foregroundColor(ZenColor.zenBrownDark)
                if let firstItem = log.items.first, !firstItem.isEmpty {
                    Text(firstItem)
                        .font(ZenFont.caption())
                        .foregroundColor(ZenColor.zenBrown.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle()) // Full ZenCard is tappable
        .accessibilityLabel("Nhật ký ngày \(dateFormatter.string(from: log.date))")
    }
}

// MARK: - Stagger appear modifier
// Row starts 20 pt below and opacity 0, animates in with 0.05s delay per row.

struct StaggerAppearModifier: ViewModifier {
    let index: Int
    let appeared: Bool

    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : 20)
            .opacity(appeared ? 1 : 0)
            .animation(
                .easeOut(duration: 0.35)
                    .delay(Double(index) * 0.05),
                value: appeared
            )
    }
}

// MARK: - Long-press preview card
// Shown when the user long-presses a HistoryRow. Renders the full set of
// gratitude items so the user can scan the day without navigating.

struct HistoryRowPreview: View {
    let log: GratitudeLog
    let dateFormatter: DateFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Nhật ký biết ơn")
                    .font(ZenFont.caption2())
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .foregroundColor(ZenColor.zenBrown.opacity(0.55))
                Text(dateFormatter.string(from: log.date))
                    .font(ZenFont.headline())
                    .foregroundColor(ZenColor.zenBrownDark)
            }

            Rectangle()
                .fill(ZenColor.zenSage.opacity(0.35))
                .frame(width: 32, height: 1)

            if log.items.isEmpty {
                Text("Không có nội dung được ghi lại.")
                    .font(ZenFont.caption())
                    .foregroundColor(ZenColor.zenBrown.opacity(0.6))
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(log.items.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(ZenFont.caption2())
                                .foregroundColor(ZenColor.zenBrownDark)
                                .frame(width: 20, height: 20)
                                .background(
                                    Circle().fill(ZenColor.zenSage.opacity(0.22))
                                )
                                .overlay(
                                    Circle().stroke(ZenColor.zenSage.opacity(0.45), lineWidth: 1)
                                )

                            Text(item)
                                .font(ZenFont.caption())
                                .foregroundColor(ZenColor.zenBrown)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(width: 300, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(ZenColor.zenCream)
                RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.55))
            }
        )
    }
}

#Preview {
    let container = try! ModelContainer(
        for: GratitudeLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return NavigationStack {
        HistoryView()
    }
    .modelContainer(container)
    .environmentObject(ThoiGianViewModel())
}
