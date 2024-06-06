//
//  LogsView.swift
//  jetbeepLocker
//
//  Created by Max Tymchii on 12.04.2024.
//

import SwiftUI
import JetbeepLockerSDK
import Combine

extension Logger.Level {
    var color: Color {
        switch self {
        case .info:
            return .blue
        case .warning:
            return .orange
        case .error:
            return .red
        case .debug:
            return .green
        case .verbose:
            return .gray
        }
    }

    var prefix: String {
        switch self {
        case .info:
            return "ℹ️"
        case .warning:
            return "⚠️"
        case .error:
            return "❌"
        case .debug:
            return "🐞"
        case .verbose:
            return "🔍"
        }
    }
}

extension Logger.LogEvent {

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss:SSS"
        return formatter
    }

    var head: String {
        " \(level.prefix) \(Logger.LogEvent.dateFormatter.string(from: date)) \(filename): \(function): \(line)"
    }

}

@Observable class LogsViewModel {
    var logs: [Logger.LogEvent] = []

    var currentLevel: Logger.Level = .info

    private var cancellables: Set<AnyCancellable> = []

    init() {
        subscribeOnLogger()
    }

    func subscribeOnLogger() {
        logger
            .publisher
            .sink {[unowned self] event in
                if event.level <= currentLevel {
                    self.logs.append(event)
                }
            }
            .store(in: &cancellables)
    }

    func setLevel(_ level: Logger.Level) {
        currentLevel = level
    }
}

struct LogsView: View {
    @Bindable var viewModel: LogsViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.logs, id: \.self) { log in
                        VStack {
                            Text(log.head)
                                .font(.caption)
                                .fontWeight(.light)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(log.message)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .foregroundColor(log.level.color)
                    }
                }
            }
            .navigationTitle("Logs")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.logs = []
                    } label: {
                        Image(systemName: "trash")
                    }

                    Button {
                        let logs = viewModel.logs.map { "\($0.head) \($0.message)" }.joined(separator: "\n")
                        UIPasteboard.general.string = logs
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }

                }
            }
            .toolbarTitleMenu {
                Button("Error level") {
                    viewModel.setLevel(.error)
                }
                Button("Warning level") {
                    viewModel.setLevel(.warning)
                }
                Button("Info level") {
                    viewModel.setLevel(.info)
                }
                Button("Debug level") {
                    viewModel.setLevel(.debug)
                }
                Button("Verbose level") {
                    viewModel.setLevel(.verbose)
                }
            }
        }
    }
}

#Preview {
    let fakeLogs: [Logger.LogEvent] = [
        Logger.LogEvent(level: .info, date: Date(), filename: "Logger.swift",
                        function: "init", line: 10, message: "Info message"),
        Logger.LogEvent(level: .warning, date: Date(), filename: "Logger.swift",
                        function: "init", line: 10, message: "Warning message"),
        Logger.LogEvent(level: .error, date: Date(), filename: "Logger.swift",
                        function: "init", line: 10, message: "Error message"),
        Logger.LogEvent(level: .debug, date: Date(), filename: "Logger.swift",
                        function: "init", line: 10, message: "Debug message"),
        Logger.LogEvent(level: .verbose, date: Date(), filename: "Logger.swift",
                        function: "init", line: 10, message: "Verbose message")

    ]
    let model = LogsViewModel()
    model.logs = fakeLogs
    return LogsView(viewModel: model)
}
