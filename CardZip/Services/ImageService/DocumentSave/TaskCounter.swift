//
//  TaskGroup.swift
//  CardZip
//
//  Created by 김태윤 on 12/7/23.
//

import UIKit
import Combine
actor TaskCounter{
    @Published private(set) var count = 0
    @Published private(set) var maxCount: Int = 0
    private(set) var completed = PassthroughSubject<Bool,Never>()
    private var subscription = Set<AnyCancellable>()
    func changeMax(_ max:Int){ self.maxCount = max }
    private func increment(){
        count += 1
        if maxCount == count{
            count = 0
            completed.send(true)
        }
    }
    private func reset(){ count = 0 }
    private func failed(){ completed.send(false) }
    var progress: AnyPublisher<(Int,Int),Never>{
        $count.combineLatest($maxCount).eraseToAnyPublisher()
    }
}
extension TaskCounter{
    func run<T>(_ results: [T],action:@escaping ((T) async throws ->Void)) async throws{
        subscription.removeAll()
        self.changeMax(results.count)
        self.reset()
        try await withThrowingTaskGroup(of: Void.self) { group in
            for result in results{
                group.addTask {
                    do{
                        try await action(result)
                        await self.increment()
                    }catch{
                        await self.failed()
                    }
                }
            }
            self.completed.sink(receiveValue: {[group] val in
                if !val{ group.cancelAll() }
            }).store(in: &subscription)
            try await group.waitForAll()
        }
    }
}
