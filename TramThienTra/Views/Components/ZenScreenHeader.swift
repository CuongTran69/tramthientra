import SwiftUI

// MARK: - ZenScreenHeader — reusable sub-screen header
//
// Pill-style dismiss button + centered title, matching TraThatView's
// navIconButton pattern. Uses time-aware colors from ThoiGianViewModel.

struct ZenScreenHeader: View {
    let title: String
    let dismissAction: () -> Void
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel

    var body: some View {
        HStack {
            Button(action: dismissAction) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(thoiGianVM.current.navIconTint)
                    .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.25)))
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Đóng")

            Spacer()

            Text(title)
                .font(ZenFont.headline())
                .foregroundColor(thoiGianVM.current.textPrimary)
                .animation(.easeInOut(duration: 2.0), value: thoiGianVM.current)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            // Balance spacer for centering
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: ThoiGian.suongSom.colors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack {
            ZenScreenHeader(title: "Tích luỹ", dismissAction: {})
            Spacer()
        }
    }
    .environmentObject(ThoiGianViewModel())
}
