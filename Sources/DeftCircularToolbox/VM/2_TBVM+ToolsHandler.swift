import SwiftUI

extension ToolboxViewModel {
    
    public class ToolsHandler: SelectableHandler, ObservableObject {
        
        @Published var writingTools: [Tool] = [
            Tool(id: "tool_4", kind: .tool, image: .init(systemName: "highlighter")?.withRenderingMode(.alwaysTemplate)),
            Tool(id: "tool_3", kind: .tool, image: .init(systemName: "pencil.and.scribble")?.withRenderingMode(.alwaysTemplate)),
            Tool(id: "tool_2", kind: .tool, image: .init(systemName: "pencil")?.withRenderingMode(.alwaysTemplate)),
            Tool(id: "tool_1", kind: .tool, image: .init(systemName: "pencil")?.withRenderingMode(.alwaysTemplate)),
        ]
        
        @Published var mainTools: [Tool] = [
            Tool(id: "redo", kind: .tool, isAction: true, image: .init(systemName: "arrow.uturn.forward")?.withRenderingMode(.alwaysTemplate)),
            Tool(id: "undo", kind: .tool, isAction: true, image: .init(systemName: "arrow.uturn.backward")?.withRenderingMode(.alwaysTemplate)),
            Tool(id: "eraser", kind: .tool, image: .init(systemName: "eraser")?.withRenderingMode(.alwaysTemplate)),
            Tool(id: "lasso", kind: .tool, image: .init(systemName: "cursorarrow")?.withRenderingMode(.alwaysTemplate))
        ]
        
        public var selectedTool: Tool? { return writingTools.first(where: { $0.isSelected}) }
        
        @discardableResult
        override func select(_ container: Container, id: String) -> Tool? {
            
            var returningElement: Tool?
            var elements: [Tool] = {
                switch container {
                case .writingTools: return writingTools
                default: return mainTools
                }
            }()
            guard let index = elements.firstIndex(where: { $0.id == id }) else { return nil }
            
            returningElement = elements[index]
            
            if elements[index].isAction {
                /// Do the action
                print("log0223 action is \(returningElement?.id)")
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
