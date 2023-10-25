//
//  PublisherExtension.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/23.
//

import Foundation
import Combine
extension Publisher where Self.Failure == Never {
  func sink(receiveValue: @escaping ((Self.Output) async -> Void)) -> AnyCancellable {
    sink { value in
      Task {
        await receiveValue(value)
      }
    }
  }
}
extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async -> T
    ) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
}
