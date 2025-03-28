import SwiftUI
import DeftCore

public struct Tool: Identifiable, Hashable {
    public init(id: String, kind: Kind, isAction: Bool = false, colorHex: String? = nil, isSelected: Bool = false, image: UIImage? = nil) {
        self.id = id
        self.kind = kind
        self.isAction = isAction
        self.colorHex = colorHex
        self.isSelected = isSelected
        self.image = image
    }
    public let id: String
    let kind: Kind
    var isAction: Bool
    var color: Color { Color(uiColor: UIColor(hex: colorHex ?? "") ?? .black) }
    var colorHex: String?
    var isSelected: Bool
    var image: UIImage?
}

extension Tool {
    public enum Kind {
        case tool
        case color
    }
}
