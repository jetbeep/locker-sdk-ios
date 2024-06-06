//
//  ResultView.swift
//  jetbeepLocker
//
//  Created by Max Tymchii on 02.04.2024.
//

import SwiftUI

@Observable
class ResultViewModel {

    let result: AnyResult

    init(_ result: AnyResult) {
        self.result = result
    }
}

struct ResultView: View {
    let viewModel: ResultViewModel

    init(_ result: AnyResult) {
        self.viewModel = ResultViewModel(result)
    }
    var body: some View {
        ScrollView {
            LazyVStack {
                Text(viewModel.result.title)
                    .font(.title)
                    .padding()
                ForEach(viewModel.result.mirror,
                        id: \.id) { item in
                    HStack {
                        Text(item.key)
                            .font(.headline)
                        Spacer()
                        Text(String(describing: item.value))
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

#Preview {
    let x: CGPoint? = CGPoint(x: 10, y: 20)
    return ResultView(AnyResult(x))
}
