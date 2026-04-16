import SwiftUI

// MARK: - SPEC §2.3 Dynamic background — 4 time slots, three-stop gradients, 1.5s cross-fade

struct NenDongView: View {
    @State private var currentColors: [Color] = ThoiGian.suongSom.colors

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: currentColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                // 1.5s linear cross-fade when the time slot changes
                withAnimation(.linear(duration: 1.5)) {
                    currentColors = ThoiGian.current.colors
                }
            }
            .onAppear {
                currentColors = ThoiGian.current.colors
            }
    }
}
