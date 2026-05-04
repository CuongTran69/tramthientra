import SwiftUI

// MARK: - Hương Trầm View (Incense Smoke)
//
// A delicate, swirling incense smoke effect used specifically for the
// Sám hối (Repentance) screen. Unlike KhoiTanView (which disperses like burning paper),
// HuongTramView represents a thin, continuous, elegant stream of incense
// rising to the heavens, reflecting purification and prayers.

struct HuongTramView: View {
    @EnvironmentObject var thoiGianVM: ThoiGianViewModel
    
    // Number of particles for a smooth, continuous smoke stream
    private let particleCount = 60
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let duration: Double = 3.5 // Time for a particle to reach the top
                
                // Color of the incense smoke, slightly tinted with the time's glow
                let smokeColor = thoiGianVM.current.smokeColor
                let baseOpacity = thoiGianVM.current.smokeOpacity * 2.5 // Slightly more visible for the thin stream
                
                for i in 0..<particleCount {
                    // Seed for pseudo-randomness without allocating new objects
                    let seed = Double(i)
                    
                    // Delay for continuous emission
                    let delay = seed * (duration / Double(particleCount))
                    
                    // Time variable mapped from 0.0 (bottom) to 1.0 (top)
                    let t = min(1.0, max(0, (now - delay).truncatingRemainder(dividingBy: duration) / duration))
                    
                    // Ease out so smoke slows down as it reaches the top
                    let eased = 1.0 - pow(1.0 - t, 2)
                    
                    // Base position (starts exactly at bottom center)
                    let startX = size.width / 2
                    let startY = size.height
                    
                    // Y moves upwards
                    let yPos = startY - CGFloat(eased * size.height)
                    
                    // X swirls using sine waves.
                    // The amplitude of the swirl increases as the smoke rises.
                    let swirlAmplitude = CGFloat(10.0 + eased * 40.0) // Spreads out at the top
                    let frequency = 1.5 // Wave frequency
                    
                    // Add some natural noise based on the seed
                    let noise = sin(seed * 11.3) * 5.0
                    
                    let xPos = startX + sin(now * 1.2 + yPos / 40.0 * frequency + seed * 0.1) * swirlAmplitude + CGFloat(noise)
                    
                    // Size of the smoke particle (grows as it rises)
                    let radius = CGFloat(2.0 + eased * 6.0)
                    
                    // Opacity (fades out at the top)
                    let opacity = max(0, (1.0 - eased) * baseOpacity)
                    
                    let rect = CGRect(
                        x: xPos - radius,
                        y: yPos - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    
                    // Draw with blur to create a soft, continuous smoke trail
                    var smokeContext = context
                    smokeContext.addFilter(.blur(radius: radius * 0.6))
                    smokeContext.fill(
                        Path(ellipseIn: rect),
                        with: .color(smokeColor.opacity(opacity))
                    )
                }
                
                // Add a few glowing sparks (tàn nhang) floating up
                let sparkCount = 5
                for i in 0..<sparkCount {
                    let seed = Double(i * 100)
                    let delay = seed * (duration / Double(sparkCount))
                    let t = min(1.0, max(0, (now - delay).truncatingRemainder(dividingBy: duration * 1.5) / (duration * 1.5)))
                    
                    let startX = size.width / 2
                    let yPos = size.height - CGFloat(t * size.height * 0.8)
                    let xPos = startX + sin(now * 2.0 + seed) * 30.0
                    
                    let opacity = max(0, sin(t * .pi)) * 0.6 // Pulsing glow
                    let rect = CGRect(x: xPos - 1.5, y: yPos - 1.5, width: 3, height: 3)
                    
                    var sparkContext = context
                    sparkContext.addFilter(.blur(radius: 1.0))
                    sparkContext.fill(
                        Path(ellipseIn: rect),
                        with: .color(thoiGianVM.current.glowTint.opacity(opacity))
                    )
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "2A2535").ignoresSafeArea() // Night background for contrast
        HuongTramView()
            .frame(width: 200, height: 300)
            .environmentObject(ThoiGianViewModel())
    }
}
