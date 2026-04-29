import SwiftUI

// MARK: - Teapot Scene — Unified Canvas for flawless layout and buttery smooth animations
struct TeapotSceneView: View {
    @State private var isFloating = false
    @State private var startPourTime: Date? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let steamCount = 7

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let now = timeline.date
                
                // --- 1. Compute timeline-based animations for 120fps smoothness ---
                var currentTilt: Double = 0
                var cupOpacity: Double = 0
                var streamProgress: CGFloat = 0
                var streamTail: CGFloat = 0
                let isPouring = startPourTime != nil
                
                if let start = startPourTime {
                    let elapsed = now.timeIntervalSince(start)
                    
                    // Tilt: 0...3.5s to 25deg, hold till 5.0s, 5.0...8.5s back to 0deg
                    if elapsed < 3.5 {
                        let p = min(1.0, max(0, elapsed / 3.5))
                        let ease = 0.5 - cos(p * .pi) / 2 // easeInOut
                        currentTilt = 25.0 * ease
                    } else if elapsed < 5.0 {
                        currentTilt = 25.0
                    } else if elapsed < 8.5 {
                        let p = min(1.0, max(0, (elapsed - 5.0) / 3.5))
                        let ease = 0.5 - cos(p * .pi) / 2
                        currentTilt = 25.0 * (1.0 - ease)
                    } else {
                        currentTilt = 0.0
                    }
                    
                    // Cup Opacity: fade in 1.0...2.0s, fade out 5.6...6.6s
                    if elapsed > 1.0 && elapsed <= 2.0 {
                        cupOpacity = (elapsed - 1.0) / 1.0
                    } else if elapsed > 2.0 && elapsed <= 5.6 {
                        cupOpacity = 1.0
                    } else if elapsed > 5.6 && elapsed <= 6.6 {
                        cupOpacity = 1.0 - (elapsed - 5.6) / 1.0
                    } else {
                        cupOpacity = 0.0
                    }
                    
                    // Stream Progress: drops down 2.5...3.1s
                    if elapsed > 2.5 {
                        let p = min(1.0, max(0, (elapsed - 2.5) / 0.6))
                        streamProgress = CGFloat(pow(p, 2.0)) // easeIn
                    }
                    
                    // Stream Tail: finishes dropping 5.0...5.6s
                    if elapsed > 5.0 {
                        let p = min(1.0, max(0, (elapsed - 5.0) / 0.6))
                        streamTail = CGFloat(pow(p, 2.0))
                    }
                }
                
                // --- 2. Calculate coordinates ---
                let floatOffset = reduceMotion ? 0.0 : (isFloating ? -5.0 : 5.0)
                let teapotRect = CGRect(x: 16, y: 16 + floatOffset, width: w - 32, height: h - 32)
                let tw = teapotRect.width
                let th = teapotRect.height
                
                // Spout rotation math
                let anchor = CGPoint(x: teapotRect.minX + tw * 0.5, y: teapotRect.minY + th * 0.8)
                let spoutLocal = CGPoint(x: teapotRect.minX + tw * 0.78, y: teapotRect.minY + th * 0.32)
                let dx = spoutLocal.x - anchor.x
                let dy = spoutLocal.y - anchor.y
                
                let currentRad = currentTilt * .pi / 180
                let currentSpout = CGPoint(
                    x: anchor.x + dx * cos(currentRad) - dy * sin(currentRad),
                    y: anchor.y + dx * sin(currentRad) + dy * cos(currentRad)
                )
                
                // Target spout (at 25deg) determines where the cup sits
                let targetRad = 25.0 * .pi / 180
                let targetSpoutX = anchor.x + dx * cos(targetRad) - dy * sin(targetRad)
                
                let cupX = targetSpoutX + tw * 0.02
                let cupY = teapotRect.minY + th * 0.95
                let cupWidth = tw * 0.2
                let cupHeight = th * 0.15
                
                // --- 3. Draw Cup ---
                if cupOpacity > 0.01 {
                    var cupContext = context
                    cupContext.opacity = cupOpacity
                    
                    var path = Path()
                    path.move(to: CGPoint(x: cupX - cupWidth*0.4, y: cupY - cupHeight*0.5))
                    path.addLine(to: CGPoint(x: cupX + cupWidth*0.4, y: cupY - cupHeight*0.5))
                    path.addQuadCurve(to: CGPoint(x: cupX + cupWidth*0.2, y: cupY + cupHeight*0.4), control: CGPoint(x: cupX + cupWidth*0.4, y: cupY + cupHeight*0.3))
                    path.addLine(to: CGPoint(x: cupX - cupWidth*0.2, y: cupY + cupHeight*0.4))
                    path.addQuadCurve(to: CGPoint(x: cupX - cupWidth*0.4, y: cupY - cupHeight*0.5), control: CGPoint(x: cupX - cupWidth*0.4, y: cupY + cupHeight*0.3))
                    
                    cupContext.fill(path, with: .color(ZenColor.zenCream))
                    cupContext.stroke(path, with: .color(ZenColor.zenBrown), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                    
                    var teaPath = Path()
                    teaPath.addEllipse(in: CGRect(x: cupX - cupWidth*0.3, y: cupY - cupHeight*0.5 - cupHeight*0.1, width: cupWidth*0.6, height: cupHeight*0.25))
                    cupContext.fill(teaPath, with: .color(ZenColor.zenTeaRich))
                }
                
                // --- 4. Draw Water Stream ---
                if streamProgress > 0 && streamTail < 1 {
                    let endPoint = CGPoint(x: cupX, y: cupY - cupHeight*0.5)
                    var streamPath = Path()
                    streamPath.move(to: currentSpout)
                    let control = CGPoint(x: currentSpout.x + 5, y: (currentSpout.y + endPoint.y) * 0.5)
                    streamPath.addQuadCurve(to: endPoint, control: control)
                    
                    var waterContext = context
                    waterContext.stroke(
                        streamPath.trimmedPath(from: streamTail, to: streamProgress),
                        with: .color(ZenColor.zenTeaRich.opacity(0.85)),
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                    )
                    
                    if streamProgress > 0.95 && streamTail < 0.95 {
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        for i in 0..<3 {
                            let seed = Double(i)
                            let splashT = (time * 3.0 + seed).truncatingRemainder(dividingBy: 1.0)
                            let splashX = endPoint.x + CGFloat(sin(time * 8 + seed * 4)) * 6.0
                            let splashY = endPoint.y - CGFloat(splashT * 12.0)
                            let radius = CGFloat(1.5 - splashT * 1.5)
                            
                            if radius > 0 {
                                let rect = CGRect(x: splashX - radius, y: splashY - radius, width: radius * 2, height: radius * 2)
                                context.fill(Path(ellipseIn: rect), with: .color(ZenColor.zenTeaRich.opacity(1.0 - splashT)))
                            }
                        }
                    }
                }
                
                // --- 5. Draw Teapot ---
                var teapotContext = context
                teapotContext.translateBy(x: anchor.x, y: anchor.y)
                teapotContext.rotate(by: .degrees(currentTilt))
                teapotContext.translateBy(x: -anchor.x, y: -anchor.y)
                
                drawTeapot(in: teapotContext, rect: teapotRect)
                
                // --- 6. Draw Steam ---
                if !reduceMotion {
                    let refTime = timeline.date.timeIntervalSinceReferenceDate
                    
                    if !isPouring && streamProgress == 0 {
                        drawSteam(in: context, spoutPoint: currentSpout, now: refTime, duration: 3.5, count: steamCount)
                    } else if streamProgress > 0.5 {
                        let cupPoint = CGPoint(x: cupX, y: cupY - cupHeight*0.5)
                        drawSteam(in: context, spoutPoint: cupPoint, now: refTime, duration: 2.0, count: 4)
                    }
                }
            }
        }
        .onTapGesture {
            if startPourTime != nil { return } // prevent multiple taps
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // Play pour tea sound effect
            AudioService.shared.playEffect(name: "pour_tea")
            
            // Kick off the deterministic timeline animation
            startPourTime = Date()
            
            // Reset state fully when animation completely finishes (8.5s + padding)
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.6) {
                startPourTime = nil
            }
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
            }
        }
    }
    
    // Helper to draw Teapot
    private func drawTeapot(in context: GraphicsContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let minX = rect.minX
        let minY = rect.minY
        
        var handlePath = Path()
        handlePath.move(to: CGPoint(x: minX + w * 0.35, y: minY + h * 0.5))
        handlePath.addCurve(to: CGPoint(x: minX + w * 0.65, y: minY + h * 0.5),
                            control1: CGPoint(x: minX + w * 0.25, y: minY + h * 0.15),
                            control2: CGPoint(x: minX + w * 0.75, y: minY + h * 0.15))
        
        context.stroke(handlePath, with: .color(ZenColor.zenBrownDark), style: StrokeStyle(lineWidth: w * 0.03, lineCap: .round, dash: [w * 0.04, w * 0.02]))
        context.stroke(handlePath, with: .color(ZenColor.zenBrown.opacity(0.6)), style: StrokeStyle(lineWidth: w * 0.015, lineCap: .round))

        var spoutPath = Path()
        spoutPath.move(to: CGPoint(x: minX + w * 0.65, y: minY + h * 0.7))
        spoutPath.addCurve(to: CGPoint(x: minX + w * 0.78, y: minY + h * 0.32),
                           control1: CGPoint(x: minX + w * 0.85, y: minY + h * 0.6),
                           control2: CGPoint(x: minX + w * 0.75, y: minY + h * 0.38))
        spoutPath.addCurve(to: CGPoint(x: minX + w * 0.68, y: minY + h * 0.55),
                           control1: CGPoint(x: minX + w * 0.78, y: minY + h * 0.4),
                           control2: CGPoint(x: minX + w * 0.8, y: minY + h * 0.55))
        
        context.fill(spoutPath, with: .color(ZenColor.zenCream))
        context.stroke(spoutPath, with: .color(ZenColor.zenBrown), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

        var bodyPath = Path()
        let bodyWidth = w * 0.4
        let bodyHeight = h * 0.4
        let bodyRect = CGRect(x: minX + w * 0.5 - bodyWidth/2, y: minY + h * 0.45, width: bodyWidth, height: bodyHeight)
        bodyPath.addRoundedRect(in: bodyRect, cornerSize: CGSize(width: w * 0.08, height: w * 0.08))
        
        context.fill(bodyPath, with: .color(ZenColor.zenCream))
        context.stroke(bodyPath, with: .color(ZenColor.zenBrown), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

        var lidPath = Path()
        lidPath.move(to: CGPoint(x: minX + w * 0.38, y: minY + h * 0.45))
        lidPath.addQuadCurve(to: CGPoint(x: minX + w * 0.62, y: minY + h * 0.45), control: CGPoint(x: minX + w * 0.5, y: minY + h * 0.38))
        lidPath.closeSubpath()
        context.fill(lidPath, with: .color(ZenColor.zenCream))
        context.stroke(lidPath, with: .color(ZenColor.zenBrown), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        
        var knobPath = Path(ellipseIn: CGRect(x: minX + w * 0.47, y: minY + h * 0.37, width: w * 0.06, height: h * 0.03))
        context.fill(knobPath, with: .color(ZenColor.zenBrownDark))

        var leafPath = Path()
        leafPath.move(to: CGPoint(x: minX + w * 0.4, y: minY + h * 0.65))
        leafPath.addQuadCurve(to: CGPoint(x: minX + w * 0.6, y: minY + h * 0.65), control: CGPoint(x: minX + w * 0.5, y: minY + h * 0.55))
        leafPath.addQuadCurve(to: CGPoint(x: minX + w * 0.4, y: minY + h * 0.65), control: CGPoint(x: minX + w * 0.5, y: minY + h * 0.75))
        context.fill(leafPath, with: .color(ZenColor.zenSage.opacity(0.8)))
        context.stroke(leafPath, with: .color(ZenColor.zenTeaDeep), style: StrokeStyle(lineWidth: 1.5))
        
        var basePath = Path()
        basePath.move(to: CGPoint(x: minX + w * 0.35, y: minY + h * 0.85))
        basePath.addLine(to: CGPoint(x: minX + w * 0.65, y: minY + h * 0.85))
        basePath.addLine(to: CGPoint(x: minX + w * 0.63, y: minY + h * 0.88))
        basePath.addLine(to: CGPoint(x: minX + w * 0.37, y: minY + h * 0.88))
        basePath.closeSubpath()
        context.fill(basePath, with: .color(ZenColor.zenBrownDark))
    }
    
    // Helper to draw steam
    private func drawSteam(in context: GraphicsContext, spoutPoint: CGPoint, now: Double, duration: Double, count: Int) {
        for i in 0..<count {
            let seed = Double(i)
            let delay = seed * (duration / Double(count))
            let rawT = (now - delay).truncatingRemainder(dividingBy: duration + delay * 0.3)
            let t = min(1.0, max(0, rawT / duration))
            let eased = 1.0 - pow(1.0 - t, 2.0)
            
            let yOffset = eased * 70.0
            let xDrift = sin(now * 0.8 + seed * 1.4) * 8.0 + sin(seed * 2.1) * 4.0
            
            let pos = CGPoint(x: spoutPoint.x + CGFloat(xDrift), y: spoutPoint.y - CGFloat(yOffset))
            let baseRadius: CGFloat = 3.0 + CGFloat(seed.truncatingRemainder(dividingBy: 3.0))
            let radius = baseRadius * CGFloat(1.0 + eased * 1.8)
            
            let fadeIn = min(1.0, t * 4.0)
            let fadeOut = max(0, 1.0 - eased)
            let opacity = fadeIn * fadeOut * 0.35
            
            guard opacity > 0.01 else { continue }
            
            let rect = CGRect(x: pos.x - radius, y: pos.y - radius, width: radius * 2, height: radius * 2)
            var steamContext = context
            steamContext.addFilter(.blur(radius: eased * 4.0))
            steamContext.fill(Path(ellipseIn: rect), with: .color(ZenColor.zenSage.opacity(opacity * 0.8)))
        }
    }
}

#Preview {
    TeapotSceneView()
        .frame(width: 220, height: 220)
        .background(Color(hex: "E8D8C0"))
}
