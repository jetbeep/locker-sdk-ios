//
//  AppView.swift
//  jetbeepLocker
//
//  Created by Max Tymchii on 12.04.2024.
//

import SwiftUI

struct AppView: View {
    var body: some View {
        TabView {
            LockerManager()
                .tabItem {
                    Label("Locker", systemImage: "lock")
                }

            LogsView(viewModel: LogsViewModel())
                .tabItem {
                    Label("Logs", systemImage: "doc.text")
                }
        }
    }
}

#Preview {
    AppView()
}
