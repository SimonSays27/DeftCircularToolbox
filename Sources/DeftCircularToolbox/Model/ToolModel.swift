import SwiftUI
import DeftCore

public struct Tool: Identifiable, Hashable {
    
    public init(kind: Kind) {
        self.kind = kind
    }
    
    /// Identifying
    public var id: Int { slot }
    public var propertyId: String?
    public var slot: Int = 0
    
    /// Converting to PKTool
    public var toolWidthPercentage: CGFloat?
    public var writingToolKind: String = ""
    public var colorHex: String? = nil

    /// SwiftUI part
    let kind: Kind
    var isAction: Bool = false
    var color: Color { Color(uiColor: UIColor(hex: colorHex ?? "") ?? .black) }
    var isSelected: Bool = false
    public var image: UIImage? = nil
    
}

extension Tool {
    public enum Kind {
        case tool
        case color
    }
}

extension Tool {
    public enum EraserMode: String {
        case pixel
        case object
    }
}
