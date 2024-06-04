//
//  ContentView.swift
//  JetbeepExample
//
//  Created by Max Tymchii on 23.05.2024.
//

import SwiftUI
import CryptoSwift
import SwiftProtobuf
import JetbeepLockerSDK


struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!".md5())
            Text(BinaryDecodingError.invalidUTF8.localizedDescription)
            Text(BluetoothStatus.bluetoothNotSupported.hashValue.description)
        }

        .padding()
    }
}

#Preview {
    ContentView()
}
