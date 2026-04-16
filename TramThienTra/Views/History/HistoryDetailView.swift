import SwiftUI
import SwiftData

// MARK: - SPEC §2.5 History detail — full gratitude log view

struct HistoryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let log: GratitudeLog

    @State private var showDeleteConfirmation = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    var body: some View {
        ZStack {
            Color("AccentColor")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Date header
                    Text(dateFormatter.string(from: log.date))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.top, 16)

                    // Items
                    ForEach(Array(log.items.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1).")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.6))
                            Text(item)
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .confirmationDialog(
            "Xoá kỷ niệm này?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Xoá", role: .destructive) {
                modelContext.delete(log)
                try? modelContext.save()
            }
            Button("Huỷ", role: .cancel) {}
        }
    }
}