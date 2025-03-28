import SwiftUI

struct CircularSlider: View {
    
    let startAngle: Angle
    let endAngle: Angle
    @Binding var percentage: Double
    @Binding var selectedColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2
            let angleRange = normalizedAngle(endAngle.degrees - startAngle.degrees)
            let currentAngle = startAngle.degrees + (percentage / 100) * angleRange
            let knobPosition = pointOnCircle(center: CGPoint(x: radius, y: radius),
                                             radius: radius,
                                             angle: currentAngle)
            
            ZStack {
                // Background Arc
                Path { path in
                    path.addArc(center: CGPoint(x: radius, y: radius),
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: false)
                }
                .stroke(selectedColor, lineWidth: 4)
                
                // Knob
                Circle()
                    .fill(selectedColor)
                    .frame(width: 20, height: 20)
                    .position(knobPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                
                                var newAngle = angleFromPoint(center: CGPoint(x: radius, y: radius),
                                                              point: value.location)
                                
                                if newAngle < startAngle.degrees || newAngle > endAngle.degrees {
                                    let lowDiff = abs(newAngle - startAngle.degrees)
                                    let highDiff = abs(newAngle - endAngle.degrees)
                                    if lowDiff < highDiff {
                                        newAngle = startAngle.degrees
                                    } else {
                                        newAngle = endAngle.degrees
                                    }
                                }
                                
                                percentage = ((newAngle - startAngle.degrees) / angleRange) * 100
                            }
                            .onEnded({ val in
                                //
                            })
                    )
            }
        }
    }
    
    /// Calculates a point on the circle given an angle
    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let radians = CGFloat(angle * .pi / 180)
        return CGPoint(x: center.x + radius * cos(radians),
                       y: center.y + radius * sin(radians))
    }
    
    /// Normalizes the angle to the 0-360 range
    private func normalizedAngle(_ angle: Double) -> Double {
        return (angle.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
    }
    
    /// Converts a point to an angle and ensures it is in the correct range
    private func angleFromPoint(center: CGPoint, point: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let radians = atan2(dy, dx)
        let degrees = radians * 180 / .pi
        return degrees
    }
    
    /// Ensures the angle is in the correct range relative to the start angle
    private func normalizeAngle(_ angle: Double, relativeTo startAngle: Double) -> Double {
        let normalized = normalizedAngle(angle)
        let normalizedStart = normalizedAngle(startAngle)
        
        if normalized < normalizedStart {
            return normalized + 360
        }
        return normalized
    }
}

struct CircularSliderCV: View {
    @State private var sliderValue: Double = 50
    @State private var color: Color = .red
    
    var body: some View {
        CircularSlider(startAngle: .degrees(-80),
                       endAngle: .degrees(80),
                       percentage: $sliderValue,
                       selectedColor: $color)
        .frame(width: 150, height: 150, alignment: .center)
    }
}

#Preview {
    CircularSliderCV()
}
