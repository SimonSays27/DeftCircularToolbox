import SwiftUI

public protocol ToolboxViewModelDelegate: AnyObject {
    func viewCenterDragged(_ val: DragGesture.Value, didEnd: Bool)
    func didSelect(_ container: ToolboxViewModel.Container, id: String)
    func currentToolColorUpdated(withHex: String)
    func currentToolSizeUpdated(withSize: CGFloat)
    func userDidChangeColor(slot: Int, withHex: String)
}
