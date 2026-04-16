import SwiftUI
import SwiftData

// MARK: - SPEC §2.5 History list — ZenCard rows, stagger animation, empty state, sticky headers (redesigned)

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GratitudeLog.date, order: .reverse) private var logs: [GratitudeLog]
    @State private var page = 0
    @State private var rowsAppeared = false
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
                            .font(.title2)
                            .foregroundColor(ZenColor.zenBrown)
                            .frame(minWidth: 44, minHeight: 44)
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

                    Color.clear.frame(width: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
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
        }
    }

    // MARK: - Empty state

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            // Empty teacup illustration using SF Symbol + decorative frame
            ZStack {
                Circle()
                    .fill(ZenColor.zenSage.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "cup.and.saucer")
                    .font(.system(size: 48))
                    .foregroundColor(ZenColor.zenSage.opacity(0.5))
            }
            .accessibilityHidden(true)

            Text("Chưa có kỷ niệm nào được ghi lại.")
                .font(ZenFont.body())
                .foregroundColor(ZenColor.zenBrown.opacity(0.6))
                .multilineTextAlignment(.center)

            Text("Hãy bắt đầu tích luỹ những điều biết ơn.")
                .font(ZenFont.caption())
                .foregroundColor(ZenColor.zenBrown.opacity(0.4))
                .multilineTextAlignment(.center)
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
