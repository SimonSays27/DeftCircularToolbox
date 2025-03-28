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
    
    /* Selection */
    @Published var selectedTool: Tool?
    @Published var selectedColor: Tool?
    @Published var sliderPercentage: Double = 33
    
    /* API */
    public func load(toContainer: Container, loads: [Tool]) {
        switch toContainer {
        case .colors: colorHandler.colorWedges = loads
        case .writingTools: toolHandler.writingTools = loads
        case .mainTools: toolHandler.mainTools = loads
        }
        /// Select If Needed
        guard let selected = loads.first(where: { $0.isSelected }) else { return }
        self.select(of: toContainer, id: selected.id)
    }
    public func select(of container: Container, id: String, isUserSelection: Bool = false) {
        switch container {
        case .colors:
            /// colorHandler.select(container, id: id)
            /// Instead change the tools color if not the same
            print("log0223 select of colors \(id)")
            guard let willChangeToColor = colorHandler.colorWedges.first(where: { $0.id == id }) else { return }
            /// Get the current tool
            if let current = toolHandler.writingTools.first(where: { $0.isSelected }) {
                /// update the color value
                if current.colorHex != willChangeToColor.colorHex {
                    delegate?.currentToolColorUpdated(withHex: willChangeToColor.colorHex ?? "")
                }
            }
            break
        default:
            /// Select tool
            toolHandler.select(container, id: id)
            /// Select the tools color
            if let selectedTool = toolHandler.writingTools.first(where: { $0.isSelected }),
               let hex = selectedTool.colorHex
            {
                colorHandler.selectColorHex(hex)
            }
        }
        /// Notify Delegate if needed
        if isUserSelection {
            delegate?.didSelect(container, id: id)
        }
    }
    
    /* ALL TOOLs */
    @Published var tools: [Container: [Tool]] = [.writingTools: [], .mainTools: [], .colors: []]
    
    /* TOOLs */
    public var toolHandler = ToolsHandler()
    private var writingToolsListener: AnyCancellable?
    private var mainToolsListener: AnyCancellable?
    private func listenToToolsHandler() {
        writingToolsListener = toolHandler.$writingTools
            .assign(to: \.tools[.writingTools]!, on: self)
        mainToolsListener = toolHandler.$mainTools
            .assign(to: \.tools[.mainTools]!, on: self)
    }
    
    /* COLORs */
    @Published var selectedColor: Color = .red
    public var colorHandler = ColorHandler()
    private var selectedColorListener: AnyCancellable?
    private var colorListener: AnyCancellable?
    private func listenToColorHandler() {
        colorListener = colorHandler.$colorWedges
            .assign(to: \.tools[.colors]!, on: self)
        selectedColorListener = colorHandler.$selectedColor
            .assign(to: \.selectedColor, on: self)
    }
    private let colorDebouncer = DDebouncer(delay: 0.1)
    public func userDidChangeColor(_ newColor: Color) {
        print("log0223 user did change color to ")
        colorDebouncer.debounce {
            if let selectedSlot = self.colorHandler.colorWedges.firstIndex(where: { $0.isSelected }) {
                print("log0223 selected color tool is \(selectedSlot)")
                let uiColor = UIColor(newColor)
                self.delegate?.userDidChangeColor(slot: selectedSlot, withHex: uiColor.hexWithAlpha)
            }
        }
    }
    
    /* SLIDER */
    @Published var sliderPercentage: Double = 33
    
}



extension ToolboxViewModel {
    
    /* DragGesture call */
    func viewCenterDragged(_ val: DragGesture.Value, didEnd: Bool = false) {
        delegate?.viewCenterDragged(val, didEnd: didEnd)
    }
    
}
