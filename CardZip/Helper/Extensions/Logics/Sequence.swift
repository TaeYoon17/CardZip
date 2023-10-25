//
//  Sequence.swift
//  CardZip
//
//  Created by 김태윤 on 2023/10/12.
//

import Foundation
extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
}
public extension Array where Element : Hashable{
    mutating func appendWithSubtract(contentsOf : [Element]){
        let newSet = Set(contentsOf)
        let subSet = newSet.subtracting(self)
        self.append(contentsOf: subSet)
    }
    func appendingWithSubtract(contentsOf : [Element]) -> [Element]{
        let newSet = Set(contentsOf)
        let subSet = newSet.subtracting(self)
        return (self + subSet)
    }
}
