//
//  ReferenceCounter.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/09.
//

import Foundation
import RealmSwift
protocol ReferenceCounter:AnyObject{
    associatedtype Item: ReferenceCountable
    associatedtype Table: ReferenceTable
    var repository : ReferenceRepository<Table> {get set}
    var instance: [Item.ID:Item] { get set }
    func plusCount(id: Item.ID) async
    func minusCount(id: Item.ID) async
    
    func saveRepository() async
//    func plusCount(item: Item) async
//    func minusCount(item: Item) async
}
//extension ReferenceCounter{
//    func plusCount(item: Item){
//        var item = item
//        item.count += 1
//        instance[item.id] = item
//    }
//    func minusCount(item: Item){
//        var item = item
//        item.count += 1
//        instance[item.id] = item
//    }
//}
