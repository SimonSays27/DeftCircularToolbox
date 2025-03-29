import SwiftUI

struct WedgeContainerView: View {
    
    @StateObject var vm: ToolboxViewModel

    let tools: [Tool]
    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat
    let action: (Int) -> Void
    
    var deskColor: Color { Color(uiColor: vm.deskColors.d) }
    var bgColor: Color { Color(uiColor: vm.deskColors.bg) }
    var fgColor: Color { Color(uiColor: vm.deskColors.fg) }
    
    @State var tappedTool: Tool?
    
    var body: some View {
        GeometryReader { geometry in
            
            let totalAngle = endAngle.degrees - startAngle.degrees
            let angleStep = totalAngle / Double(tools.count)
            let outerRadius = min(geometry.size.width, geometry.size.height) / 2
            
            ZStack {
                
                ForEach(Array(tools.enumerated()), id: \.element) { (index, tool) in
                    
                    let angle1 = startAngle + Angle(degrees: angleStep * Double(index))
                    let angle2 = startAngle + Angle(degrees: angleStep * Double(index + 1))
                    
                    let toolCenter = calculateCenter(startAngle: angle1,
                                                      endAngle: angle2,
                                                      innerRadius: innerRadius,
                                                      outerRadius: outerRadius,
                                                      inFrame: CGRect(origin: .zero, size: geometry.size))
                    
                    
                    if tool.kind == .color {
                        
                        if tool.isSelected {

                            Circle()
                                .fill(vm.selectedColor)
                                .frame(width: 30, height: 30)
                                .offset(x: toolCenter.x - geometry.size.width / 2,
                                        y: toolCenter.y - geometry.size.height / 2)
                                .zIndex(99)
                                .onTapGesture {
                                    vm.shouldShowColorPicker()
                                }
                            
//                            ColorPickerView(selectedColor: $tempColor)
//                                .modifierIf(UIScreen.main.scale == 3, transform: { view in
//                                    view.scaleEffect(1.2)
//                                })
//                                .offset(x: toolCenter.x - geometry.size.width / 2,
//                                        y: toolCenter.y - geometry.size.height / 2)
//                                .zIndex(99)
//                                .onChange(of: tempColor) { oldValue, newValue in
//                                    vm.userDidChangeColor(newValue)
//                                }
                            
                        } else {
                            WedgeShape(startAngle: angle1,
                                       endAngle: angle2,
                                       innerRadius: innerRadius,
                                       outerRadius: outerRadius,
                                       strokeWidth: 0)
                            .fill(tool.color)
                            .onTapGesture(count: 1) {
                                action(tool.id)
                            }
                        }
                        
                    } else {
                        
                        WedgeShape(startAngle: angle1,
                                   endAngle: angle2,
                                   innerRadius: innerRadius,
                                   outerRadius: outerRadius,
                                   strokeWidth: 2)
                        .fill(
                            tappedTool == tool
                            ? fgColor
                            : (tool.isSelected ? fgColor : bgColor)
                        )
                        .stroke(bgColor, lineWidth: tool.isSelected ? 4: 0)
                        .onTapGesture {
                            action(tool.id)
                            withAnimation {
                                tappedTool = tool
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    tappedTool = nil
                                }
                            }
                        }
                        
                        if let img = tool.image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(tool.isSelected ? bgColor : fgColor, tool.isSelected ? bgColor : fgColor)
                                .position(toolCenter)
                                .allowsHitTesting(false)
                        }
                        
                    }
                    
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            
        }
        
    }
    
    
    func calculateCenter(startAngle: Angle, endAngle: Angle, innerRadius: CGFloat, outerRadius: CGFloat, inFrame: CGRect) -> CGPoint {
        // Step 1: Calculate the midpoint angle (the average of startAngle and endAngle)
        let midpointAngle = Angle(radians: (startAngle.radians + endAngle.radians) / 2)
        
        // Step 2: Calculate the midpoint radius (average of inner and outer radius)
        let midpointRadius = (innerRadius + outerRadius) / 2
        
        // Step 3: Convert polar coordinates (midpointRadius, midpointAngle) to Cartesian coordinates
        let x = midpointRadius * cos(CGFloat(midpointAngle.radians))
        let y = midpointRadius * sin(CGFloat(midpointAngle.radians))
        
        return CGPoint(x: x + inFrame.midX, y: y + inFrame.midY)
    }
    
}
