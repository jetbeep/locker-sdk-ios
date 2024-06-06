//
//  BluetoothScanButtonModifier.swift
//  jetbeepLocker
//
//  Created by Max Tymchii on 02.04.2024.
//

import Foundation
import SwiftUI

struct GrowingButton: ButtonStyle {
    @Binding var isScan: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(maxWidth: .infinity)
            .padding()
            .background(isScan ? Color.blue : Color.green)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
