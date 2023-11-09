//
//  FileRC.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/09.
//

import Foundation
import RealmSwift
struct ImageItem: ReferenceCountable{
    var name: String
    var count: Int
}
actor ImageRC:ReferenceCounter{
    typealias Item = ImageItem
    typealias Table = ImageTable
    @MainActor lazy var repository: TableRepository<Table> = ImageRepository()!
    var instance: [Item.ID : ImageItem]
    init(){
        instance = [:]
    }
    func saveRepository() async {
        instance.forEach { key,value in
            
        }
    }
    func plusCount(id: Item.ID) async {
        if instance[id] == nil{
            instance[id] = ImageItem(name: id, count: 1)
        }else{
            instance[id]?.count += 1
        }
    }
    func minusCount(id: Item.ID)async {
        instance[id]?.count -= 1
    }
}
