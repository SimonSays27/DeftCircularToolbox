//
//  2_EraserSelectionView.swift
//  DeftCircularToolbox
//
//  Created by Caner Ergin on 8.01.2026.
//
import SwiftUI

struct EraserSelectionView: View {
    
    @ObservedObject var vm: ToolboxViewModel
    
    var deskColor: Color { Color(uiColor: vm.deskColors.d) }
    var bgColor: Color { Color(uiColor: vm.deskColors.bg) }
    var fgColor: Color { Color(uiColor: vm.deskColors.fg) }
    
    var selectedToolEraserMode: Tool.EraserMode { vm.eraserMode }
    
    var body: some View {
        ZStack {
            WedgeShape(startAngle: .degrees(-90),
                       endAngle: .degrees(0),
                       innerRadius: 20,
                       outerRadius: 50,
                       strokeWidth: 2)
            .fill(selectedToolEraserMode == .pixel ? fgColor : bgColor)
            .stroke(bgColor, lineWidth: selectedToolEraserMode == .pixel ? 4 : 0)
            
            Text("Pixel")
                .font(.footnote)
                .foregroundStyle(selectedToolEraserMode == .pixel ? bgColor : fgColor)
                .rotationEffect(.degrees(45))
                .offset(x: 24, y: -24)
        }
        .scaleEffect(vm.formHidden ? 0.1 : 1.0)
        .onTapGesture(count: 1) {
            vm.userWantsEraserMode(.pixel)
        }

        ZStack {
            WedgeShape(startAngle: .degrees(0),
                       endAngle: .degrees(90),
                       innerRadius: 20,
                       outerRadius: 50,
                       strokeWidth: 2)
            .fill(selectedToolEraserMode == .object ? fgColor : bgColor)
            .stroke(bgColor, lineWidth: selectedToolEraserMode == .object ? 4 : 0)
            
            Text("Object")
                .font(.footnote)
                .foregroundStyle(selectedToolEraserMode == .object ? bgColor : fgColor)
                .rotationEffect(.degrees(-45))
                .offset(x: 24, y: 24)
        }
        .scaleEffect(vm.formHidden ? 0.1 : 1.0)
        .onTapGesture(count: 1) {
            vm.userWantsEraserMode(.object)
        }
    }
}
