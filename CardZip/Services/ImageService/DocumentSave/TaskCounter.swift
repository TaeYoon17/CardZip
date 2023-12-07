//
//  TaskGroup.swift
//  CardZip
//
//  Created by 김태윤 on 12/7/23.
//

import UIKit
import Photos
import PhotosUI
import Combine
actor TaskCounter{
    @Published private(set) var count = 0
    private(set) var maxCount: Int
    private var completed = PassthroughSubject<Bool,Never>()
    private var subscription = Set<AnyCancellable>()
    init(max:Int = 0) {
        self.maxCount = max
    }
    func changeMax(_ max:Int){
        self.maxCount = max
    }
    private func increment(){
        count += 1
        if maxCount == count{
            count = 0
            completed.send(true)
        }
    }
    private func reset(){ count = 0 }
    private func failed(){ completed.send(false) }
    func sink(receiveValue:@escaping (Bool)->Void)-> Subscribers.Sink<Bool,Never>{
        let sinker = Subscribers.Sink<Bool,Never>.init { _ in } receiveValue: { val in
            receiveValue(val)
        }
        completed.subscribe(sinker)
        return sinker
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
            self.sink(receiveValue: {[group] val in
                if !val{ group.cancelAll() }
            }).store(in: &subscription)
            try await group.waitForAll()
        }
    }
}
