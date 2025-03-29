import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    
    var body: some View {
        ZStack {
            VStack {
                ColorPicker(selection: $selectedColor) {
                    //
                }
                .labelsHidden() // Hides any text labels
            }
        }.fixedSize()
    }
}

#Preview {
    @Previewable @State var selectedColor: Color = .black
    ColorPickerView(selectedColor: $selectedColor)
}

extension View {
    @ViewBuilder
    func modifierIf<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
