import SwiftUI
import Combine

public protocol ToolboxViewModelDelegate: AnyObject {
    /// For view appeared
    func toolboxDidAppear()
    
    /// For Dragging action
    func viewCenterDragged(_ val: DragGesture.Value, didEnd: Bool)
    
    /// Action update
    func userDidTapAction(_ actionTool: Tool)
    
    /// Selection Updates
    func userDidTap(_ tool: Tool)
    func toolSelectionDidChange(to tool: Tool)
    func colorSelectionDidChange(of tool: Tool)
    func sliderValueDidChange(_ newValue: Double)
    
    /// User changed the selected color value
    func shouldShowColorPicker()
    
    /// Eraser Option
    var eraserMode: Tool.EraserMode? { get }
    var eraserModePublisher: AnyPublisher<Tool.EraserMode, Never>? { get }
    func userWantsEraserMode(_ em: Tool.EraserMode)
}
