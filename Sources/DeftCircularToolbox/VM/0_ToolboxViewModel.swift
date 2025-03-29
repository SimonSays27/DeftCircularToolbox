import SwiftUI
import Combine
import DeftCore

public class ToolboxViewModel: ObservableObject {
    
    /** Initiation */
    weak var delegate: ToolboxViewModelDelegate?
    public init(delegate: ToolboxViewModelDelegate?) {
        self.delegate = delegate
        listenToColorHandler()
        listenToToolsHandler()
    }
    
    /* UI Colors */
    @Published public var deskColors: (d: UIColor, bg: UIColor, fg: UIColor) = (#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1), #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1))
    
    /* API */
    public func updateLoad(_ container: Container, update: (inout [Tool]) -> Void) {
        print("log0222 updateload called for \(container)")
        var tools: [Tool]
        /// Get
        switch container {
        case .colors: tools = colorHandler.colorWedges
        case .writingTools: tools = toolHandler.writingTools
        case .mainTools: tools = toolHandler.mainTools
        }
        /// Update
        update(&tools)
        /// Set back
        switch container {
        case .colors: colorHandler.colorWedges = tools
        case .writingTools: toolHandler.writingTools = tools
        case .mainTools: toolHandler.mainTools = tools
        }
    }
    
    public func selectTool(_ tool: Tool? = nil, slot: Int? = nil) {
        let slot = tool?.slot ?? slot ?? toolHandler.selectedTool?.slot ?? 0
        var selectedTool: Tool?
        
        /// If it's an action
        if let tool = toolHandler.writingTools.first(where: { $0.slot == slot }) ??
            toolHandler.mainTools.first(where: { $0.slot == slot }),
           tool.isAction
        {
            /// it's action
            print("log0225 it's action")
            return
        }
        
        /// Otherwise, update
        for k in [Container.writingTools, .mainTools] {
            updateLoad(k) { tools in
                for (i, t) in tools.enumerated() {
                    let willSelect = (t.slot == slot)
                    tools[i].isSelected = willSelect
                    if willSelect { selectedTool = tools[i] }
                }
            }
        }
        
        /// Set the color and shit
        guard let selectedTool = selectedTool else { return }
        let colorHex = selectedTool.colorHex ?? ""
        colorHandler.selectColorHex(colorHex)
        
        /// Notify Delegate
        delegate?.toolSelectionDidChange(to: selectedTool)
    }
    
    func userDidTap(_ container: Container, slot: Int) {
        print("log0225 userDidTap \(container) - \(slot)")
        /// Loop update, Deselect other
        switch container {
        case .writingTools, .mainTools: selectTool(slot: slot)
        case .colors:
            guard var selectedTool = toolHandler.selectedTool else { return }
            /// Update the color of the current tool
            selectedTool.colorHex = colorHandler.colorWedges.first(where: { $0.slot == slot })?.colorHex
            /// Select the current tool again
            let writingContainer: Container = {
                if toolHandler.writingTools.contains(where: { $0.slot == selectedTool.slot }) { return .writingTools }
                return .mainTools
            }()
            print("log0225 will update \(writingContainer) - with \(selectedTool.slot) ")
            updateLoad(writingContainer) { tool in
                for i in tool.indices {
                    if tool[i].slot == selectedTool.slot {
                        tool[i] = selectedTool
                    }
                }
            }
            /// Now select
            selectTool(selectedTool)
            /// Notify Delegate
            delegate?.colorSelectionDidChange(of: selectedTool)
        }

    }
    
    /* ALL TOOLs */
    @Published var tools: [Container: [Tool]] = [.writingTools: [], .mainTools: [], .colors: []]
    
    /* Listeners */
    private var cancellables: Set<AnyCancellable> = []
    
    /* TOOLs */
    public var toolHandler = ToolsHandler()
    private func listenToToolsHandler() {
        toolHandler.$writingTools
            .assign(to: \.tools[.writingTools]!, on: self)
            .store(in: &cancellables)
        toolHandler.$mainTools
            .assign(to: \.tools[.mainTools]!, on: self)
            .store(in: &cancellables)
    }
    
    /* COLORs */
    @Published var selectedColor: Color = .black
    public var colorHandler = ColorHandler()
    private func listenToColorHandler() {
        colorHandler.$colorWedges
            .assign(to: \.tools[.colors]!, on: self)
            .store(in: &cancellables)
        colorHandler.$selectedColor
            .assign(to: \.selectedColor, on: self)
            .store(in: &cancellables)
    }
    private let colorDebouncer = DDebouncer(delay: 0.1)
    public func userDidChangeColor(_ newColor: Color) {
        print("log0223 user did change color to ")
        colorDebouncer.debounce {
            if let selectedColor = self.colorHandler.colorWedges.first(where: { $0.isSelected }) {
                print("log0223 selected color tool is \(selectedColor.slot)")
                let uiColor = UIColor(newColor)
                let hex = uiColor.hexWithAlpha
                
                /// UPDATE COLOR WEDGE
                for (i, w) in self.colorHandler.colorWedges.enumerated() {
                    if w.slot == selectedColor.slot {
                        self.colorHandler.colorWedges[i].colorHex = hex; return
                    }
                }
                
                /// UPDATE SELECTED TOOL
                guard var selectedTool = self.toolHandler.selectedTool else { return }
                /// Update the color of the current tool
                selectedTool.colorHex = hex
                /// Notify
                self.delegate?.toolSelectionDidChange(to: selectedTool)
                
            }
        }
    }
    
    /* Color Picker Color */
    @Published var colorPickerColor: Color = .black
    
    /* SLIDER */
    @Published var sliderPercentage: Double = 33
    
}



extension ToolboxViewModel {
    
    /* DragGesture call */
    func viewCenterDragged(_ val: DragGesture.Value, didEnd: Bool = false) {
        delegate?.viewCenterDragged(val, didEnd: didEnd)
    }
    
    /* Should Show Color Picker */
    func shouldShowColorPicker() {
        delegate?.shouldShowColorPicker()
    }
    
}
