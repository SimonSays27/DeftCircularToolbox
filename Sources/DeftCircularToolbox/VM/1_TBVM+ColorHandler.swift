import SwiftUI
import DeftCore

/** Selectable Handler */
extension ToolboxViewModel {
    public class SelectableHandler {
        @discardableResult func select(_ container: Container, slot: Int) -> Tool? { return nil }
    }
}


/** Color Handler */
extension ToolboxViewModel {
    
    public class ColorHandler: SelectableHandler, ObservableObject {
        
        @Published var colorWedges: [Tool] = []
        
        public var selectedTool: Tool? { return colorWedges.first(where: { $0.isSelected}) }

        @Published var selectedColor: Color = .black
        
        func selectColorHex(_ hex: String) {
            print("log0222 selectColorHex \(hex)")
            /// Find the color wedge
            for (_, c) in colorWedges.enumerated() {
                guard let colorHex = c.colorHex else { continue }
                print("log0222 colorHex \(colorHex) - hex \(hex)")
                if hex == colorHex {
                    /// Select it
                    select(.colors, slot: c.slot)
                    return
                }
            }
            /// Deselect all colors
            var new = colorWedges
            for i in new.indices {
                new[i].isSelected = false
            }
            colorWedges = new
            /// Otherwise set the color according to hex
            selectedColor = Color(uiColor: UIColor(hex: hex) ?? .black)
        }
        
        @discardableResult
        override func select(_ container: Container, slot: Int) -> Tool? {
            
            var returningElement: Tool?
            var elements = colorWedges
            
            guard let index = elements.firstIndex(where: { $0.slot == slot }) else { return nil }
            
            returningElement = elements[index]
            
            if elements[index].isAction { return returningElement }
            
            for i in elements.indices {
                if i == index { elements[i].isSelected = true }
                else { elements[i].isSelected = false }
            }
            
            colorWedges = elements
            
            /// Set Selected Color
            if let colorHex = elements[index].colorHex {
                selectedColor = Color(uiColor: UIColor(hex: colorHex) ?? .black)
            }
            
            return returningElement
        }
    }
    
}
