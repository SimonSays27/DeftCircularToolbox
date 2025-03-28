import Foundation

extension ToolboxViewModel {
    
    public enum Container: String, Identifiable {
        public var id: String { return rawValue }
        case writingTools
        case mainTools
        case colors
    }
    
}
