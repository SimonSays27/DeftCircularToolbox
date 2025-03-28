import SwiftUI

struct WedgeShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    let strokeWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        let calculatedInner = innerRadius + strokeWidth
        let calculatedOuter = outerRadius// - strokeWidth
        
        let startInner = CGPoint(
            x: center.x + calculatedInner * cos(CGFloat(startAngle.radians)),
            y: center.y + calculatedInner * sin(CGFloat(startAngle.radians))
        )
        let startOuter = CGPoint(
            x: center.x + calculatedOuter * cos(CGFloat(startAngle.radians)),
            y: center.y + calculatedOuter * sin(CGFloat(startAngle.radians))
        )
        let endInner = CGPoint(
            x: center.x + calculatedInner * cos(CGFloat(endAngle.radians)),
            y: center.y + calculatedInner * sin(CGFloat(endAngle.radians))
        )
        
        path.move(to: startInner)
        path.addLine(to: startOuter)
        path.addArc(center: center, radius: calculatedOuter, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addLine(to: endInner)
        path.addArc(center: center, radius: calculatedInner, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        path.closeSubpath()
        
        return path
    }
}
