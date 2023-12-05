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
}

