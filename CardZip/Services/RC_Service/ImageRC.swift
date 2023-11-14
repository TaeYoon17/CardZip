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
final class ImageRC:ReferenceCounter{
    typealias Item = ImageItem
    typealias Table = ReferenceTable
    @MainActor var repository = ReferenceRepository<ReferenceTable>()!
    var instance: [Item.ID : ImageItem] = [:]
    init(){
        Task{@MainActor in
            let res = repository.getAllTable().reduce(into: [:]) {
                $0[$1.id] = ImageItem.init(name: $1.name, count: $1.count)
            }
            self.instance = res
        }
    }
    
    func plusCount(id: Item.ID) async {
        if instance[id] == nil{
            instance[id] = ImageItem(name: id, count: 1)
        }else{
            instance[id]?.count += 1
        }
    }
    func minusCount(id: Item.ID) async {
        instance[id]?.count -= 1
    }
    func saveRepository() async {
        await instance.asyncForEach { key,value in
            await self.repository.update(item: value)
        }
        await repository.clearTable(type: .emptyBT, format: .jpg)
    }
    func apply(_ snapshot: ImageRC.SnapShot){
        instance = snapshot.instance
    }
    var snapshot:SnapShot{ SnapShot(irc: self) }
}


extension ImageRC{
    struct SnapShot{
        typealias Item = ImageItem
        typealias Table = ReferenceTable
        var instance: [Item.ID : ImageItem] = [:]
        init(irc: ImageRC){ instance = irc.instance }
        
        mutating func plusCount(id: Item.ID) async {
            if instance[id] == nil{
                instance[id] = ImageItem(name: id, count: 1)
            }else{
                instance[id]?.count += 1
            }
        }
        mutating func minusCount(id: Item.ID)async {
            instance[id]?.count -= 1
        }
    }
    
}
