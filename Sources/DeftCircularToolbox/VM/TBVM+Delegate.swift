import SwiftUI

public protocol ToolboxViewModelDelegate: AnyObject {
    /// For view appeared
    func toolboxDidAppear()
    
    /// For Dragging action
    func viewCenterDragged(_ val: DragGesture.Value, didEnd: Bool)
    
    /// Selection Updates
    func toolSelectionDidChange(to tool: Tool)
    func colorSelectionDidChange(of tool: Tool)
    func sliderValueDidChange(_ newValue: Double)
    
    /// User changed the selected color value
    func shouldShowColorPicker()
}
