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
