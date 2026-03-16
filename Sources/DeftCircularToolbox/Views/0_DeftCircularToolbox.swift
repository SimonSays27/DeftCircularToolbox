import SwiftUI

public struct DeftCircularToolboxView: View {
    
    public init(vm: ToolboxViewModel) {
        self.vm = vm
    }
    
    @ObservedObject var vm: ToolboxViewModel
    @State var sliderFrameSize: CGFloat = 80
    
    let kinds: [ToolboxViewModel.Container] = [.writingTools, .mainTools, .colors]
    
    public var body: some View {
        
        ZStack {
            
            /// Show Slider
            let sliderMode: SliderMode = shouldShowSlider()
            let showKinds: [ToolboxViewModel.Container] = {
                switch sliderMode {
                case .closed, .eraser:
                    guard !vm.forceShowColors else { break }
                    return kinds.filter({ $0 != .colors })
                case .open: break
                }
                return kinds
            }()
            
            /// Tools and Colors
            ForEach(showKinds) { k in
                
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
                .scaleEffect(vm.formHidden ? 0.1 : 1.0)
                
            }
            
            /// Slider
            if case .open = sliderMode {
                CircularSlider(startAngle: .degrees(-70),
                               endAngle: .degrees(70),
                               percentage: $vm.sliderPercentage,
                               selectedColor: vm.selectedColor,
                               sliderOnEnd: { perc in vm.delegate?.sliderValueDidChange(perc) })
                    .frame(width: sliderFrameSize, height: sliderFrameSize)
                    .rotationEffect(vm.formHidden ? .radians(vm.activeRotation - .pi / 2) : .zero)
            }
            
            /// Eraser Options
            if case .eraser = sliderMode {
                EraserSelectionView(vm: vm)
            }
            
            /// Mid Circle
            MidCircleView(vm: vm)
            
        }
        .foregroundStyle(Color(vm.deskColors.fg))
        .onAppear {
            vm.delegate?.toolboxDidAppear()
        }
        
    }
    
    public enum SliderMode {
        case closed
        case open
        case eraser
    }
    
    private func shouldShowSlider() -> SliderMode {
        switch (vm.toolHandler.selectedTool?.slot ?? 0) {
        case 102:
            return .eraser
        case 99...200:
            return .closed
        default:
            return .open
        }
    }
    
}

struct MidCircleView: View {
    
    @ObservedObject var vm: ToolboxViewModel
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: vm.deskColors.bg))
                .frame(width: 44, height: 44)
                .shadow(radius: 3)
            
            /// Image
            if let img = vm.toolHandler.selectedTool?.image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
            }
        }
        .frame(width: 44, height: 44)
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                    let dragDistance = hypot(value.translation.width, value.translation.height)
                    if dragDistance > 5 {
                        vm.viewCenterDragged(value)
                    }
                }
                .onEnded { value in
                    let dragDistance = hypot(value.translation.width, value.translation.height)
                    if dragDistance < 6 {
                        let formIt = !vm.formHidden
                        let animation: Animation = vm.formHidden ? .easeOut(duration: 0.2) : .easeIn(duration: 0.2)
                        withAnimation(animation) {
                            vm.setForm(hidden: formIt)
                        }
                    } else {
                        vm.viewCenterDragged(value, didEnd: true)
                    }
                }
        )
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
