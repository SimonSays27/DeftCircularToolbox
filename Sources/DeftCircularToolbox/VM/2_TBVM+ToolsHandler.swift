import SwiftUI

extension ToolboxViewModel {
    
    public class ToolsHandler: SelectableHandler, ObservableObject {
        
        @Published var writingTools: [Tool] = (0..<4).map({ i in
            var tool = Tool(kind: .tool)
            tool.slot = i
            switch i {
            case 0:
                tool.colorHex = "000000"
                tool.image = .init(systemName: "highlighter")?.withRenderingMode(.alwaysTemplate)
            case 1:
                tool.colorHex = "A66C42"
                tool.image = .init(systemName: "pencil.and.scribble")?.withRenderingMode(.alwaysTemplate)
            case 2:
                tool.colorHex = "66B96F"
                tool.image = .init(systemName: "pencil")?.withRenderingMode(.alwaysTemplate)
            case 3:
                tool.colorHex = "5B7DB5"
                tool.image = .init(systemName: "pencil")?.withRenderingMode(.alwaysTemplate)
            default:
                break
            }
            return tool
        })
        
        @Published var mainTools: [Tool] = (0..<4).map({ i in
            var tool = Tool(kind: .tool)
            tool.slot = i + 100
            switch i {
            case 0:
                tool.isAction = true
                tool.image = .init(systemName: "arrow.uturn.forward")?.withRenderingMode(.alwaysTemplate)
            case 1:
                tool.isAction = true
                tool.image = .init(systemName: "arrow.uturn.backward")?.withRenderingMode(.alwaysTemplate)
            case 2:
                tool.image = .init(systemName: "eraser")?.withRenderingMode(.alwaysTemplate)
            case 3:
                tool.image = .init(systemName: "cursorarrow")?.withRenderingMode(.alwaysTemplate)
            default:
                break
            }
            return tool
        })
        
        public var selectedTool: Tool? { return writingTools.first(where: { $0.isSelected}) ?? mainTools.first(where: { $0.isSelected }) }
        // @Published var selectedTool: Tool?
        
        @discardableResult
        override func select(_ container: Container, slot: Int) -> Tool? {
            
            var returningElement: Tool?
            var elements: [Tool] = {
                switch container {
                case .writingTools: return writingTools
                default: return mainTools
                }
            }()
            guard let index = elements.firstIndex(where: { $0.slot == slot }) else { return nil }
            
            returningElement = elements[index]
            
            if elements[index].isAction {
                /// Do the action
                print("log0223 action is \(String(describing: returningElement?.slot))")
                return returningElement
            }
            
            for i in elements.indices {
                if i == index { elements[i].isSelected = true }
                else { elements[i].isSelected = false }
            }
            
            switch container {
            case .writingTools: writingTools = elements
            default: mainTools = elements
            }
            
            /// ShouldDeselect other
            deselect(container == .mainTools ? .writingTools : .mainTools)
            
            ///
            return returningElement
        }
        func deselect(_ container: Container) {
            var elements: [Tool] = {
                switch container {
                case .writingTools: return writingTools
                default: return mainTools
                }
            }()
            for i in elements.indices {
                elements[i].isSelected = false
            }
            switch container {
            case .writingTools: writingTools = elements
            default: mainTools = elements
            }
        }
    }
}
