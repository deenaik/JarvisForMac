import SwiftUI

struct WaveformView: View {
    var audioLevel: CGFloat = 0.5
    var color: Color = .green
    var isAnimating: Bool = true

    @State private var phase: Double = 0

    private let waveCount = 3
    private let baseHeight: CGFloat = 20

    var body: some View {
        Canvas { context, size in
            let midY = size.height / 2
            let width = size.width

            for i in 0..<waveCount {
                let wavePhase = phase + Double(i) * 0.8
                let amplitude = baseHeight * audioLevel * (1.0 - Double(i) * 0.25)
                let opacity = 1.0 - Double(i) * 0.3

                var path = Path()
                path.move(to: CGPoint(x: 0, y: midY))

                for x in stride(from: CGFloat(0), through: width, by: 2) {
                    let relativeX = Double(x / width)
                    let sine = sin(relativeX * Double.pi * 3 + wavePhase)
                    let envelope = sin(relativeX * Double.pi) // fade edges
                    let y = midY + CGFloat(sine) * amplitude * CGFloat(envelope)
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                context.stroke(
                    path,
                    with: .color(color.opacity(opacity)),
                    lineWidth: 2
                )
            }
        }
        .frame(height: 60)
        .onChange(of: isAnimating) { _, newValue in
            if newValue { startAnimation() }
        }
        .onAppear {
            if isAnimating { startAnimation() }
        }
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            phase = .pi * 2
        }
    }
}
