//
//  AnyResult.swift
//  jetbeepLocker
//
//  Created by Max Tymchii on 02.04.2024.
//

import Foundation
struct AnyResult: Identifiable {
    struct KeyValue: Identifiable {
        let id = UUID()
        let key: String
        let value: Any
    }

    let id: UUID = UUID()
    let result: Any
    let mirror: [KeyValue]
    let title: String

    init(_ result: Any?) {
        switch result {
        case .none:
            self.result = "Check your input data"
        case .some(let value):
            self.result = value
        }

        self.mirror = Mirror(reflecting: self.result).children
            .map { ($0.label ?? "", $0.value) }
            .compactMap(KeyValue.init(key:value:))
        self.title = String(describing: type(of: self.result))
    }
}
