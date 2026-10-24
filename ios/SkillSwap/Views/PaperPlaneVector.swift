import SwiftUI

// MARK: - Native Paper Plane Vector with Dotted Flight Path

struct PaperPlaneHeaderDecoration: View {
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        HStack {
            Spacer()
            ZStack(alignment: .trailing) {
                // Curved dotted flight path
                PaperPlaneFlightPath()
                    .stroke(
                        SkillSwapTheme.coral.opacity(0.65),
                        style: StrokeStyle(lineWidth: 1.8, lineCap: .round, dash: [4, 4])
                    )
                    .frame(width: 86, height: 44)
                    .offset(x: -24, y: 8)

                // Vector Paper Plane
                PaperPlaneShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 238/255, green: 135/255, blue: 105/255),
                                Color(red: 218/255, green: 105/255, blue: 76/255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 32)
                    .rotationEffect(.degrees(12))
                    .shadow(color: SkillSwapTheme.coral.opacity(0.35), radius: 4, x: 1, y: 2)
            }
            .frame(width: 120, height: 50)
            .offset(y: floatOffset)
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2.8).repeatForever(autoreverses: true)
            ) {
                floatOffset = -4
            }
        }
    }
}

struct PaperPlaneFlightPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY * 0.7))
        p.addCurve(
            to: CGPoint(x: rect.maxX * 0.45, y: rect.minY * 0.3),
            control1: CGPoint(x: rect.minX + 15, y: rect.maxY * 0.8),
            control2: CGPoint(x: rect.maxX * 0.25, y: rect.maxY * 0.1)
        )
        p.addCurve(
            to: CGPoint(x: rect.maxX * 0.5, y: rect.maxY * 0.8),
            control1: CGPoint(x: rect.maxX * 0.65, y: rect.minY * 0.4),
            control2: CGPoint(x: rect.maxX * 0.6, y: rect.maxY * 0.7)
        )
        p.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY * 0.4),
            control1: CGPoint(x: rect.maxX * 0.38, y: rect.maxY * 0.9),
            control2: CGPoint(x: rect.maxX * 0.82, y: rect.maxY * 0.75)
        )
        return p
    }
}

struct PaperPlaneShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        
        // Nose point
        let nose = CGPoint(x: w, y: h * 0.15)
        // Back top
        let topWing = CGPoint(x: 0, y: h * 0.5)
        // Center fold back
        let centerFold = CGPoint(x: w * 0.35, y: h * 0.65)
        // Lower wing back
        let bottomWing = CGPoint(x: w * 0.2, y: h)
        
        // Main top wing
        p.move(to: nose)
        p.addLine(to: topWing)
        p.addLine(to: centerFold)
        p.closeSubpath()
        
        // Lower underside wing
        p.move(to: nose)
        p.addLine(to: centerFold)
        p.addLine(to: bottomWing)
        p.closeSubpath()
        
        return p
    }
}
