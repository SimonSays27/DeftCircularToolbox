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
                
                let sess: (startAngle: Angle,
                           endAngle: Angle,
                           innerRadius: CGFloat,
                           outerRadius: CGFloat,
                           toolsToLoad: [Tool]) = {
                    switch k {
                    case .colors:
                        return (.degrees(-90), .degrees(90), 60, 150, vm.tools[k] ?? [])
                    case .mainTools:
                        return (.degrees(90), .degrees(270), 19, 100, vm.tools[k] ?? [])
                    case .writingTools:
                        return (.degrees(90), .degrees(270), 50, 150, vm.tools[k]?.reversed() ?? [])
                    }
                }()
                                
                WedgeContainerView(vm: vm,
                                   tools: sess.toolsToLoad,
                                   startAngle: sess.startAngle,
                                   endAngle: sess.endAngle,
                                   innerRadius: sess.innerRadius,
                                   action: { slot in vm.userDidTap(k, slot: slot) })
                .frame(width: sess.outerRadius, height: sess.outerRadius)
                .scaleEffect(formHidden ? 0.1 : 1.0)
                
            }
            
            /// Slider
            CircularSlider(startAngle: .degrees(-70),
                           endAngle: .degrees(70),
                           percentage: $vm.sliderPercentage,
                           selectedColor: vm.selectedColor,
                           sliderOnEnd: { perc in vm.delegate?.sliderValueDidChange(perc) })
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
        .onAppear {
            vm.delegate?.toolboxDidAppear()
        }
        
    }
}

#Preview {
    let vm = ToolboxViewModel(delegate: nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        vm.updateLoad(.colors) { currentColors in
            currentColors = (0..<8).map { i in
                var color = Tool(kind: .color)
                color.colorHex = {
                    switch i {
                    case 0: return "000000"
                    case 1: return "5B7DB5"
                    case 2: return "6CA1D9"
                    case 3: return "E57373"
                    case 4: return "66B96F"
                    case 5: return "F8A546"
                    case 6: return "D1A3D7"
                    case 7: return "A66C42"
                    default: return ""
                    }
                }()
                return color
            }
        }
        vm.selectTool(slot: 2)
    }
    return DeftCircularToolboxView(vm: vm)
}
