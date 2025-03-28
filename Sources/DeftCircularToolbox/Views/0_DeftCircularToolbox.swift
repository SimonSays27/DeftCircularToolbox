import SwiftUI

public struct DeftCircularToolboxView: View {
    
    public init(vm: ToolboxViewModel) {
        self.vm = vm
    }
    
    @ObservedObject var vm: ToolboxViewModel
    @State var formHidden: Bool = false
    @State var sliderFrameSize: CGFloat = 80
    
    let kinds: [ToolboxViewModel.Container] = [.writingTools, .mainTools, .colors]
    
    public var body: some View {
        
        ZStack {
            
            Circle()
                .fill(Color.clear)
                .strokeBorder(Color.black, lineWidth: 10) // Create the "blank" area in the middle
                .frame(width: 148, height: 148)
                .shadow(radius: 5)
                .scaleEffect(formHidden ? 0.1 : 1.0)
            
            /// Tools and Colors
            ForEach(kinds) { k in
                
                let sess: (startAngle: Angle, endAngle: Angle, innerRadius: CGFloat, outerRadius: CGFloat) = {
                    switch k {
                    case .colors:
                        return (.degrees(-90), .degrees(90), 60, 150)
                    case .mainTools:
                        return (.degrees(90), .degrees(270), 19, 100)
                    case .writingTools:
                        return (.degrees(90), .degrees(270), 50, 150)
                    }
                }()
                
                WedgeContainerView(vm: vm,
                                   tools: vm.tools[k] ?? [],
                                   startAngle: sess.startAngle,
                                   endAngle: sess.endAngle,
                                   innerRadius: sess.innerRadius,
                                   action: { id in
                    vm.select(of: k, id: id, isUserSelection: true)
                })
                .frame(width: sess.outerRadius, height: sess.outerRadius)
                .scaleEffect(formHidden ? 0.1 : 1.0)
                
            }
            
            /// Slider
            CircularSlider(startAngle: .degrees(-70),
                           endAngle: .degrees(70),
                           percentage: $vm.sliderPercentage,
                           selectedColor: $vm.selectedColor)
                .frame(width: sliderFrameSize, height: sliderFrameSize)
            
            /// Mid Circle
            Circle()
                .fill(Color(uiColor: vm.deskColors.bg))
                .frame(width: 36, height: 36)
                .shadow(radius: 3)
                .onTapGesture {
                    let animation: Animation = formHidden ? .easeOut(duration: 0.2) : .easeIn(duration: 0.2)
                    withAnimation(animation) {
                        formHidden.toggle()
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            vm.viewCenterDragged(value)
                        }
                        .onEnded({ value in
                            vm.viewCenterDragged(value, didEnd: true)
                        })
                )
            
        }
        
    }
}

#Preview {
    let vm = ToolboxViewModel(delegate: nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        vm.load(toContainer: .colors, loads:[
            Tool(id: "color_1", kind: .color, colorHex: "5B7DB5"),
            Tool(id: "color_2", kind: .color, colorHex: "6CA1D9"),
            Tool(id: "color_3", kind: .color, colorHex: "E57373"),
            Tool(id: "color_4", kind: .color, colorHex: "66B96F", isSelected: true),
            Tool(id: "color_5", kind: .color, colorHex: "F8A546"),
            Tool(id: "color_6", kind: .color, colorHex: "D1A3D7"),
            Tool(id: "color_7", kind: .color, colorHex: "A66C42"),
            Tool(id: "color_8", kind: .color, colorHex: "000000")
        ])
        vm.select(of: .writingTools, id: "tool_1")
    }
    return DeftCircularToolboxView(vm: vm)
}
